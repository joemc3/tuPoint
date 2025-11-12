import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app/domain/value_objects/location_coordinate.dart';

part 'point.freezed.dart';
part 'point.g.dart';

/// Represents a location-based post (Point) in the tuPoint application.
///
/// A Point is ephemeral content tied to a specific geographic location.
/// It contains user-generated content, location data (both precise coordinates
/// and a Maidenhead grid locator), and an active status flag.
///
/// Maps to the `points` table in the database schema.
@freezed
class Point with _$Point {
  /// Creates a Point instance.
  ///
  /// [id] - Unique identifier for the Point (UUID)
  /// [userId] - ID of the user who created this Point
  /// [content] - Text content (max 280 characters)
  /// [location] - Geographic coordinates using WGS84 (SRID 4326)
  /// [maidenhead6char] - 6-character Maidenhead grid locator (~800m precision)
  /// [isActive] - Whether the Point is currently active (soft delete flag)
  /// [createdAt] - Timestamp when the Point was created
  const factory Point({
    /// Unique identifier for the Point (UUID). Primary Key.
    required String id,

    /// ID of the user who created this Point (Foreign Key to auth.users.id)
    @JsonKey(name: 'user_id') required String userId,

    /// Text content of the Point (max 280 characters)
    required String content,

    /// Geographic location using LocationCoordinate value object.
    /// Serialized to/from PostGIS geometry format.
    @JsonKey(name: 'geom')
    @LocationCoordinateConverter()
    required LocationCoordinate location,

    /// 6-character Maidenhead grid locator (e.g., "FN42aa")
    /// Provides ~800m precision for generalized location display.
    @JsonKey(name: 'maidenhead_6char') required String maidenhead6char,

    /// Whether the Point is currently active. Used for soft-delete.
    @JsonKey(name: 'is_active') required bool isActive,

    /// Timestamp when the Point was created
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Point;

  /// Creates a Point instance from JSON data.
  ///
  /// Maps snake_case JSON keys from the database to camelCase Dart fields.
  /// Converts PostGIS geometry format to LocationCoordinate.
  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);
}

/// Custom JSON converter for LocationCoordinate to/from PostGIS geometry format.
///
/// PostGIS stores points as GeoJSON-like structures:
/// ```json
/// {
///   "type": "Point",
///   "coordinates": [longitude, latitude]
/// }
/// ```
///
/// This converter handles the transformation between that format and
/// the LocationCoordinate value object.
class LocationCoordinateConverter
    implements JsonConverter<LocationCoordinate, Map<String, dynamic>> {
  const LocationCoordinateConverter();

  @override
  LocationCoordinate fromJson(Map<String, dynamic> json) {
    // PostGIS geometry format: {"type": "Point", "coordinates": [lon, lat]}
    final coordinates = json['coordinates'] as List<dynamic>;
    final longitude = (coordinates[0] as num).toDouble();
    final latitude = (coordinates[1] as num).toDouble();

    return LocationCoordinate(
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Map<String, dynamic> toJson(LocationCoordinate coordinate) {
    // Convert back to PostGIS geometry format
    return {
      'type': 'Point',
      'coordinates': [coordinate.longitude, coordinate.latitude],
    };
  }
}
