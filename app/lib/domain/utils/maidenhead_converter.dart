import 'dart:math' as math;
import '../value_objects/location_coordinate.dart';

/// Converts geographic coordinates to Maidenhead Grid Locator System format.
///
/// The Maidenhead Locator System is a concise method of expressing geographic
/// coordinates, originally developed for amateur radio operators. It divides
/// the world into nested grids of decreasing size.
///
/// ## Grid Structure:
/// - **Field (2 letters)**: 20° longitude × 10° latitude (18×18 fields worldwide)
/// - **Square (2 digits)**: 2° longitude × 1° latitude (10×10 squares per field)
/// - **Subsquare (2 lowercase letters)**: 5' longitude × 2.5' latitude (24×24 subsquares per square)
///
/// ## Precision:
/// A 6-character grid locator (e.g., "FN42li") defines a subsquare of 5' longitude
/// × 2.5' latitude, which equates to approximately:
/// - **Width**: 3-9 km depending on latitude (narrows toward poles)
/// - **Height**: ~4.6 km (relatively constant)
/// - **Maximum diagonal**: ~12 km between two points in same subsquare
///
/// This provides neighborhood-level precision suitable for tuPoint's requirement
/// to display approximate location without revealing exact coordinates.
///
/// ## Coordinate System:
/// - Uses WGS84 (SRID 4326) decimal degrees
/// - Longitude range: -180° to +180°
/// - Latitude range: -90° to +90°
///
/// ## Example:
/// ```dart
/// final coord = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
/// final grid = MaidenheadConverter.toMaidenhead6Char(coord);
/// print(grid); // Output: "FN42li"
/// ```
///
/// ## References:
/// - Original specification by Dr. John Morris, G4ANB (1980)
/// - IARU Region 1 VHF Manager's Handbook
class MaidenheadConverter {
  MaidenheadConverter._(); // Private constructor - utility class should not be instantiated

  /// Converts a geographic coordinate to a 6-character Maidenhead grid locator.
  ///
  /// The output format is always 6 characters: AAnnaa
  /// - AA: Field (2 uppercase letters)
  /// - nn: Square (2 digits)
  /// - aa: Subsquare (2 lowercase letters)
  ///
  /// ## Algorithm:
  /// 1. Normalize coordinates to positive values (longitude +180, latitude +90)
  /// 2. Calculate field: divide by 20° (lon) and 10° (lat), convert to letters A-R
  /// 3. Calculate square: divide remainder by 2° (lon) and 1° (lat), convert to digits 0-9
  /// 4. Calculate subsquare: divide remainder by 5' (lon) and 2.5' (lat), convert to letters a-x
  ///
  /// ## Parameters:
  /// - [coord]: A valid LocationCoordinate with latitude [-90, 90] and longitude [-180, 180]
  ///
  /// ## Returns:
  /// A 6-character string representing the Maidenhead grid locator (e.g., "FN31pr")
  ///
  /// ## Example:
  /// ```dart
  /// // Boston, MA
  /// final boston = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
  /// print(MaidenheadConverter.toMaidenhead6Char(boston)); // "FN42li"
  ///
  /// // Tokyo, Japan
  /// final tokyo = LocationCoordinate(latitude: 35.6762, longitude: 139.6503);
  /// print(MaidenheadConverter.toMaidenhead6Char(tokyo)); // "PM95tq"
  ///
  /// // Sydney, Australia
  /// final sydney = LocationCoordinate(latitude: -33.8688, longitude: 151.2093);
  /// print(MaidenheadConverter.toMaidenhead6Char(sydney)); // "QF56od"
  /// ```
  static String toMaidenhead6Char(LocationCoordinate coord) {
    // Normalize coordinates to positive values
    // Maidenhead uses origin at 180°W, 90°S
    final lon = coord.longitude + 180.0; // Range: 0 to 360
    final lat = coord.latitude + 90.0;   // Range: 0 to 180

    // FIELD: 20° longitude × 10° latitude (18×18 fields)
    // Divide by field size and convert to letter A-R (0-17)
    // Handle edge case: exactly 180° lat (North Pole) would give index 18, clamp to 17
    final fieldLon = (lon / 20.0).floor().clamp(0, 17);
    final fieldLat = (lat / 10.0).floor().clamp(0, 17);

    // Convert to letters A-R (ASCII 65-82)
    final field = String.fromCharCode(65 + fieldLon) +
                  String.fromCharCode(65 + fieldLat);

    // SQUARE: 2° longitude × 1° latitude (10×10 squares per field)
    // Get remainder from field calculation, divide by square size
    final squareLon = ((lon % 20.0) / 2.0).floor();
    final squareLat = ((lat % 10.0) / 1.0).floor();

    // Convert to digits 0-9
    final square = '$squareLon$squareLat';

    // SUBSQUARE: 5' longitude × 2.5' latitude (24×24 subsquares per square)
    // 5' = 5/60° = 0.083333°, 2.5' = 2.5/60° = 0.041667°
    // Get remainder from square calculation, divide by subsquare size
    final subsquareLon = ((lon % 2.0) / (5.0 / 60.0)).floor();
    final subsquareLat = ((lat % 1.0) / (2.5 / 60.0)).floor();

    // Convert to lowercase letters a-x (ASCII 97-120, indices 0-23)
    final subsquare = String.fromCharCode(97 + subsquareLon) +
                      String.fromCharCode(97 + subsquareLat);

    return field + square + subsquare;
  }

