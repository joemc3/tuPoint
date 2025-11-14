import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app/domain/entities/point.dart';

part 'point_drop_state.freezed.dart';

/// Represents the state of point creation operations in the application.
///
/// This is a union type that can be in one of five states:
/// - [Initial]: No point drop operation has been performed yet
/// - [FetchingLocation]: GPS location is being fetched from the device
/// - [Dropping]: Point is being created in the database
/// - [Success]: Point was successfully created
/// - [Error]: Point creation failed at any stage
///
/// Point creation is a two-phase operation:
/// 1. Fetch GPS coordinates from LocationService
/// 2. Create Point in database via DropPointUseCase
///
/// This state is managed by [PointDropNotifier] and exposed via Riverpod providers.
@freezed
class PointDropState with _$PointDropState {
  /// No point drop operation has been performed yet.
  ///
  /// This is the initial state before any point creation attempts.
  /// The UI should display the point creation form ready for input.
  const factory PointDropState.initial() = _Initial;

  /// GPS location is being fetched from the device.
  ///
  /// This is the first phase of point creation where the LocationService
  /// is retrieving the current device coordinates. This phase typically
  /// takes 1-15 seconds depending on GPS signal strength.
  ///
  /// The UI should display a loading indicator with location-specific
  /// messaging like "Getting your location..." to distinguish from the
  /// database creation phase.
  const factory PointDropState.fetchingLocation() = _FetchingLocation;

  /// Point is being created in the database.
  ///
  /// This is the second phase of point creation where the DropPointUseCase
  /// is sending the Point data to Supabase. This phase typically takes
  /// less than 1 second with a network connection.
  ///
  /// The UI should display a loading indicator with database-specific
  /// messaging like "Creating point..." or "Dropping point..." to
  /// distinguish from the location fetch phase.
  const factory PointDropState.dropping() = _Dropping;

  /// Point was successfully created.
  ///
  /// The [point] contains the complete Point data including the server-
  /// generated ID and timestamp. The UI should display success feedback
  /// and typically navigate back to the main feed or clear the form.
  ///
  /// This is a terminal state. To create another point, call reset()
  /// to return to the initial state.
  const factory PointDropState.success({
    required Point point,
  }) = _Success;

  /// Point creation failed at any stage.
  ///
  /// The [message] provides a user-friendly error description that can
  /// be displayed in the UI. Errors can occur during:
  /// - Content validation (empty, too long)
  /// - Location fetching (permission denied, service disabled, timeout)
  /// - Database creation (network error, authorization error)
  ///
  /// This is a terminal state. To retry, call dropPoint() again or
  /// reset() to clear the error and return to initial state.
  const factory PointDropState.error({
    required String message,
  }) = _Error;
}
