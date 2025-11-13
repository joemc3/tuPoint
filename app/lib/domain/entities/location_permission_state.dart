import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_permission_state.freezed.dart';

/// Represents the current state of location permissions.
///
/// This model wraps the various permission states that can occur
/// when requesting location access from the device. Each state
/// corresponds to a specific user action or system configuration.
///
/// States:
/// - [notAsked]: Initial state, no permission request made yet
/// - [granted]: User has granted location permission
/// - [denied]: User denied permission (can be requested again)
/// - [deniedForever]: User denied permission permanently (requires app settings)
/// - [serviceDisabled]: Location services are turned off system-wide
@freezed
class LocationPermissionState with _$LocationPermissionState {
  /// Permission has not been requested yet.
  ///
  /// This is the initial state before any permission dialog is shown.
  /// The app should request permission when location is needed.
  const factory LocationPermissionState.notAsked() = _NotAsked;

  /// User has granted location permission.
  ///
  /// The app can access device location. This may be either
  /// "while using" or "always" permission depending on the request.
  const factory LocationPermissionState.granted() = _Granted;

  /// User denied location permission.
  ///
  /// The permission was denied but can be requested again. The user
  /// may reconsider if shown a clear explanation of why location is needed.
  const factory LocationPermissionState.denied() = _Denied;

  /// User denied location permission permanently.
  ///
  /// On Android: User selected "Don't ask again" and denied
  /// On iOS: User denied after the second prompt
  ///
  /// The app must direct users to system settings to enable permission.
  /// Cannot show permission dialog anymore.
  const factory LocationPermissionState.deniedForever() = _DeniedForever;

  /// Location services are disabled system-wide.
  ///
  /// The user has turned off location services in device settings.
  /// The app must direct users to system settings to enable location services.
  /// This is different from permission denial - services must be enabled first.
  const factory LocationPermissionState.serviceDisabled() = _ServiceDisabled;
}
