# Location Services Implementation Guide

## Overview

The tuPoint location services provide comprehensive device location access with proper permission handling, error management, and real-time streaming capabilities. The implementation follows clean architecture principles and integrates seamlessly with Riverpod state management.

## Architecture

### Components

1. **Domain Models** (`lib/domain/entities/`)
   - `LocationPermissionState` - Represents permission states (granted, denied, etc.)
   - `LocationServiceState` - Represents location service states (available, loading, error, etc.)

2. **Service Layer** (`lib/core/services/`)
   - `LocationService` - Wraps geolocator package with domain-specific logic

3. **State Management** (`lib/core/providers/`)
   - `location_providers.dart` - Riverpod providers for location functionality

4. **Platform Configuration**
   - iOS: `ios/Runner/Info.plist` - Permission descriptions
   - Android: `android/app/src/main/AndroidManifest.xml` - Permission declarations

## Usage Examples

### 1. Check Permission Status

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/providers/location_providers.dart';

class PermissionCheckWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(locationPermissionProvider);

    return permissionState.when(
      data: (state) => state.when(
        granted: () => Text('Location permission granted'),
        denied: () => ElevatedButton(
          onPressed: () {
            // Refresh to trigger permission request
            ref.refresh(locationPermissionProvider);
          },
          child: Text('Request Permission'),
        ),
        deniedForever: () => ElevatedButton(
          onPressed: () async {
            final locationService = ref.read(locationServiceProvider);
            await locationService.openAppSettings();
          },
          child: Text('Open Settings'),
        ),
        serviceDisabled: () => Text('Enable location services in device settings'),
        notAsked: () => Text('Permission not yet requested'),
      ),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error checking permission: $err'),
    );
  }
}
```

### 2. Get Current Location (One-Time)

Use this for point creation where you need location once:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/providers/location_providers.dart';

class CreatePointButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = ref.watch(currentLocationProvider);

    return currentLocation.when(
      data: (state) => state.when(
        available: (location) => ElevatedButton(
          onPressed: () {
            // Use location.latitude and location.longitude
            _createPoint(location);
          },
          child: Text('Drop Point Here'),
        ),
        loading: () => CircularProgressIndicator(),
        permissionDenied: (message, isPermanent) => Text(message),
        serviceDisabled: (message) => Text(message),
        error: (message) => Text(message),
      ),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Failed to get location'),
    );
  }

  void _createPoint(LocationCoordinate location) {
    // Create point at this location
  }
}
```

### 3. Stream Real-Time Location Updates

Use this for the main feed to continuously update nearby points:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/providers/location_providers.dart';

class NearbyPointsFeed extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationStream = ref.watch(locationStreamProvider);

    return locationStream.when(
      data: (state) => state.when(
        available: (location) => _buildFeed(ref, location),
        loading: () => Center(child: CircularProgressIndicator()),
        permissionDenied: (message, isPermanent) => _buildPermissionError(
          context,
          ref,
          message,
          isPermanent,
        ),
        serviceDisabled: (message) => _buildServiceDisabledError(message),
        error: (message) => _buildErrorDisplay(message),
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Location stream error: $err'),
    );
  }

  Widget _buildFeed(WidgetRef ref, LocationCoordinate userLocation) {
    // Filter points within 5km of userLocation
    // Use HaversineCalculator for distance filtering
    return ListView(/* nearby points */);
  }
}
```

### 4. Integration with FetchNearbyPointsUseCase

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/providers/location_providers.dart';
import 'package:app/domain/use_cases/point_use_cases/fetch_nearby_points_use_case.dart';

final nearbyPointsProvider = FutureProvider.autoDispose((ref) async {
  // Get current location
  final locationState = await ref.watch(currentLocationProvider.future);

  // Extract location from state
  final location = locationState.maybeWhen(
    available: (loc) => loc,
    orElse: () => null,
  );

  if (location == null) {
    return []; // No location available
  }

  // Fetch nearby points using the use case
  final useCase = ref.watch(fetchNearbyPointsUseCaseProvider);
  final request = FetchNearbyPointsRequest(
    centerLocation: location,
    radiusKm: 5.0, // 5km radius for MVP
  );

  return await useCase.call(request);
});
```

### 5. Simplified Boolean Checks

For simple permission checks:

