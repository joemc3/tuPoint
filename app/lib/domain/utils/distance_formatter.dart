/// Formats distances in meters to human-readable strings.
///
/// Provides consistent distance formatting across the tuPoint application,
/// automatically selecting appropriate units (meters vs kilometers) based
/// on distance magnitude.
///
/// ## Formatting Rules:
/// - **< 1000m**: Display as whole meters (e.g., "456 m")
/// - **≥ 1000m**: Display as kilometers with 1 decimal place (e.g., "1.2 km")
///
/// ## Design Rationale:
/// - **Meters for short distances**: Provides meaningful precision for nearby content
/// - **No decimals on meters**: "456 m" is clearer than "456.0 m"
/// - **One decimal for kilometers**: Balances precision with readability ("1.2 km" vs "1234 m")
/// - **Consistent formatting**: All distances follow the same rules for UI uniformity
///
/// ## Usage in tuPoint:
/// This formatter is used throughout the UI to display distances:
/// - Point card distance labels ("1.2 km away")
/// - Feed filtering status ("Showing points within 5.0 km")
/// - Profile stats ("Dropped 42 points across 12.5 km")
///
/// ## Example:
/// ```dart
/// print(DistanceFormatter.format(0));       // "0 m"
/// print(DistanceFormatter.format(456));     // "456 m"
/// print(DistanceFormatter.format(999));     // "999 m"
/// print(DistanceFormatter.format(1000));    // "1.0 km"
/// print(DistanceFormatter.format(1234.5));  // "1.2 km"
/// print(DistanceFormatter.format(5678.9));  // "5.7 km"
/// print(DistanceFormatter.format(10000));   // "10.0 km"
/// ```
class DistanceFormatter {
  DistanceFormatter._(); // Private constructor - utility class should not be instantiated

  /// Threshold in meters at which to switch from meters to kilometers.
  static const double _metersToKilometersThreshold = 1000.0;

  /// Converts meters to kilometers.
  static const double _metersPerKilometer = 1000.0;

  /// Formats a distance in meters to a human-readable string.
  ///
  /// ## Parameters:
  /// - [meters]: Distance in meters (non-negative double)
  ///
  /// ## Returns:
  /// A formatted string with appropriate units:
  /// - "X m" for distances < 1000m (no decimal places)
  /// - "X.X km" for distances ≥ 1000m (one decimal place)
  ///
  /// ## Behavior:
  /// - **Negative values**: Treated as absolute value (edge case handling)
  /// - **Zero**: Returns "0 m"
  /// - **Very large values**: Formatted as kilometers (e.g., "123.4 km" for 123,456m)
  /// - **Rounding**: Kilometers rounded to 1 decimal place using standard rounding rules
  ///
  /// ## Precision Notes:
  /// - Meter values are rounded to nearest integer (automatic via Dart's toString)
  /// - Kilometer values show 1 decimal place (100m resolution)
  /// - Example: 1,249m → "1.2 km", 1,250m → "1.2 km", 1,251m → "1.3 km"
  ///
  /// ## Example:
  /// ```dart
  /// // Edge cases
  /// print(DistanceFormatter.format(0));      // "0 m"
  /// print(DistanceFormatter.format(0.5));    // "1 m" (rounds up)
  /// print(DistanceFormatter.format(-100));   // "100 m" (absolute value)
  ///
  /// // Meter range (0-999m)
  /// print(DistanceFormatter.format(1));      // "1 m"
  /// print(DistanceFormatter.format(456));    // "456 m"
  /// print(DistanceFormatter.format(999));    // "999 m"
  /// print(DistanceFormatter.format(999.9));  // "1000 m"
  ///
  /// // Threshold
  /// print(DistanceFormatter.format(1000));   // "1.0 km"
  ///
  /// // Kilometer range (≥1000m)
  /// print(DistanceFormatter.format(1234));   // "1.2 km"
  /// print(DistanceFormatter.format(1249));   // "1.2 km"
  /// print(DistanceFormatter.format(1250));   // "1.2 km"
  /// print(DistanceFormatter.format(1251));   // "1.3 km"
  /// print(DistanceFormatter.format(5678.9)); // "5.7 km"
  /// print(DistanceFormatter.format(10000));  // "10.0 km"
  /// print(DistanceFormatter.format(123456)); // "123.5 km"
  /// ```
  ///
  /// ## UI Integration:
  /// ```dart
  /// // In a Point card widget:
  /// Text(
  ///   DistanceFormatter.format(point.distanceFromUser),
  ///   style: theme.textTheme.labelSmall,
  /// )
  ///
  /// // In feed header:
  /// Text('Showing points within ${DistanceFormatter.format(5000)}')
  /// ```
  static String format(double meters) {
    // Handle negative values as edge case (convert to absolute value)
    final absoluteMeters = meters.abs();

    // Check if we should display in kilometers
    if (absoluteMeters >= _metersToKilometersThreshold) {
      // Convert to kilometers with 1 decimal place
      final kilometers = absoluteMeters / _metersPerKilometer;
      return '${kilometers.toStringAsFixed(1)} km';
    } else {
      // Display in meters (no decimal places)
      // Round to nearest integer
      final roundedMeters = absoluteMeters.round();
      return '$roundedMeters m';
    }
  }

