import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/location_permission_state.dart';
import '../../domain/entities/location_service_state.dart';
import '../../domain/value_objects/location_coordinate.dart';

/// Service for accessing device location with comprehensive permission handling.
///
/// This service wraps the geolocator package and provides:
/// - One-time location fetching with timeout
/// - Real-time location streaming
/// - Permission checking and requesting
/// - Location service availability checking
/// - Detailed error handling and user-friendly messages
///
/// All location data is returned as domain [LocationCoordinate] objects
/// for consistency with the rest of the application.
///
/// Usage:
/// ```dart
/// final locationService = LocationService();
///
/// // Check permission status
/// final permissionState = await locationService.checkPermission();
///
/// // Get current location once
/// final location = await locationService.getCurrentLocation();
///
/// // Stream location updates
/// final stream = locationService.getLocationStream();
/// ```
class LocationService {
  /// Default timeout for location requests.
  ///
  /// If location is not obtained within this time, the request fails.
  /// This prevents indefinite waiting in areas with poor GPS signal.
  static const Duration _defaultTimeout = Duration(seconds: 15);

  /// Location accuracy settings for requests.
  ///
  /// Uses high accuracy to ensure:
  /// - Accurate 5km radius filtering for nearby Points
  /// - Precise Point creation locations
  /// - Reliable Maidenhead grid square calculation
  ///
  /// Note: High accuracy uses GPS which consumes more battery.
  /// For MVP, accuracy is prioritized over battery optimization.
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Minimum 10m movement to trigger update
  );

  /// Checks the current location permission state.
  ///
  /// This method checks both:
  /// 1. Whether location services are enabled system-wide
  /// 2. What permission level the app currently has
  ///
  /// Returns a [LocationPermissionState] indicating the current state.
  /// This does NOT request permission - use [requestPermission] for that.
  ///
  /// Example:
  /// ```dart
  /// final state = await locationService.checkPermission();
  /// state.when(
  ///   granted: () => print('Can access location'),
  ///   denied: () => print('Permission denied'),
  ///   serviceDisabled: () => print('Location services off'),
  ///   // ...
  /// );
  /// ```
  Future<LocationPermissionState> checkPermission() async {
    try {
      // First check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationPermissionState.serviceDisabled();
      }

      // Then check permission status
      final permission = await Geolocator.checkPermission();
      return _mapPermissionToState(permission);
    } catch (_) {
      // If we can't check permission, treat as not asked
      // This shouldn't happen in normal operation
      return const LocationPermissionState.notAsked();
    }
  }

  /// Requests location permission from the user.
  ///
  /// This shows the system permission dialog if:
  /// - Permission has not been requested before
  /// - Permission was previously denied (but not permanently)
  ///
  /// If permission was denied permanently, this returns [deniedForever]
  /// without showing a dialog. The app must direct users to settings.
  ///
  /// Returns the new [LocationPermissionState] after the request.
  ///
  /// Example:
  /// ```dart
  /// final state = await locationService.requestPermission();
  /// state.when(
  ///   granted: () => _fetchLocation(),
  ///   deniedForever: () => _showSettingsDialog(),
  ///   // ...
  /// );
  /// ```
  Future<LocationPermissionState> requestPermission() async {
    try {
      // Check if services are enabled first
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationPermissionState.serviceDisabled();
      }

      // Request permission
      final permission = await Geolocator.requestPermission();
      return _mapPermissionToState(permission);
    } catch (e) {
      // If request fails, return denied state
      return const LocationPermissionState.denied();
    }
  }

  /// Gets the current device location as a one-time fetch.
  ///
  /// This method:
  /// 1. Checks if location services are enabled
  /// 2. Checks/requests location permission
  /// 3. Fetches current location with timeout
  /// 4. Returns [LocationServiceState] with result or error
  ///
  /// The method is self-contained and handles all permission checking
  /// internally, so callers don't need to check permissions separately.
  ///
  /// Timeout: [_defaultTimeout] (15 seconds)
  ///
  /// Returns:
  /// - [LocationServiceState.available] with current location on success
  /// - [LocationServiceState.permissionDenied] if permission denied
  /// - [LocationServiceState.serviceDisabled] if services disabled
  /// - [LocationServiceState.error] for timeout or other errors
  ///
  /// Example:
  /// ```dart
  /// final state = await locationService.getCurrentLocation();
  /// state.when(
  ///   available: (location) => print('At: $location'),
  ///   permissionDenied: (msg, isPermanent) => _showPermissionError(msg),
  ///   error: (msg) => _showError(msg),
  ///   // ...
  /// );
  /// ```
  Future<LocationServiceState> getCurrentLocation({
    Duration timeout = _defaultTimeout,
  }) async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationServiceState.serviceDisabled(
          message: 'Location services are disabled. '
              'Please enable location services in your device settings.',
        );
      }

      // Check current permission
      var permission = await Geolocator.checkPermission();

      // Request permission if not yet asked or denied (but not permanently)
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Handle denied permission
      if (permission == LocationPermission.denied) {
        return const LocationServiceState.permissionDenied(
          message: 'Location permission denied. '
              'tuPoint needs your location to show nearby Points and create new Points.',
          isPermanent: false,
        );
      }

      // Handle permanently denied permission
      if (permission == LocationPermission.deniedForever) {
        return const LocationServiceState.permissionDenied(
          message: 'Location permission permanently denied. '
              'Please enable location access in app settings.',
          isPermanent: true,
        );
      }

      // Permission granted - fetch location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      ).timeout(
        timeout,
        onTimeout: () => throw TimeoutException(
          'Location request timed out after ${timeout.inSeconds} seconds',
        ),
      );

      // Convert to domain LocationCoordinate
      final coordinate = LocationCoordinate(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return LocationServiceState.available(location: coordinate);
    } on TimeoutException catch (e) {
      return LocationServiceState.error(
        message: 'Location request timed out. '
            'Please ensure you have a clear view of the sky and try again.',
      );
    } catch (e) {
      // Handle any other errors (no signal, hardware issues, etc.)
      return LocationServiceState.error(
        message: 'Unable to get your location. '
            'Please check that location services are enabled and try again.',
      );
    }
  }

  /// Provides a stream of real-time location updates.
  ///
  /// This stream emits [LocationServiceState] values whenever:
  /// - Location changes by at least [distanceFilter] meters (10m)
  /// - Permission or service state changes
  /// - An error occurs
  ///
  /// The stream automatically handles:
  /// - Initial permission checking
  /// - Permission changes while streaming
  /// - Service enabled/disabled changes
  /// - Error recovery
  ///
  /// The stream does NOT close automatically. Callers should:
  /// - Cancel the subscription when location updates are no longer needed
  /// - Handle all state changes (not just available state)
  ///
  /// Location settings:
  /// - Accuracy: High (GPS)
  /// - Distance filter: 10 meters
  ///
  /// Example:
  /// ```dart
  /// final subscription = locationService
  ///   .getLocationStream()
  ///   .listen((state) {
  ///     state.when(
  ///       available: (location) => _updateMap(location),
  ///       error: (msg) => _showError(msg),
  ///       // ...
  ///     );
  ///   });
  ///
  /// // Later, when done:
  /// subscription.cancel();
  /// ```
  Stream<LocationServiceState> getLocationStream() async* {
    // Check initial state
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      yield const LocationServiceState.serviceDisabled(
        message: 'Location services are disabled. '
            'Please enable location services in your device settings.',
      );
      return;
    }

    // Check permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      yield const LocationServiceState.permissionDenied(
        message: 'Location permission denied. '
            'tuPoint needs your location to show nearby Points.',
        isPermanent: false,
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      yield const LocationServiceState.permissionDenied(
        message: 'Location permission permanently denied. '
            'Please enable location access in app settings.',
        isPermanent: true,
      );
      return;
    }

    // Start streaming location updates
    yield const LocationServiceState.loading();

    try {
      await for (final position
          in Geolocator.getPositionStream(locationSettings: _locationSettings)) {
        final coordinate = LocationCoordinate(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        yield LocationServiceState.available(location: coordinate);
      }
    } catch (e) {
      yield LocationServiceState.error(
        message: 'Error streaming location updates: ${e.toString()}',
      );
    }
  }

  /// Opens device settings for location permissions.
  ///
  /// Use this when permission is denied permanently and the user
  /// needs to manually enable location access in app settings.
  ///
  /// Returns true if settings were opened successfully, false otherwise.
  ///
  /// Note: This does not wait for the user to change settings.
  /// The app should re-check permission when returning to foreground.
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Opens device settings for the app.
  ///
  /// Use this when permission is denied permanently on platforms
  /// where app-specific settings are separate from location settings.
  ///
  /// Returns true if settings were opened successfully, false otherwise.
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Maps geolocator permission enum to domain permission state.
  ///
  /// This internal helper converts the geolocator-specific permission
  /// values to our domain model for consistency across the app.
  LocationPermissionState _mapPermissionToState(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return const LocationPermissionState.denied();
      case LocationPermission.deniedForever:
        return const LocationPermissionState.deniedForever();
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return const LocationPermissionState.granted();
      case LocationPermission.unableToDetermine:
        // Treat unable to determine as not asked
        return const LocationPermissionState.notAsked();
    }
  }
}
