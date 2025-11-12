import 'package:app/domain/entities/point.dart';
import 'package:app/domain/value_objects/location_coordinate.dart';

/// Repository interface for Point domain entity operations.
///
/// This interface defines contracts for CRUD operations on Points.
/// All operations respect Row Level Security (RLS) policies enforced
/// at the database level:
/// - INSERT: User can only create points with their own user_id
/// - SELECT: Returns only active points (is_active = true)
/// - UPDATE/DELETE: User can only modify their own points
///
/// Maps to the `points` table in the database schema.
///
/// **Implementation Notes:**
/// - All methods are asynchronous (return Future)
/// - Exceptions are thrown for error cases (no null returns)
/// - Empty results return empty lists (not exceptions)
/// - LocationCoordinate ensures coordinates are always valid (WGS84 SRID 4326)
abstract class IPointsRepository {
  /// Creates a new Point at the user's location.
  ///
  /// [userId] - ID of the authenticated user (must match auth.uid())
  /// [content] - Text content (max 280 characters)
  /// [location] - Geographic coordinates (WGS84 SRID 4326)
  /// [maidenhead6char] - 6-character Maidenhead grid locator
  ///
  /// Returns the created Point with server-generated id and created_at.
  ///
  /// Throws [UnauthorizedException] if userId doesn't match authenticated user.
  /// Throws [ValidationException] if content exceeds 280 characters.
  /// Throws [DatabaseException] for server-side errors.
  Future<Point> createPoint({
    required String userId,
    required String content,
    required LocationCoordinate location,
    required String maidenhead6char,
  });

  /// Fetches all active points from the database.
  ///
  /// Returns a list of all Points where is_active = true.
  /// The list is unfiltered - client-side filtering by distance
  /// should be applied after retrieval using HaversineCalculator.
  ///
  /// Returns empty list if no active points exist.
  /// Throws [DatabaseException] for server-side errors.
  Future<List<Point>> fetchAllActivePoints();

  /// Fetches a specific point by ID.
  ///
  /// [pointId] - The UUID of the point to fetch
  ///
  /// Returns the Point if found and is_active = true.
  /// Throws [NotFoundException] if point doesn't exist or is inactive.
  /// Throws [DatabaseException] for server-side errors.
  Future<Point> fetchPointById(String pointId);

  /// Fetches all active points created by a specific user.
  ///
  /// [userId] - The UUID of the user whose points to fetch
  ///
  /// Returns list of Points created by the user where is_active = true.
  /// Returns empty list if user has no active points.
  /// Throws [DatabaseException] for server-side errors.
  Future<List<Point>> fetchPointsByUserId(String userId);

  /// Soft-deletes a point (marks as inactive).
  ///
  /// [pointId] - The UUID of the point to deactivate
  /// [userId] - ID of the authenticated user (must own the point)
  ///
  /// Updates the point's is_active flag to false.
  /// Throws [UnauthorizedException] if user doesn't own the point.
  /// Throws [NotFoundException] if point doesn't exist.
  /// Throws [DatabaseException] for server-side errors.
  Future<void> deactivatePoint({
    required String pointId,
    required String userId,
  });

  /// Updates a point's content (user can only update their own).
  ///
  /// [pointId] - The UUID of the point to update
  /// [userId] - ID of the authenticated user (must own the point)
  /// [content] - New text content (max 280 characters)
  ///
  /// Returns the updated Point.
  /// Throws [UnauthorizedException] if user doesn't own the point.
  /// Throws [ValidationException] if content exceeds 280 characters.
  /// Throws [NotFoundException] if point doesn't exist.
  /// Throws [DatabaseException] for server-side errors.
  Future<Point> updatePointContent({
    required String pointId,
    required String userId,
    required String content,
  });
}