  /// Formats a distance with additional precision for debugging or technical displays.
  ///
  /// Uses 2 decimal places for kilometers instead of 1, providing ~10m resolution
  /// for technical contexts where more precision is helpful.
  ///
  /// ## Parameters:
  /// - [meters]: Distance in meters (non-negative double)
  ///
  /// ## Returns:
  /// A formatted string with enhanced precision:
  /// - "X m" for distances < 1000m (no decimal places)
  /// - "X.XX km" for distances ≥ 1000m (two decimal places)
  ///
  /// ## Use Cases:
  /// - Debug logs
  /// - Developer tools
  /// - Testing output
  /// - Analytics reports
  ///
  /// ## Example:
  /// ```dart
  /// print(DistanceFormatter.formatPrecise(456));     // "456 m"
  /// print(DistanceFormatter.formatPrecise(1234.5));  // "1.23 km"
  /// print(DistanceFormatter.formatPrecise(5678.9));  // "5.68 km"
  /// ```
  static String formatPrecise(double meters) {
    final absoluteMeters = meters.abs();

    if (absoluteMeters >= _metersToKilometersThreshold) {
      final kilometers = absoluteMeters / _metersPerKilometer;
      return '${kilometers.toStringAsFixed(2)} km';
    } else {
      final roundedMeters = absoluteMeters.round();
      return '$roundedMeters m';
    }
  }

  /// Parses a formatted distance string back to meters.
  ///
  /// Inverse operation of [format]. Useful for parsing user input or
  /// stored formatted strings.
  ///
  /// ## Parameters:
  /// - [formattedDistance]: A string in the format "X m" or "X.X km"
  ///
  /// ## Returns:
  /// Distance in meters as a double
  ///
  /// ## Throws:
  /// - [FormatException] if the string cannot be parsed
  ///
  /// ## Example:
  /// ```dart
  /// print(DistanceFormatter.parse("456 m"));    // 456.0
  /// print(DistanceFormatter.parse("1.2 km"));   // 1200.0
  /// print(DistanceFormatter.parse("5.7 km"));   // 5700.0
  /// ```
  static double parse(String formattedDistance) {
    final trimmed = formattedDistance.trim();

    if (trimmed.endsWith(' m')) {
      // Parse meters
      final numberStr = trimmed.substring(0, trimmed.length - 2).trim();
      final meters = double.tryParse(numberStr);
      if (meters == null) {
        throw FormatException('Invalid meter format: $formattedDistance');
      }
      return meters;
    } else if (trimmed.endsWith(' km')) {
      // Parse kilometers
      final numberStr = trimmed.substring(0, trimmed.length - 3).trim();
      final kilometers = double.tryParse(numberStr);
      if (kilometers == null) {
        throw FormatException('Invalid kilometer format: $formattedDistance');
      }
      return kilometers * _metersPerKilometer;
    } else {
      throw FormatException('Unknown distance format: $formattedDistance');
    }
  }

  /// Formats a distance for compact display in tight UI spaces.
  ///
  /// Removes space between number and unit for more compact presentation.
  /// Useful for badges, chips, or dense layouts.
  ///
  /// ## Parameters:
  /// - [meters]: Distance in meters (non-negative double)
  ///
  /// ## Returns:
  /// A compact formatted string without space:
  /// - "Xm" for distances < 1000m
  /// - "X.Xkm" for distances ≥ 1000m
  ///
  /// ## Example:
  /// ```dart
  /// print(DistanceFormatter.formatCompact(456));     // "456m"
  /// print(DistanceFormatter.formatCompact(1234.5));  // "1.2km"
  /// ```
  static String formatCompact(double meters) {
    final formatted = format(meters);
    return formatted.replaceAll(' ', ''); // Remove space between number and unit
  }
}
