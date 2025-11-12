import 'package:app/domain/value_objects/location_coordinate.dart';

/// Request DTOs for domain use cases.
///
/// These classes encapsulate input parameters for use cases,
/// providing type safety and clear contracts.

/// Request to create a new user profile.
class CreateProfileRequest {
  /// User ID from auth.users (must match authenticated user)
  final String userId;

  /// Unique username (3-32 chars, alphanumeric + underscore/dash)
  final String username;

  /// Optional biography/description (max 280 chars)
  final String? bio;

  CreateProfileRequest({
    required this.userId,
    required this.username,
    this.bio,
  });
}

/// Request to fetch a user's profile.
class FetchProfileRequest {
  /// User ID to fetch profile for
  final String userId;

  FetchProfileRequest({required this.userId});
}

/// Request to create a new Point.
class DropPointRequest {
  /// User ID of the authenticated user
  final String userId;

  /// Text content (1-280 characters)
  final String content;

  /// Location coordinates (WGS84)
  final LocationCoordinate location;

  /// 6-character Maidenhead grid locator
  final String maidenhead6char;

  DropPointRequest({
    required this.userId,
    required this.content,
    required this.location,
    required this.maidenhead6char,
  });
}

/// Request to fetch nearby points within a radius.
class FetchNearbyPointsRequest {
  /// User's current location
  final LocationCoordinate userLocation;

  /// Radius in meters (default 5000m = 5km for MVP)
  final double radiusMeters;

  /// Whether to include the user's own points (default false)
  final bool includeUserOwnPoints;

  /// Optional: User ID to filter out user's own points
  final String? userId;

  FetchNearbyPointsRequest({
    required this.userLocation,
    this.radiusMeters = 5000.0, // 5km default
    this.includeUserOwnPoints = false,
    this.userId,
  });
}

/// Request to fetch points created by a specific user.
class FetchUserPointsRequest {
  /// User ID whose points to fetch
  final String userId;

  FetchUserPointsRequest({required this.userId});
}

/// Request to like a point.
class LikePointRequest {
  /// Point ID to like
  final String pointId;

  /// User ID performing the like
  final String userId;

  LikePointRequest({
    required this.pointId,
    required this.userId,
  });
}

/// Request to unlike a point.
class UnlikePointRequest {
  /// Point ID to unlike
  final String pointId;

  /// User ID performing the unlike
  final String userId;

  UnlikePointRequest({
    required this.pointId,
    required this.userId,
  });
}

/// Request to get like count for a point.
class GetLikeCountRequest {
  /// Point ID to get like count for
  final String pointId;

  GetLikeCountRequest({required this.pointId});
}