```dart
// Check if permission is granted
final hasPermission = ref.watch(hasLocationPermissionProvider);
hasPermission.when(
  data: (granted) => granted
    ? LocationFeature()
    : RequestPermissionButton(),
  loading: () => CircularProgressIndicator(),
  error: (_, __) => ErrorWidget(),
);

// Check if services are enabled
final servicesEnabled = ref.watch(locationServicesEnabledProvider);
servicesEnabled.when(
  data: (enabled) => enabled
    ? PermissionCheckWidget()
    : EnableLocationServicesDialog(),
  loading: () => CircularProgressIndicator(),
  error: (_, __) => ErrorWidget(),
);
```

## Available Providers

| Provider | Type | Purpose | Use Case |
|----------|------|---------|----------|
| `locationServiceProvider` | `Provider<LocationService>` | Access to location service | Direct service calls |
| `locationPermissionProvider` | `FutureProvider<LocationPermissionState>` | Current permission state | Check/display permission status |
| `currentLocationProvider` | `FutureProvider<LocationServiceState>` | One-time location fetch | Point creation, one-off location needs |
| `locationStreamProvider` | `StreamProvider<LocationServiceState>` | Real-time location updates | Main feed, continuous tracking |
| `hasLocationPermissionProvider` | `FutureProvider<bool>` | Simple permission check | Simple boolean conditional logic |
| `locationServicesEnabledProvider` | `FutureProvider<bool>` | Service enabled check | Check if GPS is on |

## Error Handling

### Permission Denied (Temporary)

User denied permission but can be asked again:

```dart
state.when(
  permissionDenied: (message, isPermanent) {
    if (!isPermanent) {
      // Show explanation and request again
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Location Access Needed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.refresh(currentLocationProvider);
              },
              child: Text('Allow'),
            ),
          ],
        ),
      );
    }
  },
  // ...
);
```

### Permission Denied Forever

User must enable in system settings:

```dart
state.when(
  permissionDenied: (message, isPermanent) {
    if (isPermanent) {
      // Direct to settings
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Enable Location in Settings'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () async {
                final locationService = ref.read(locationServiceProvider);
                await locationService.openAppSettings();
                Navigator.pop(context);
              },
              child: Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  },
  // ...
);
```

### Location Services Disabled

GPS is turned off system-wide:

```dart
state.when(
  serviceDisabled: (message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.location_off, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final locationService = ref.read(locationServiceProvider);
            await locationService.openLocationSettings();
          },
          child: Text('Open Location Settings'),
        ),
      ],
    );
  },
  // ...
);
```

### Timeout or No Signal

GPS signal unavailable:

```dart
state.when(
  error: (message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.signal_cellular_connected_no_internet_0_bar,
             size: 64, color: Colors.orange),
        SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            ref.refresh(currentLocationProvider);
          },
          child: Text('Try Again'),
        ),
      ],
    );
  },
  // ...
);
```

## Platform Configuration

### iOS (Info.plist)

Two keys are required:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>tuPoint needs your location to show nearby Points within 5km and to create new Points at your current location. Your exact location is never shared publicly - only an approximate area is shown.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>tuPoint needs your location to show nearby Points and create new Points. Your exact location is never shared publicly.</string>
```

### Android (AndroidManifest.xml)

Two permissions are required:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

## Location Settings

### Accuracy

- **Mode**: High accuracy (GPS)
- **Reason**: Ensures accurate 5km radius filtering and precise Maidenhead grid square calculation
- **Trade-off**: Higher battery consumption, but necessary for MVP location features

### Distance Filter

- **Value**: 10 meters
- **Behavior**: Location updates only trigger when user moves at least 10m
- **Reason**: Balances update frequency with battery consumption

### Timeout

- **Value**: 15 seconds
- **Behavior**: Location request fails if not obtained within timeout
- **Reason**: Prevents indefinite waiting in poor GPS signal areas

## Testing

Run location entity tests:

```bash
flutter test test/domain/entities/location_permission_state_test.dart
flutter test test/domain/entities/location_service_state_test.dart
```

## Best Practices

### 1. Request Permission at the Right Time

Don't request permission on app launch. Request when the user takes an action that requires location:

```dart
// BAD: Request on app start
void initState() {
  super.initState();
  ref.read(locationPermissionProvider);
}

