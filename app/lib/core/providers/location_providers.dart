import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/location_permission_state.dart';
import '../../domain/entities/location_service_state.dart';
import '../services/location_service.dart';

/// Provides the LocationService singleton instance.
///
/// This service handles all location-related operations including:
/// - Permission checking and requesting
/// - One-time location fetching
/// - Real-time location streaming
/// - Error handling for all location scenarios
///
/// The service is kept as a singleton throughout the app lifecycle
/// to maintain consistent state and avoid redundant initialization.
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Provides the current location permission state.
///
/// This provider fetches the current permission state when accessed.
/// It checks both location service availability and permission level.
///
/// States:
/// - [LocationPermissionState.notAsked]: No permission request made
/// - [LocationPermissionState.granted]: Permission granted
/// - [LocationPermissionState.denied]: Permission denied (can ask again)
/// - [LocationPermissionState.deniedForever]: Permanently denied (needs settings)
/// - [LocationPermissionState.serviceDisabled]: Location services off
///
/// This is a FutureProvider, so it can be watched with `.when()`:
///
/// Example:
/// ```dart
/// final permissionState = ref.watch(locationPermissionProvider);
/// permissionState.when(
///   data: (state) => state.when(
///     granted: () => Text('Location enabled'),
///     denied: () => ElevatedButton(
///       onPressed: () => ref.refresh(locationPermissionProvider),
///       child: Text('Request permission'),
///     ),
///     deniedForever: () => Text('Enable in settings'),
///     // ...
///   ),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error checking permission'),
/// );
/// ```
final locationPermissionProvider =
    FutureProvider<LocationPermissionState>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.checkPermission();
});

/// Provides the current device location as a one-time fetch.
///
/// This provider:
/// 1. Automatically checks/requests location permission
/// 2. Fetches current device location with 15 second timeout
/// 3. Returns [LocationServiceState] with result or error
///
/// The provider handles all permission checking internally, so consumers
/// don't need to check permissions separately before accessing location.
///
/// Use this provider when you need location once (e.g., creating a Point).
/// For continuous updates, use [locationStreamProvider] instead.
///
/// Example:
/// ```dart
/// final currentLocation = ref.watch(currentLocationProvider);
/// currentLocation.when(
///   data: (state) => state.when(
///     available: (location) => Text('At: $location'),
///     permissionDenied: (msg, isPermanent) => PermissionError(msg),
///     serviceDisabled: (msg) => ServiceDisabledError(msg),
///     error: (msg) => ErrorWidget(msg),
///     loading: () => CircularProgressIndicator(),
///   ),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Failed to get location'),
/// );
/// ```
///
/// To refresh the location:
/// ```dart
/// ref.refresh(currentLocationProvider);
/// ```
final currentLocationProvider =
    FutureProvider<LocationServiceState>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentLocation();
});

/// Provides a stream of real-time location updates.
///
/// This provider emits [LocationServiceState] values whenever:
/// - Location changes by at least 10 meters
/// - Permission or service state changes
/// - An error occurs
///
/// The stream automatically handles:
/// - Initial permission checking/requesting
/// - Permission changes during streaming
/// - Service enabled/disabled changes
/// - Error recovery
///
/// Settings:
/// - Accuracy: High (GPS)
/// - Distance filter: 10 meters (minimum movement to trigger update)
///
/// Use this provider for:
/// - Main feed with real-time nearby Points filtering
/// - Map views that track user movement
/// - Any UI that needs continuous location updates
///
/// The stream does NOT close automatically. Riverpod manages the lifecycle
/// and will dispose the stream when no longer watched.
///
/// Example:
/// ```dart
/// final locationStream = ref.watch(locationStreamProvider);
/// locationStream.when(
///   data: (state) => state.when(
///     available: (location) => MapView(userLocation: location),
///     loading: () => Text('Finding your location...'),
///     permissionDenied: (msg, isPermanent) => isPermanent
///       ? SettingsButton()
///       : RequestPermissionButton(),
///     serviceDisabled: (msg) => EnableLocationServicesButton(),
///     error: (msg) => ErrorDisplay(msg),
///   ),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Location stream error'),
/// );
/// ```
///
/// Note: For one-time location fetches (e.g., dropping a Point),
/// use [currentLocationProvider] instead to avoid unnecessary streaming.
final locationStreamProvider =
    StreamProvider<LocationServiceState>((ref) async* {
  final locationService = ref.watch(locationServiceProvider);
  yield* locationService.getLocationStream();
});

/// Provides whether location permission has been granted.
///
/// This is a convenience provider that simplifies permission checking
/// in widgets that only care about granted vs. not-granted.
///
/// Returns true only if permission is fully granted (whileInUse or always).
/// Returns false for all other states (denied, deniedForever, serviceDisabled, notAsked).
///
/// Use this when you need a simple boolean check:
/// ```dart
/// final hasPermission = ref.watch(hasLocationPermissionProvider);
/// hasPermission.when(
///   data: (granted) => granted
///     ? LocationBasedFeature()
///     : RequestPermissionButton(),
///   loading: () => CircularProgressIndicator(),
///   error: (_, __) => ErrorWidget(),
/// );
/// ```
final hasLocationPermissionProvider = FutureProvider<bool>((ref) async {
  final permissionState = await ref.watch(locationPermissionProvider.future);
  return permissionState.maybeWhen(
    granted: () => true,
    orElse: () => false,
  );
});

/// Provides whether location services are enabled on the device.
///
/// This is a convenience provider that checks specifically for the
/// service disabled state, ignoring permission status.
///
/// Returns:
/// - false: Location services are disabled (user must enable in device settings)
/// - true: Location services are enabled (but permission might still be denied)
///
/// Use this to show specific guidance about enabling location services
/// separately from permission issues:
/// ```dart
/// final servicesEnabled = ref.watch(locationServicesEnabledProvider);
/// servicesEnabled.when(
///   data: (enabled) => enabled
///     ? PermissionCheckWidget()
///     : EnableLocationServicesDialog(),
///   loading: () => CircularProgressIndicator(),
///   error: (_, __) => ErrorWidget(),
/// );
/// ```
final locationServicesEnabledProvider = FutureProvider<bool>((ref) async {
  final permissionState = await ref.watch(locationPermissionProvider.future);
  return permissionState.maybeWhen(
    serviceDisabled: () => false,
    orElse: () => true,
  );
});
