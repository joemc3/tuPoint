import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/location_coordinate.dart';

part 'location_service_state.freezed.dart';

/// Represents the current state of the location service.
///
/// This model encapsulates all possible states when accessing
/// device location, including loading, success, and various error states.
///
/// States:
/// - [loading]: Fetching location from device
/// - [available]: Location successfully retrieved
/// - [permissionDenied]: User denied location permission
/// - [serviceDisabled]: Location services turned off
/// - [error]: Generic error occurred (timeout, no signal, etc.)
@freezed
class LocationServiceState with _$LocationServiceState {
  /// Location is being fetched from the device.
  ///
  /// This state indicates an ongoing location request.
  /// UI should show a loading indicator.
  const factory LocationServiceState.loading() = _Loading;

  /// Location successfully retrieved.
  ///
  /// Contains the current device location as a [LocationCoordinate].
  /// This coordinate can be used for:
  /// - Filtering nearby Points (5km radius)
  /// - Creating new Points at current location
  /// - Displaying user location on map
  ///
  /// [location]: Current device location with latitude/longitude
  const factory LocationServiceState.available({
    required LocationCoordinate location,
  }) = _Available;

  /// Location permission was denied by the user.
  ///
  /// The user either:
  /// - Denied the permission request dialog
  /// - Denied permission permanently (requires app settings)
  ///
  /// [message]: User-friendly explanation of the permission issue
  /// [isPermanent]: If true, user must enable in app settings
  const factory LocationServiceState.permissionDenied({
    required String message,
    @Default(false) bool isPermanent,
  }) = _PermissionDenied;

  /// Location services are disabled system-wide.
  ///
  /// The user has turned off location services in device settings.
  /// The app cannot access location until services are re-enabled.
  ///
  /// [message]: User-friendly explanation directing to settings
  const factory LocationServiceState.serviceDisabled({
    required String message,
  }) = _ServiceDisabled;

  /// An error occurred while fetching location.
  ///
  /// This covers various error scenarios:
  /// - Network timeout when using assisted GPS
  /// - No GPS signal (indoor, underground, etc.)
  /// - Device hardware issues
  /// - Unexpected system errors
  ///
  /// [message]: User-friendly error explanation
  const factory LocationServiceState.error({
    required String message,
  }) = _Error;
}