// GOOD: Request when user wants to see feed
void _viewNearbyPoints() {
  final location = ref.watch(currentLocationProvider);
  // Permission is requested automatically if needed
}
```

### 2. Provide Context

Always explain why location is needed before requesting:

```dart
void _showLocationExplanation() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Location Access'),
      content: Text(
        'tuPoint shows you Points within 5km of your location. '
        'Your exact coordinates are never shared - only an approximate area.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Now request permission
            ref.refresh(currentLocationProvider);
          },
          child: Text('Continue'),
        ),
      ],
    ),
  );
}
```

### 3. Use Appropriate Provider

- **One-time fetch**: Use `currentLocationProvider` (point creation)
- **Continuous updates**: Use `locationStreamProvider` (main feed)
- **Permission check**: Use `locationPermissionProvider` or `hasLocationPermissionProvider`

### 4. Handle All States

Always handle all possible states in `.when()` callbacks:

```dart
state.when(
  available: (location) => /* success */,
  loading: () => /* loading indicator */,
  permissionDenied: (msg, isPermanent) => /* handle both cases */,
  serviceDisabled: (msg) => /* direct to settings */,
  error: (msg) => /* show error with retry */,
);
```

### 5. Refresh When Returning from Settings

When user returns from settings after enabling permission:

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    // User returned from settings, refresh permission check
    ref.refresh(locationPermissionProvider);
  }
}
```

## Integration Points

### With FetchNearbyPointsUseCase

```dart
final nearbyPointsProvider = FutureProvider((ref) async {
  final locationState = await ref.watch(currentLocationProvider.future);
  final location = locationState.maybeWhen(
    available: (loc) => loc,
    orElse: () => null,
  );

  if (location == null) return [];

  final useCase = ref.watch(fetchNearbyPointsUseCaseProvider);
  return await useCase(FetchNearbyPointsRequest(
    centerLocation: location,
    radiusKm: 5.0,
  ));
});
```

### With DropPointUseCase

```dart
Future<void> _dropPoint(String content) async {
  final locationState = await ref.read(currentLocationProvider.future);

  final location = locationState.maybeWhen(
    available: (loc) => loc,
    orElse: () => null,
  );

  if (location == null) {
    _showError('Location not available');
    return;
  }

  final useCase = ref.read(dropPointUseCaseProvider);
  await useCase(DropPointRequest(
    content: content,
    location: location,
  ));
}
```

### With MaidenheadConverter

```dart
final maidenheadProvider = Provider<String?>((ref) {
  final locationState = ref.watch(currentLocationProvider);

  return locationState.maybeWhen(
    data: (state) => state.maybeWhen(
      available: (location) {
        final converter = MaidenheadConverter();
        return converter.encode(location, precision: 6);
      },
      orElse: () => null,
    ),
    orElse: () => null,
  );
});
```

## Troubleshooting

### Location Never Loads

1. Check platform permissions are configured correctly
2. Verify device location services are enabled
3. Ensure app has permission (check in device settings)
4. Try outdoors with clear sky view for GPS signal

### Permission Request Not Showing

1. Check if permission was previously denied forever
2. Check platform configuration (Info.plist / AndroidManifest.xml)
3. Verify you're calling the provider that triggers permission request

### Location Updates Too Frequent

1. Adjust `distanceFilter` in LocationService (currently 10m)
2. Consider using `currentLocationProvider` instead of stream for infrequent updates

### High Battery Consumption

1. Use `locationStreamProvider` only when needed (main feed screen)
2. Cancel subscriptions when screen is not visible
3. Consider reducing accuracy for non-critical features (would require service modification)

## Future Enhancements

### Background Location (Not in MVP)

If future versions need background location:

1. Add `ACCESS_BACKGROUND_LOCATION` permission for Android 10+
2. Add `NSLocationAlwaysUsageDescription` to iOS Info.plist
3. Modify LocationService to support background mode
4. Handle additional permission flow for background access

### Geofencing (Not in MVP)

If implementing "auto-delete when leaving area":

1. Use `geolocator` package's geofencing features
2. Set up geofence around each Point user interacts with
3. Listen for geofence exit events
4. Trigger local cleanup when user exits 5km radius

### Location Caching (Not in MVP)

If implementing location caching for offline:

1. Store last known location in shared preferences
2. Use cached location with timestamp warning if fresh location unavailable
3. Invalidate cache after reasonable time period (e.g., 5 minutes)

## Summary

The location services implementation provides:

- ✅ Comprehensive permission handling (all states covered)
- ✅ One-time and streaming location access
- ✅ Platform-specific configuration (iOS + Android)
- ✅ Domain model integration (LocationCoordinate)
- ✅ Riverpod state management integration
- ✅ Clear error messages for all scenarios
- ✅ Testing infrastructure for entities
- ✅ Ready for use in FetchNearbyPointsUseCase and DropPointUseCase

All location functionality needed for tuPoint MVP is now available through clean, well-documented interfaces.
