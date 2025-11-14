import 'package:freezed_annotation/freezed_annotation.dart';

part 'like_state.freezed.dart';

/// Represents the state of like operations across multiple points.
///
/// Unlike other state models in the app that use union types (loading/loaded/error),
/// this is a data class because we need to track state for multiple points simultaneously.
/// Each point has its own:
/// - Like status (whether current user has liked it)
/// - Like count (total number of likes)
/// - Loading state (during toggle operation)
/// - Error state (if operation failed)
///
/// This design enables:
/// - Independent state management per point
/// - Optimistic UI updates with rollback on error
/// - Concurrent like operations on different points
/// - Per-point error handling
///
/// Example usage:
/// ```dart
/// // Check if user liked a point
/// final isLiked = state.likedByUser[pointId] ?? false;
///
/// // Get like count for a point
/// final count = state.likeCounts[pointId] ?? 0;
///
/// // Check if toggle is in progress
/// final isLoading = state.loadingStates[pointId] ?? false;
///
/// // Get error message if any
/// final error = state.errors[pointId];
/// ```
@freezed
class LikeState with _$LikeState {
  /// Creates a LikeState instance.
  ///
  /// All fields default to empty maps, which means no points have been
  /// initialized yet. Points are added to these maps as their like state
  /// is fetched or modified.
  ///
  /// Fields:
  /// - [likedByUser]: Map of pointId -> whether current user has liked that point
  /// - [likeCounts]: Map of pointId -> like count for that point
  /// - [loadingStates]: Map of pointId -> loading state during toggle
  /// - [errors]: Map of pointId -> error message if operation failed
  const factory LikeState({
    /// Map of point IDs to whether the current user has liked that point.
    ///
    /// - `true`: User has liked the point
    /// - `false`: User has not liked the point
    /// - Missing key: Like status not yet fetched
    ///
    /// This map is updated optimistically during toggle operations and
    /// rolled back if the server operation fails.
    @Default({}) Map<String, bool> likedByUser,

    /// Map of point IDs to the total number of likes for that point.
    ///
    /// - `n > 0`: Point has n likes
    /// - `0`: Point has no likes
    /// - Missing key: Like count not yet fetched
    ///
    /// This map is updated optimistically during toggle operations and
    /// rolled back if the server operation fails.
    @Default({}) Map<String, int> likeCounts,

    /// Map of point IDs to loading state during toggle operations.
    ///
    /// - `true`: Toggle operation in progress (disable button)
    /// - `false`: No operation in progress (enable button)
    /// - Missing key: Defaults to false (not loading)
    ///
    /// This is used to disable like buttons during toggle operations
    /// to prevent duplicate requests.
    @Default({}) Map<String, bool> loadingStates,

    /// Map of point IDs to error messages if operations failed.
    ///
    /// - `null`: No error
    /// - Non-null string: Error message to display
    /// - Missing key: Defaults to null (no error)
    ///
    /// Errors are point-specific and are cleared when a new toggle
    /// operation is initiated for that point.
    @Default({}) Map<String, String?> errors,
  }) = _LikeState;
}
