/// Domain-layer exceptions for repository operations.
///
/// These exceptions represent business logic errors and data access failures
/// in a technology-agnostic way. Data layer implementations should catch
/// backend-specific errors and translate them into these domain exceptions.

/// Base exception for all repository operations.
///
/// All repository exceptions extend this base class to provide a consistent
/// error handling interface across the domain layer.
abstract class RepositoryException implements Exception {
  /// Human-readable error message describing what went wrong
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => message;
}

/// Thrown when authentication or authorization fails.
///
/// Examples:
/// - User attempts to create a Point with a different user_id than their authenticated ID
/// - User attempts to update/delete another user's Point
/// - User attempts to create a Like for another user
///
/// Maps to RLS policy violations at the database level.
class UnauthorizedException extends RepositoryException {
  UnauthorizedException(String message) : super(message);
}

/// Thrown when a requested resource is not found.
///
/// Examples:
/// - Fetching a Point by ID that doesn't exist
/// - Fetching a Profile that hasn't been created yet
/// - Attempting to unlike a Point that was never liked
///
/// Different from empty results (which return empty lists, not exceptions).
class NotFoundException extends RepositoryException {
  NotFoundException(String message) : super(message);
}

/// Thrown when input validation fails.
///
/// Examples:
/// - Point content exceeds 280 characters
/// - Username contains invalid characters
/// - LocationCoordinate has invalid lat/lon values
///
/// These should typically be caught before reaching the repository,
/// but repositories perform defensive validation as well.
class ValidationException extends RepositoryException {
  ValidationException(String message) : super(message);
}

/// Thrown when a database operation fails.
///
/// This is a catch-all for server-side errors that don't fit other categories.
/// Examples:
/// - Network connectivity issues
/// - Database timeout
/// - Unexpected server errors (500)
///
/// The optional [httpStatusCode] helps with debugging and error classification.
class DatabaseException extends RepositoryException {
  /// Optional HTTP status code from the backend (e.g., 500, 503)
  final int? httpStatusCode;

  DatabaseException(String message, {this.httpStatusCode}) : super(message);

  @override
  String toString() {
    if (httpStatusCode != null) {
      return '$message (HTTP $httpStatusCode)';
    }
    return message;
  }
}

/// Thrown when a username is not unique.
///
/// The `profile` table has a UNIQUE constraint on the username field.
/// This exception is thrown when:
/// - Creating a Profile with a username that already exists
/// - Updating a Profile to a username that already exists
class DuplicateUsernameException extends RepositoryException {
  DuplicateUsernameException(String username)
      : super('Username "$username" is already taken');
}

/// Thrown when user attempts to like a point they've already liked.
///
/// The `likes` table has a UNIQUE constraint on (point_id, user_id).
/// A user can only like a point once. If they attempt to like it again,
/// this exception is thrown.
///
/// To remove a like, use `unlikePoint()` instead.
class DuplicateLikeException extends RepositoryException {
  DuplicateLikeException(String pointId, String userId)
      : super('User $userId has already liked point $pointId');
}
