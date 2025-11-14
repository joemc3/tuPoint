import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app/domain/entities/point.dart';
import 'package:app/domain/value_objects/location_coordinate.dart';

part 'feed_state.freezed.dart';

/// Represents the state of the nearby points feed in the application.
///
/// This is a union type that can be in one of four states:
/// - [Initial]: No feed loaded yet (app startup)
/// - [Loading]: Feed is being fetched from database
/// - [Loaded]: Feed successfully loaded with points and user location
/// - [Error]: Feed loading failed
///
/// The loaded state includes both the points list and the user's current
/// location, enabling the UI to calculate and display distance to each point.
///
/// This state is managed by [FeedNotifier] and exposed via Riverpod providers.
@freezed
class FeedState with _$FeedState {
  /// No feed loaded yet.
  ///
  /// This is the initial state before any feed operations have been
  /// performed. The UI should typically show a placeholder, empty state,
  /// or prompt the user to enable location services.
  const factory FeedState.initial() = _Initial;

  /// Feed is being fetched.
  ///
  /// This state is shown during:
  /// - Initial feed load
  /// - Location-based refresh operations
  /// - Manual refresh operations
  ///
  /// The UI should display a loading indicator while in this state.
  const factory FeedState.loading() = _Loading;

  /// Feed was successfully loaded.
  ///
  /// The [points] contains the list of nearby Points within the specified
  /// radius (default 5km for MVP), sorted by distance (nearest first).
  ///
  /// The [userLocation] is included so the UI can:
  /// - Display distance to each Point
  /// - Show user's location on a map
  /// - Enable location-aware features
  ///
  /// This is the success state where the UI can display the feed and
  /// allow user interactions (like, navigate to point creation, etc.).
  ///
  /// Note: An empty points list is valid - it means no Points exist
  /// within the radius.
  const factory FeedState.loaded({
    required List<Point> points,
    required LocationCoordinate userLocation,
  }) = _Loaded;

  /// Feed loading failed.
  ///
  /// The [message] provides a user-friendly error description that can
  /// be displayed in the UI. Common errors include:
  /// - Location permission denied
  /// - Location services disabled
  /// - Network errors
  /// - Database errors
  /// - GPS timeout or no signal
  const factory FeedState.error({
    required String message,
  }) = _Error;
}
