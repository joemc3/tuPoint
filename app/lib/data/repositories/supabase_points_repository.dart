import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/domain/entities/point.dart';
import 'package:app/domain/repositories/i_points_repository.dart';
import 'package:app/domain/value_objects/location_coordinate.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';

/// Supabase implementation of [IPointsRepository].
///
/// This repository handles all Point CRUD operations via Supabase PostgREST API.
/// It enforces Row Level Security (RLS) policies at the database level and
/// provides defensive client-side checks for better error messages.
///
/// **RLS Policies for points table:**
/// - SELECT: `auth.uid() IS NOT NULL` (any authenticated user)
/// - INSERT: `auth.uid() = user_id` (users can only create their own points)
/// - UPDATE: `auth.uid() = user_id` (users can only update their own points)
/// - DELETE: No policy (intentionally blocked - use UPDATE is_active instead)
///
/// **PostGIS Geometry Handling:**
/// - INSERT/UPDATE: Converts LocationCoordinate to WKT format `SRID=4326;POINT(lon lat)`
/// - SELECT: Receives GeoJSON format `{"type": "Point", "coordinates": [lon, lat]}`
///   which is automatically converted by LocationCoordinateConverter
class SupabasePointsRepository implements IPointsRepository {
  final SupabaseClient _client;

  SupabasePointsRepository(this._client);

  @override
  Future<Point> createPoint({
    required String userId,
    required String content,
    required LocationCoordinate location,
    required String maidenhead6char,
  }) async {
    try {
      // Defensive check: verify authenticated user matches userId (mirrors RLS)
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw UnauthorizedException(
          'Authentication required to create a point',
        );
      }
      if (currentUserId != userId) {
        throw UnauthorizedException(
          'Cannot create point for another user. '
          'Authenticated user: $currentUserId, Requested user: $userId',
        );
      }

      // Validate content length (max 280 characters)
      if (content.length > 280) {
        throw ValidationException(
          'Point content must not exceed 280 characters (got ${content.length})',
        );
      }

      // Convert LocationCoordinate to PostGIS WKT format
      // PostGIS uses (longitude, latitude) order in WKT
      final geomWKT = 'SRID=4326;POINT(${location.longitude} ${location.latitude})';

      // Insert the point
      final response = await _client
          .from('points')
          .insert({
            'user_id': userId,
            'content': content,
            'geom': geomWKT,
            'maidenhead_6char': maidenhead6char,
            // is_active defaults to true in database
          })
          .select()
          .single();

      return Point.fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'createPoint');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to create point: $e');
    }
  }

  @override
  Future<List<Point>> fetchAllActivePoints() async {
    try {
      final response = await _client
          .from('points')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Point.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'fetchAllActivePoints');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to fetch active points: $e');
    }
  }

  @override
  Future<Point> fetchPointById(String pointId) async {
    try {
      final response = await _client
          .from('points')
          .select()
          .eq('id', pointId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        throw NotFoundException(
          'Point with id $pointId not found or is inactive',
        );
      }

      return Point.fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'fetchPointById');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to fetch point by id: $e');
    }
  }

  @override
  Future<List<Point>> fetchPointsByUserId(String userId) async {
    try {
      final response = await _client
          .from('points')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Point.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'fetchPointsByUserId');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to fetch points by user id: $e');
    }
  }

  @override
  Future<void> deactivatePoint({
    required String pointId,
    required String userId,
  }) async {
    try {
      // Defensive check: verify authenticated user matches userId (mirrors RLS)
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw UnauthorizedException(
          'Authentication required to deactivate a point',
        );
      }
      if (currentUserId != userId) {
        throw UnauthorizedException(
          'Cannot deactivate point owned by another user. '
          'Authenticated user: $currentUserId, Point owner: $userId',
        );
      }

      // First verify the point exists and is owned by the user
      // Note: We need to select ALL columns to bypass the RLS SELECT filter
      // that only returns is_active = true
      final existing = await _client
          .from('points')
          .select('user_id, is_active')
          .eq('id', pointId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing == null) {
        throw NotFoundException('Point with id $pointId not found');
      }

      if (existing['user_id'] != userId) {
        throw UnauthorizedException(
          'Cannot deactivate point owned by another user',
        );
      }

      // Update is_active to false (soft delete)
      // Note: We cannot use .select() after the update because the RLS SELECT policy
      // only allows viewing active points (is_active = true), so the updated row
      // would be filtered out immediately after being set to inactive.
      await _client
          .from('points')
          .update({'is_active': false})
          .eq('id', pointId)
          .eq('user_id', userId); // RLS will enforce this anyway
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'deactivatePoint');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to deactivate point: $e');
    }
  }

  @override
  Future<Point> updatePointContent({
    required String pointId,
    required String userId,
    required String content,
  }) async {
    try {
      // Defensive check: verify authenticated user matches userId (mirrors RLS)
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw UnauthorizedException(
          'Authentication required to update a point',
        );
      }
      if (currentUserId != userId) {
        throw UnauthorizedException(
          'Cannot update point owned by another user. '
          'Authenticated user: $currentUserId, Point owner: $userId',
        );
      }

      // Validate content length (max 280 characters)
      if (content.length > 280) {
        throw ValidationException(
          'Point content must not exceed 280 characters (got ${content.length})',
        );
      }

      // First verify the point exists and is owned by the user
      final existing = await _client
          .from('points')
          .select('user_id')
          .eq('id', pointId)
          .maybeSingle();

      if (existing == null) {
        throw NotFoundException('Point with id $pointId not found');
      }

      if (existing['user_id'] != userId) {
        throw UnauthorizedException(
          'Cannot update point owned by another user',
        );
      }

      // Update the content
      final response = await _client
          .from('points')
          .update({'content': content})
          .eq('id', pointId)
          .eq('user_id', userId) // RLS will enforce this anyway
          .select()
          .single();

      return Point.fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e, 'updatePointContent');
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DatabaseException('Failed to update point content: $e');
    }
  }

  /// Maps PostgrestException to domain exceptions.
  ///
  /// PostgreSQL error codes: https://www.postgresql.org/docs/current/errcodes-appendix.html
  ///
  /// Common codes:
  /// - 42501: insufficient_privilege (RLS violation)
  /// - 23505: unique_violation
  /// - 23503: foreign_key_violation
  /// - 23502: not_null_violation
  ///
  /// PostgREST codes:
  /// - PGRST116: Row not found
  RepositoryException _mapPostgrestException(
    PostgrestException e,
    String operation,
  ) {
    final code = e.code;
    final message = e.message;

    // PostgreSQL error codes
    if (code == '42501') {
      return UnauthorizedException(
        'Insufficient privileges for $operation. This operation violates Row Level Security policies.',
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
      return NotFoundException(
        'Point not found for $operation',
      );
    }

    // Default to DatabaseException
    return DatabaseException(
      'Database error during $operation: $message (code: $code)',
    );
  }
}
