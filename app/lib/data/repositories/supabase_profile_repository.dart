import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/domain/entities/profile.dart';
import 'package:app/domain/repositories/i_profile_repository.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';

/// Supabase implementation of [IProfileRepository].
///
/// This repository handles all Profile CRUD operations via Supabase PostgREST API.
/// It enforces Row Level Security (RLS) policies at the database level and
/// provides defensive client-side checks for better error messages.
///
/// **RLS Policies for profile table:**
/// - SELECT: `auth.uid() IS NOT NULL` (any authenticated user can view profiles)
/// - INSERT: `auth.uid() = id` (users can only create their own profile)
/// - UPDATE: `auth.uid() = id` (users can only update their own profile)
/// - DELETE: `auth.uid() = id` (users can only delete their own profile)
///
/// **Unique Constraints:**
/// - username must be unique across all profiles (enforced by database)
class SupabaseProfileRepository implements IProfileRepository {
  final SupabaseClient _client;

  SupabaseProfileRepository(this._client);

  @override
  Future<Profile> createProfile({
    required String id,
    required String username,
    String? bio,
  }) async {
    try {
      // Defensive check: verify authenticated user matches id (mirrors RLS)
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw UnauthorizedException(
          'Authentication required to create a profile',
        );
      }
      if (currentUserId != id) {
        throw UnauthorizedException(
          'Cannot create profile for another user. '
          'Authenticated user: $currentUserId, Requested user: $id',
        );
      }

      // Validate username is not empty
      if (username.trim().isEmpty) {
        throw ValidationException('Username cannot be empty');
      }

      // Insert the profile
      final response = await _client
          .from('profile')
          .insert({
            'id': id,
            'username': username,
            if (bio != null) 'bio': bio,
          })
          .select()
          .single();

      return Profile.fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'createProfile', username: username);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to create profile: $e');
    }
  }

  @override
  Future<Profile> fetchProfileById(String userId) async {
    try {
      final response = await _client
          .from('profile')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        throw NotFoundException('Profile with id $userId not found');
      }

      return Profile.fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'fetchProfileById');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to fetch profile by id: $e');
    }
  }

  @override
  Future<Profile> fetchProfileByUsername(String username) async {
    try {
      final response = await _client
          .from('profile')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response == null) {
        throw NotFoundException('Profile with username "$username" not found');
      }

      return Profile.fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'fetchProfileByUsername');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to fetch profile by username: $e');
    }
  }

  @override
  Future<List<Profile>> fetchAllProfiles() async {
    try {
      final response = await _client
          .from('profile')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Profile.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'fetchAllProfiles');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to fetch all profiles: $e');
    }
  }

  @override
  Future<Profile> updateProfile({
    required String userId,
    String? username,
    String? bio,
  }) async {
    try {
      // Defensive check: verify authenticated user matches userId (mirrors RLS)
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw UnauthorizedException(
          'Authentication required to update a profile',
        );
      }
      if (currentUserId != userId) {
        throw UnauthorizedException(
          'Cannot update profile for another user. '
          'Authenticated user: $currentUserId, Requested user: $userId',
        );
      }

      // Build update map with only provided fields
      final updateData = <String, dynamic>{};
      if (username != null) {
        if (username.trim().isEmpty) {
          throw ValidationException('Username cannot be empty');
        }
        updateData['username'] = username;
      }
      if (bio != null) {
        updateData['bio'] = bio;
      }

      // If no fields to update, just fetch and return current profile
      if (updateData.isEmpty) {
        return fetchProfileById(userId);
      }

      // Update the profile
      final response = await _client
          .from('profile')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return Profile.fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(
        e,
        'updateProfile',
        username: username,
      );
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to update profile: $e');
    }
  }

  /// Maps PostgrestException to domain exceptions.
  ///
  /// PostgreSQL error codes: https://www.postgresql.org/docs/current/errcodes-appendix.html
  ///
  /// Common codes:
  /// - 42501: insufficient_privilege (RLS violation)
  /// - 23505: unique_violation (duplicate username)
  /// - 23503: foreign_key_violation
  /// - 23502: not_null_violation
  ///
  /// PostgREST codes:
  /// - PGRST116: Row not found
  RepositoryException _mapPostgrestException(
    PostgrestException e,
    String operation, {
    String? username,
  }) {
    final code = e.code;
    final message = e.message;

    // PostgreSQL error codes
    if (code == '42501') {
      return UnauthorizedException(
        'Insufficient privileges for $operation. This operation violates Row Level Security policies.',
      );
    }

    if (code == '23505') {
      // Unique constraint violation - likely duplicate username
      if (username != null) {
        return DuplicateUsernameException(username);
      }
      return ValidationException(
        'Unique constraint violation for $operation: $message',
      );
    }

    if (code == '23503') {
      return NotFoundException(
        'Related resource not found for $operation: $message',
      );
    }

    if (code == '23502') {
      return ValidationException(
        'Missing required field for $operation: $message',
      );
    }

    // PostgREST error codes
    if (code == 'PGRST116') {
      return NotFoundException('Profile not found for $operation');
    }

    // HTTP status code mapping
    if (e.statusCode != null) {
      if (e.statusCode == '401' || e.statusCode == '403') {
        return UnauthorizedException(
          'Authorization failed for $operation: $message',
        );
      }

      if (e.statusCode == '404') {
        return NotFoundException(
          'Resource not found for $operation: $message',
        );
      }

      if (e.statusCode == '422') {
        return ValidationException(
          'Validation failed for $operation: $message',
        );
      }
    }

    // Default to DatabaseException
    return DatabaseException(
      'Database error during $operation: $message (code: $code)',
      httpStatusCode: e.statusCode != null ? int.tryParse(e.statusCode!) : null,
    );
  }
}
