import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/domain/entities/like.dart';
import 'package:app/domain/repositories/i_likes_repository.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';

/// Supabase implementation of [ILikesRepository].
///
/// This repository handles all Like CRUD operations via Supabase PostgREST API.
/// It enforces Row Level Security (RLS) policies at the database level and
/// provides defensive client-side checks for better error messages.
///
/// **RLS Policies for likes table:**
/// - SELECT: `auth.uid() IS NOT NULL` (any authenticated user)
/// - INSERT: `auth.uid() = user_id` (users can only like as themselves)
/// - UPDATE: No policy (likes are immutable)
/// - DELETE: `auth.uid() = user_id` (users can only unlike their own likes)
///
/// **Unique Constraints:**
/// - (point_id, user_id) must be unique - a user can only like a point once
class SupabaseLikesRepository implements ILikesRepository {
  final SupabaseClient _client;

  SupabaseLikesRepository(this._client);

  @override
  Future<Like> likePoint({
    required String pointId,
    required String userId,
  }) async {
    try {
      // Defensive check: verify authenticated user matches userId (mirrors RLS)
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw UnauthorizedException(
          'Authentication required to like a point',
        );
      }
      if (currentUserId != userId) {
        throw UnauthorizedException(
          'Cannot like point as another user. '
          'Authenticated user: $currentUserId, Requested user: $userId',
        );
      }

      // Verify the point exists before attempting to like
      final pointExists = await _client
          .from('points')
          .select('id')
          .eq('id', pointId)
          .maybeSingle();

      if (pointExists == null) {
        throw NotFoundException('Point with id $pointId not found');
      }

      // Insert the like
      final response = await _client
          .from('likes')
          .insert({
            'point_id': pointId,
            'user_id': userId,
          })
          .select()
          .single();

      return Like.fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(
        e,
        'likePoint',
        pointId: pointId,
        userId: userId,
      );
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to like point: $e');
    }
  }

  @override
  Future<void> unlikePoint({
    required String pointId,
    required String userId,
  }) async {
    try {
      // Defensive check: verify authenticated user matches userId (mirrors RLS)
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw UnauthorizedException(
          'Authentication required to unlike a point',
        );
      }
      if (currentUserId != userId) {
        throw UnauthorizedException(
          'Cannot unlike point as another user. '
          'Authenticated user: $currentUserId, Requested user: $userId',
        );
      }

      // Delete the like (silently succeeds if like doesn't exist)
      // RLS policy ensures user can only delete their own likes
      await _client
          .from('likes')
          .delete()
          .eq('point_id', pointId)
          .eq('user_id', userId);

      // Note: Supabase delete() doesn't throw if no rows match,
      // which is the desired behavior per requirements
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'unlikePoint');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to unlike point: $e');
    }
  }

  @override
  Future<bool> hasUserLikedPoint({
    required String pointId,
    required String userId,
  }) async {
    try {
      final response = await _client
          .from('likes')
          .select('point_id')
          .eq('point_id', pointId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'hasUserLikedPoint');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to check if user liked point: $e');
    }
  }

  @override
  Future<List<Like>> fetchLikesForPoint(String pointId) async {
    try {
      // First verify the point exists
      final pointExists = await _client
          .from('points')
          .select('id')
          .eq('id', pointId)
          .maybeSingle();

      if (pointExists == null) {
        throw NotFoundException('Point with id $pointId not found');
      }

      final response = await _client
          .from('likes')
          .select()
          .eq('point_id', pointId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Like.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'fetchLikesForPoint');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to fetch likes for point: $e');
    }
  }

  @override
  Future<int> getLikeCountForPoint(String pointId) async {
    try {
      // First verify the point exists
      final pointExists = await _client
          .from('points')
          .select('id')
          .eq('id', pointId)
          .maybeSingle();

      if (pointExists == null) {
        throw NotFoundException('Point with id $pointId not found');
      }

      // Use count to get the number of likes
      final response = await _client
          .from('likes')
          .select('point_id', const FetchOptions(count: CountOption.exact))
          .eq('point_id', pointId);

      // The count is available in the count property of the response
      // For supabase_flutter, we need to use the count from PostgrestResponse
      // Since we're selecting data, we get a list, so we count the list length
      return (response as List).length;
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'getLikeCountForPoint');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to get like count for point: $e');
    }
  }

  @override
  Future<List<Like>> fetchLikesByUserId(String userId) async {
    try {
      final response = await _client
          .from('likes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Like.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'fetchLikesByUserId');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to fetch likes by user id: $e');
    }
  }

  /// Maps PostgrestException to domain exceptions.
  ///
  /// PostgreSQL error codes: https://www.postgresql.org/docs/current/errcodes-appendix.html
  ///
  /// Common codes:
  /// - 42501: insufficient_privilege (RLS violation)
  /// - 23505: unique_violation (duplicate like)
  /// - 23503: foreign_key_violation (point doesn't exist)
  /// - 23502: not_null_violation
  ///
  /// PostgREST codes:
  /// - PGRST116: Row not found
  RepositoryException _mapPostgrestException(
    PostgrestException e,
    String operation, {
    String? pointId,
    String? userId,
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
      // Unique constraint violation - duplicate like
      if (pointId != null && userId != null) {
        return DuplicateLikeException(pointId, userId);
      }
      return ValidationException(
        'Unique constraint violation for $operation: $message',
      );
    }

    if (code == '23503') {
      // Foreign key violation - point doesn't exist
      return NotFoundException(
        'Point not found for $operation: $message',
      );
    }

    if (code == '23502') {
      return ValidationException(
        'Missing required field for $operation: $message',
      );
    }

    // PostgREST error codes
    if (code == 'PGRST116') {
      return NotFoundException('Like not found for $operation');
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
