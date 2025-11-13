# Location Services Quick Start

## Import

```dart
import 'package:app/core/providers/location_providers.dart';
```

## Common Use Cases

### 1. Get Location Once (Point Creation)

```dart
final currentLocation = ref.watch(currentLocationProvider);

currentLocation.when(
  data: (state) => state.when(
    available: (location) {
      // Use location.latitude and location.longitude
      _createPoint(location);
    },
    loading: () => CircularProgressIndicator(),
    permissionDenied: (msg, isPermanent) => Text(msg),
    serviceDisabled: (msg) => Text(msg),
    error: (msg) => Text(msg),
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, _) => Text('Error: $err'),
);
```

### 2. Stream Location (Main Feed)

```dart
final locationStream = ref.watch(locationStreamProvider);

locationStream.when(
  data: (state) => state.when(
    available: (location) => NearbyPointsList(userLocation: location),
    loading: () => Text('Finding your location...'),
    permissionDenied: (msg, isPermanent) => PermissionError(msg, isPermanent),
    serviceDisabled: (msg) => ServiceError(msg),
    error: (msg) => ErrorDisplay(msg),
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, _) => Text('Stream error: $err'),
);
```

### 3. Check Permission Only

```dart
final hasPermission = ref.watch(hasLocationPermissionProvider);

hasPermission.when(
  data: (granted) => granted
    ? LocationFeature()
    : RequestPermissionButton(),
  loading: () => CircularProgressIndicator(),
  error: (_, __) => ErrorWidget(),
);
```

### 4. Handle Permission Errors

```dart
Widget buildPermissionError(String message, bool isPermanent, WidgetRef ref) {
  return Column(
    children: [
      Text(message),
      ElevatedButton(
        onPressed: () async {
          if (isPermanent) {
            // Open app settings
            final service = ref.read(locationServiceProvider);
            await service.openAppSettings();
          } else {
            // Request permission again
            ref.refresh(currentLocationProvider);
          }
        },
        child: Text(isPermanent ? 'Open Settings' : 'Request Permission'),
      ),
    ],
  );
}
```

### 5. Refresh Location

```dart
// Refresh one-time location
ElevatedButton(
  onPressed: () => ref.refresh(currentLocationProvider),
  child: Text('Refresh Location'),
);

// Refresh permission check
ElevatedButton(
  onPressed: () => ref.refresh(locationPermissionProvider),
  child: Text('Check Permission'),
);
```

## Provider Reference

| Provider | Returns | Best For |
|----------|---------|----------|
| `currentLocationProvider` | `FutureProvider<LocationServiceState>` | Point creation, one-off location |
| `locationStreamProvider` | `StreamProvider<LocationServiceState>` | Main feed, continuous tracking |
| `hasLocationPermissionProvider` | `FutureProvider<bool>` | Simple conditional logic |
| `locationPermissionProvider` | `FutureProvider<LocationPermissionState>` | Detailed permission status |
| `locationServiceProvider` | `Provider<LocationService>` | Direct service access |

## Error States

| State | Meaning | User Action |
|-------|---------|-------------|
| `permissionDenied(msg, isPermanent: false)` | User denied, can ask again | Show explanation, request again |
| `permissionDenied(msg, isPermanent: true)` | User denied permanently | Direct to app settings |
| `serviceDisabled(msg)` | GPS turned off | Direct to location settings |
| `error(msg)` | Timeout or no signal | Retry or move outdoors |
| `loading()` | Fetching location | Show loading indicator |

## Complete Example: Point Creation Screen

```dart
class CreatePointScreen extends ConsumerWidget {
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = ref.watch(currentLocationProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Create Point')),
      body: Column(
        children: [
          TextField(
            controller: _contentController,
            decoration: InputDecoration(labelText: 'Content'),
            maxLength: 280,
          ),
          currentLocation.when(
            data: (state) => state.when(
              available: (location) => ElevatedButton(
                onPressed: () => _createPoint(ref, location),
                child: Text('Drop Point Here'),
              ),
              loading: () => CircularProgressIndicator(),
              permissionDenied: (msg, isPermanent) =>
                _buildPermissionError(ref, msg, isPermanent),
              serviceDisabled: (msg) => _buildServiceError(ref, msg),
              error: (msg) => _buildLocationError(ref, msg),
            ),
            loading: () => CircularProgressIndicator(),
            error: (err, _) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPoint(WidgetRef ref, LocationCoordinate location) async {
    final useCase = ref.read(dropPointUseCaseProvider);
    await useCase(DropPointRequest(
      content: _contentController.text,
      location: location,
    ));
    // Navigate back or show success
  }

  Widget _buildPermissionError(WidgetRef ref, String msg, bool isPermanent) {
    return Column(
      children: [
        Text(msg, textAlign: TextAlign.center),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            if (isPermanent) {
              await ref.read(locationServiceProvider).openAppSettings();
            } else {
              ref.refresh(currentLocationProvider);
            }
          },
          child: Text(isPermanent ? 'Open Settings' : 'Request Permission'),
        ),
      ],
    );
  }

  Widget _buildServiceError(WidgetRef ref, String msg) {
    return Column(
      children: [
        Icon(Icons.location_off, size: 64),
        SizedBox(height: 16),
        Text(msg, textAlign: TextAlign.center),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            await ref.read(locationServiceProvider).openLocationSettings();
          },
          child: Text('Enable Location'),
        ),
      ],
    );
  }

  Widget _buildLocationError(WidgetRef ref, String msg) {
    return Column(
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.orange),
        SizedBox(height: 16),
        Text(msg, textAlign: TextAlign.center),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => ref.refresh(currentLocationProvider),
          child: Text('Try Again'),
        ),
      ],
    );
  }
}
```

## Tips

1. **Use currentLocationProvider for one-off needs** (point creation)
2. **Use locationStreamProvider for continuous tracking** (main feed)
3. **Always handle all states** in `.when()` callbacks
4. **Refresh location when returning from settings** (use AppLifecycleObserver)
5. **Explain why location is needed** before requesting permission
6. **Show clear error messages** for each failure scenario

## See Also

- Full documentation: `lib/core/services/LOCATION_SERVICES_README.md`
- Implementation: `lib/core/services/location_service.dart`
- Models: `lib/domain/entities/location_permission_state.dart` and `location_service_state.dart`
