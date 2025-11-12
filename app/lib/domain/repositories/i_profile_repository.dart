import 'package:app/domain/entities/profile.dart';

/// Repository interface for Profile domain entity operations.
///
/// This interface defines contracts for CRUD operations on user profiles.
/// All operations respect Row Level Security (RLS) policies:
/// - INSERT: User can only create their own profile (id must match auth.uid())
/// - SELECT: All authenticated users can read any profile
/// - UPDATE: User can only update their own profile
///
/// Maps to the `profile` table in the database schema.
///
/// **Implementation Notes:**
/// - All methods are asynchronous (return Future)
/// - Exceptions are thrown for error cases (no null returns)
/// - Empty results return empty lists (not exceptions)
/// - Username must be unique across all profiles (enforced by database constraint)
abstract class IProfileRepository {
  /// Creates a new user profile.
  ///
  /// [id] - User ID from auth.users (must match authenticated user's ID)
  /// [username] - Unique username (will be validated by database constraint)
  /// [bio] - Optional biography/description
  ///
  /// Returns the created Profile with server-generated timestamps.
  /// Throws [UnauthorizedException] if id doesn't match authenticated user.
  /// Throws [DuplicateUsernameException] if username already exists.
  /// Throws [ValidationException] if username or bio are invalid.
  /// Throws [DatabaseException] for server-side errors.
  Future<Profile> createProfile({
    required String id,
    required String username,
    String? bio,
  });

  /// Fetches a user profile by ID.
  ///
  /// [userId] - The UUID of the user whose profile to fetch
  ///
  /// Returns the Profile if found.
  /// Throws [NotFoundException] if profile doesn't exist.
  /// Throws [DatabaseException] for server-side errors.
  Future<Profile> fetchProfileById(String userId);

  /// Fetches a user profile by username.
  ///
  /// [username] - The unique username to search for
  ///
  /// Returns the Profile if found.
  /// Throws [NotFoundException] if no profile with that username exists.
  /// Throws [DatabaseException] for server-side errors.
  Future<Profile> fetchProfileByUsername(String username);

  /// Fetches all user profiles.
  ///
  /// Returns a list of all profiles.
  /// Returns empty list if no profiles exist.
  /// Throws [DatabaseException] for server-side errors.
  ///
  /// **Note:** In production, this might need pagination for performance.
  Future<List<Profile>> fetchAllProfiles();

  /// Updates a user's profile (user can only update their own).
  ///
  /// [userId] - ID of the authenticated user (must own the profile)
  /// [username] - New username (if changing; will be validated for uniqueness)
  /// [bio] - New bio (optional)
  ///
  /// Returns the updated Profile with new updated_at timestamp.
  /// Throws [UnauthorizedException] if user doesn't own the profile.
  /// Throws [DuplicateUsernameException] if new username already exists.
  /// Throws [ValidationException] if inputs are invalid.
  /// Throws [NotFoundException] if profile doesn't exist.
  /// Throws [DatabaseException] for server-side errors.
  Future<Profile> updateProfile({
    required String userId,
    String? username,
    String? bio,
  });
}
