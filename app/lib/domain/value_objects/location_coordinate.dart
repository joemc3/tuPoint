/// Represents a geographic coordinate with latitude and longitude.
///
/// This is an immutable value object used throughout the domain layer
/// for geospatial calculations. Uses WGS84 coordinate system (SRID 4326).
class LocationCoordinate {
  /// Latitude in decimal degrees.
  /// Valid range: -90.0 (South Pole) to +90.0 (North Pole)
  final double latitude;

  /// Longitude in decimal degrees.
  /// Valid range: -180.0 to +180.0
  final double longitude;

  /// Creates a LocationCoordinate with validation.
  ///
  /// Throws [ArgumentError] if coordinates are out of valid ranges.
  const LocationCoordinate({
    required this.latitude,
    required this.longitude,
  })  : assert(
          latitude >= -90.0 && latitude <= 90.0,
          'Latitude must be between -90.0 and 90.0',
        ),
        assert(
          longitude >= -180.0 && longitude <= 180.0,
          'Longitude must be between -180.0 and 180.0',
        );

  /// Creates a LocationCoordinate with validation that throws on invalid input.
  ///
  /// Use this factory when you need explicit error handling for invalid coordinates.
  factory LocationCoordinate.validated({
    required double latitude,
    required double longitude,
  }) {
    if (latitude < -90.0 || latitude > 90.0) {
      throw ArgumentError(
        'Latitude must be between -90.0 and 90.0, got: $latitude',
      );
    }
    if (longitude < -180.0 || longitude > 180.0) {
      throw ArgumentError(
        'Longitude must be between -180.0 and 180.0, got: $longitude',
      );
    }
    return LocationCoordinate(latitude: latitude, longitude: longitude);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationCoordinate &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() =>
      'LocationCoordinate(lat: ${latitude.toStringAsFixed(6)}, lon: ${longitude.toStringAsFixed(6)})';
}
