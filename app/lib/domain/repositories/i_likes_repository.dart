import 'package:app/domain/entities/like.dart';

/// Repository interface for Like domain entity operations.
///
/// This interface defines contracts for operations on user likes/reactions.
/// All operations respect Row Level Security (RLS) policies:
/// - INSERT: User can only record their own like (user_id must match auth.uid())
/// - SELECT: All authenticated users can read any like
/// - DELETE: User can only delete their own like
///
/// The (point_id, user_id) combination forms a unique constraint -
/// a user can only like a point once.
///
/// Maps to the `likes` table in the database schema.
///
/// **Implementation Notes:**
/// - All methods are asynchronous (return Future)
/// - Exceptions are thrown for error cases (no null returns)
/// - Empty results return empty lists (not exceptions)
/// - Duplicate likes throw DuplicateLikeException (use unlikePoint to remove)
abstract class ILikesRepository {
  /// Records a user's like on a point.
  ///
  /// [pointId] - The UUID of the point being liked
  /// [userId] - ID of the authenticated user (must match auth.uid())
  ///
  /// Returns the created Like with server-generated created_at timestamp.
  /// Throws [UnauthorizedException] if userId doesn't match authenticated user.
  /// Throws [DuplicateLikeException] if user has already liked this point.
  /// Throws [NotFoundException] if the point doesn't exist.
  /// Throws [DatabaseException] for server-side errors.
  Future<Like> likePoint({
    required String pointId,
    required String userId,
  });

  /// Removes a user's like from a point (un-like).
  ///
  /// [pointId] - The UUID of the point to unlike
  /// [userId] - ID of the authenticated user (must own the like)
  ///
  /// Throws [UnauthorizedException] if user didn't create this like.
  /// Throws [NotFoundException] if the like doesn't exist.
  /// Throws [DatabaseException] for server-side errors.
  Future<void> unlikePoint({
    required String pointId,
    required String userId,
  });

  /// Checks if a user has liked a specific point.
  ///
  /// [pointId] - The UUID of the point to check
  /// [userId] - The UUID of the user to check
  ///
  /// Returns true if the user has liked the point, false otherwise.
  /// Throws [DatabaseException] for server-side errors.
  Future<bool> hasUserLikedPoint({
    required String pointId,
    required String userId,
  });

  /// Fetches all likes for a specific point.
  ///
  /// [pointId] - The UUID of the point
  ///
  /// Returns list of all Like records for that point.
  /// Returns empty list if the point has no likes.
  /// Throws [NotFoundException] if the point doesn't exist.
  /// Throws [DatabaseException] for server-side errors.
  Future<List<Like>> fetchLikesForPoint(String pointId);

  /// Fetches the like count for a specific point.
  ///
  /// [pointId] - The UUID of the point
  ///
  /// Returns the number of likes on the point (0 if none).
  /// Throws [NotFoundException] if the point doesn't exist.
  /// Throws [DatabaseException] for server-side errors.
  Future<int> getLikeCountForPoint(String pointId);

  /// Fetches all likes created by a specific user.
  ///
  /// [userId] - The UUID of the user
  ///
  /// Returns list of all Like records created by the user.
  /// Returns empty list if user has no likes.
  /// Throws [DatabaseException] for server-side errors.
  Future<List<Like>> fetchLikesByUserId(String userId);
}