  /// Decodes a 6-character Maidenhead grid locator to its approximate center coordinate.
  ///
  /// Returns the geographic center point of the specified grid square.
  /// Note: This loses precision - multiple coordinates map to the same grid square.
  ///
  /// ## Parameters:
  /// - [gridLocator]: A 6-character Maidenhead string (case-insensitive, e.g., "FN31pr" or "fn31pr")
  ///
  /// ## Returns:
  /// A LocationCoordinate representing the center of the grid square
  ///
  /// ## Throws:
  /// - [ArgumentError] if the grid locator format is invalid
  ///
  /// ## Example:
  /// ```dart
  /// final coord = MaidenheadConverter.fromMaidenhead6Char("FN42li");
  /// print(coord); // LocationCoordinate near Boston
  /// ```
  static LocationCoordinate fromMaidenhead6Char(String gridLocator) {
    if (gridLocator.length != 6) {
      throw ArgumentError('Grid locator must be exactly 6 characters, got: ${gridLocator.length}');
    }

    final upper = gridLocator.toUpperCase();

    // Validate format: AAnnaa
    if (!RegExp(r'^[A-R]{2}[0-9]{2}[A-X]{2}$').hasMatch(upper)) {
      throw ArgumentError('Invalid Maidenhead grid locator format: $gridLocator');
    }

    // Decode field (characters 0-1)
    final fieldLon = upper.codeUnitAt(0) - 65; // A=0, R=17
    final fieldLat = upper.codeUnitAt(1) - 65;

    // Decode square (characters 2-3)
    final squareLon = int.parse(upper[2]);
    final squareLat = int.parse(upper[3]);

    // Decode subsquare (characters 4-5)
    final subsquareLon = upper.codeUnitAt(4) - 65; // A=0, X=23
    final subsquareLat = upper.codeUnitAt(5) - 65;

    // Calculate coordinate (center of subsquare)
    // Start from southwest corner, add half subsquare size for center
    final lon = (fieldLon * 20.0) +
                (squareLon * 2.0) +
                (subsquareLon * (5.0 / 60.0)) +
                (2.5 / 60.0) - // Half subsquare for center
                180.0; // Normalize back to -180 to +180

    final lat = (fieldLat * 10.0) +
                (squareLat * 1.0) +
                (subsquareLat * (2.5 / 60.0)) +
                (1.25 / 60.0) - // Half subsquare for center
                90.0; // Normalize back to -90 to +90

    return LocationCoordinate(latitude: lat, longitude: lon);
  }

  /// Calculates the approximate size of a Maidenhead grid square in meters.
  ///
  /// Returns dimensions at the center latitude of the grid square.
  /// Note: Grid squares are not perfect rectangles due to Earth's curvature.
  ///
  /// ## Parameters:
  /// - [gridLocator]: A 6-character Maidenhead string
  ///
  /// ## Returns:
  /// A map with 'width' (east-west) and 'height' (north-south) in meters
  ///
  /// ## Example:
  /// ```dart
  /// final size = MaidenheadConverter.getGridSquareSize("FN42li");
  /// print('Width: ${size['width']!.toStringAsFixed(0)}m'); // ~6855m at Boston latitude
  /// print('Height: ${size['height']!.toStringAsFixed(0)}m'); // ~4607m
  /// ```
  static Map<String, double> getGridSquareSize(String gridLocator) {
    final center = fromMaidenhead6Char(gridLocator);

    // Subsquare dimensions: 5' longitude × 2.5' latitude
    const lonDegrees = 5.0 / 60.0; // 0.083333°
    const latDegrees = 2.5 / 60.0; // 0.041667°

    // Convert to meters using approximate formulas
    // At equator: 1° longitude = 111,320 meters
    // 1° latitude ≈ 110,574 meters (relatively constant)
    const earthCircumference = 40075000.0; // meters at equator
    const metersPerDegreeLon = earthCircumference / 360.0; // ~111,319m
    const metersPerDegreeLat = 110574.0; // meters (average)

    // Adjust longitude for latitude (grid squares narrow at poles)
    final latRad = center.latitude * (math.pi / 180.0);
    final width = lonDegrees * metersPerDegreeLon * math.cos(latRad);
    final height = latDegrees * metersPerDegreeLat;

    return {
      'width': width,
      'height': height,
    };
  }
}
