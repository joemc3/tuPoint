import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/location_coordinate.dart';
import 'package:app/domain/utils/maidenhead_converter.dart';

void main() {
  group('MaidenheadConverter.toMaidenhead6Char', () {
    test('converts Boston coordinates correctly', () {
      // Boston, MA: 42.3601°N, 71.0589°W
      final boston = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final grid = MaidenheadConverter.toMaidenhead6Char(boston);
      expect(grid, equals('FN42li'));
    });

    test('converts Tokyo coordinates correctly', () {
      // Tokyo, Japan: 35.6762°N, 139.6503°E
      final tokyo = LocationCoordinate(latitude: 35.6762, longitude: 139.6503);
      final grid = MaidenheadConverter.toMaidenhead6Char(tokyo);
      expect(grid, equals('PM95tq'));
    });

    test('converts Sydney coordinates correctly', () {
      // Sydney, Australia: -33.8688°S, 151.2093°E
      final sydney = LocationCoordinate(latitude: -33.8688, longitude: 151.2093);
      final grid = MaidenheadConverter.toMaidenhead6Char(sydney);
      expect(grid, equals('QF56od'));
    });

    test('converts London coordinates correctly', () {
      // London, UK: 51.5074°N, 0.1278°W
      final london = LocationCoordinate(latitude: 51.5074, longitude: -0.1278);
      final grid = MaidenheadConverter.toMaidenhead6Char(london);
      expect(grid, equals('IO91wm'));
    });

    test('converts South Pole correctly', () {
      // South Pole: 90°S, 0°E (arbitrary longitude at pole)
      final southPole = LocationCoordinate(latitude: -90.0, longitude: 0.0);
      final grid = MaidenheadConverter.toMaidenhead6Char(southPole);
      expect(grid, equals('JA00aa')); // Field J (180°/20 = 9, 'A'+9='J'), Square 0
    });

    test('converts North Pole correctly', () {
      // North Pole: 90°N, 0°E
      // Edge case: 90° exactly is clamped to field R (17), then 180%10=0 for square
      final northPole = LocationCoordinate(latitude: 90.0, longitude: 0.0);
      final grid = MaidenheadConverter.toMaidenhead6Char(northPole);
      expect(grid, equals('JR00aa')); // Field R (clamped), square 0, subsquare a
    });

    test('converts Prime Meridian/Equator intersection correctly', () {
      // 0°N, 0°E
      final origin = LocationCoordinate(latitude: 0.0, longitude: 0.0);
      final grid = MaidenheadConverter.toMaidenhead6Char(origin);
      expect(grid, equals('JJ00aa')); // Center field
    });

    test('converts Date Line/Equator intersection correctly', () {
      // 0°N, 180°E (360° normalized, clamped to field R, max 17)
      final dateLine = LocationCoordinate(latitude: 0.0, longitude: 180.0);
      final grid = MaidenheadConverter.toMaidenhead6Char(dateLine);
      expect(grid, equals('RJ00aa')); // Maximum longitude clamped to field R
    });

    test('converts Date Line/Equator western side correctly', () {
      // 0°N, -180°W (same location as 180°E)
      final dateLineWest = LocationCoordinate(latitude: 0.0, longitude: -180.0);
      final grid = MaidenheadConverter.toMaidenhead6Char(dateLineWest);
      expect(grid, equals('AJ00aa')); // Minimum longitude = field A
    });

    test('returns 6-character string', () {
      final coord = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final grid = MaidenheadConverter.toMaidenhead6Char(coord);
      expect(grid.length, equals(6));
    });

    test('returns uppercase field letters', () {
      final coord = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final grid = MaidenheadConverter.toMaidenhead6Char(coord);
      // First two characters should be uppercase A-R
      expect(RegExp(r'^[A-R]{2}').hasMatch(grid), isTrue);
    });

    test('returns digits for square', () {
      final coord = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final grid = MaidenheadConverter.toMaidenhead6Char(coord);
      // Characters 3-4 should be digits 0-9
      expect(RegExp(r'^[A-R]{2}[0-9]{2}').hasMatch(grid), isTrue);
    });

    test('returns lowercase subsquare letters', () {
      final coord = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final grid = MaidenheadConverter.toMaidenhead6Char(coord);
      // Characters 5-6 should be lowercase a-x
      expect(RegExp(r'^[A-R]{2}[0-9]{2}[a-x]{2}$').hasMatch(grid), isTrue);
    });
  });

  group('MaidenheadConverter.fromMaidenhead6Char', () {
    test('decodes Boston grid square to approximate coordinate', () {
      final coord = MaidenheadConverter.fromMaidenhead6Char('FN42li');

      // Should be near Boston (42.3601, -71.0589)
      // Grid square is ~6.8km × ~4.6km, so allow 0.05° tolerance (~5.5km)
      expect(coord.latitude, closeTo(42.3601, 0.05));
      expect(coord.longitude, closeTo(-71.0589, 0.05));
    });

    test('decodes Tokyo grid square to approximate coordinate', () {
      final coord = MaidenheadConverter.fromMaidenhead6Char('PM95tq');

      // Should be near Tokyo (35.6762, 139.6503)
      expect(coord.latitude, closeTo(35.6762, 0.05));
      expect(coord.longitude, closeTo(139.6503, 0.05));
    });

    test('accepts lowercase input', () {
      final coord = MaidenheadConverter.fromMaidenhead6Char('fn42li');
      expect(coord.latitude, closeTo(42.3601, 0.05));
      expect(coord.longitude, closeTo(-71.0589, 0.05));
    });

    test('accepts mixed case input', () {
      final coord = MaidenheadConverter.fromMaidenhead6Char('Fn42Li');
      expect(coord.latitude, closeTo(42.3601, 0.05));
      expect(coord.longitude, closeTo(-71.0589, 0.05));
    });

    test('throws ArgumentError for wrong length', () {
      expect(
        () => MaidenheadConverter.fromMaidenhead6Char('FN42'),
        throwsArgumentError,
      );
      expect(
        () => MaidenheadConverter.fromMaidenhead6Char('FN42jiabc'),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for invalid field letters', () {
      expect(
        () => MaidenheadConverter.fromMaidenhead6Char('ZZ42li'),
        throwsArgumentError,
      );
      expect(
        () => MaidenheadConverter.fromMaidenhead6Char('FN42li'),
        returnsNormally,
      );
    });

    test('throws ArgumentError for invalid square digits', () {
      expect(
        () => MaidenheadConverter.fromMaidenhead6Char('FNAAji'),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for invalid subsquare letters', () {
      expect(
        () => MaidenheadConverter.fromMaidenhead6Char('FN42ZZ'),
        throwsArgumentError,
      );
    });

    test('round-trip conversion preserves grid square', () {
      final original = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final grid = MaidenheadConverter.toMaidenhead6Char(original);
      final decoded = MaidenheadConverter.fromMaidenhead6Char(grid);
      final reencoded = MaidenheadConverter.toMaidenhead6Char(decoded);

      // Re-encoding the decoded center should give same grid square
      expect(reencoded, equals(grid));
    });
  });

  group('MaidenheadConverter.getGridSquareSize', () {
    test('calculates Boston grid square size', () {
      final size = MaidenheadConverter.getGridSquareSize('FN42li');

      // At Boston latitude (~42°N), 6-char grid subsquare is 5' lon × 2.5' lat:
      // - Width: ~6.9km (varies by latitude due to meridian convergence)
      // - Height: ~4.6km (relatively constant)
      expect(size['width']!, closeTo(6900, 500)); // ~6.9km ± 500m
      expect(size['height']!, closeTo(4600, 100)); // ~4.6km ± 100m
    });

    test('calculates equator grid square size', () {
      final size = MaidenheadConverter.getGridSquareSize('JJ00aa');

      // At equator, grid squares are widest:
      // - Width: ~9.3km (no meridian convergence)
      // - Height: ~4.6km
      expect(size['width']!, closeTo(9300, 200));
      expect(size['height']!, closeTo(4600, 100));
    });

    test('calculates polar grid square size', () {
      final size = MaidenheadConverter.getGridSquareSize('JR00aa');

      // At high latitudes (170-180° normalized = 80-90°N), width shrinks dramatically
      expect(size['width']!, lessThan(2000)); // Much narrower near pole (~1600m at 85°N)
      expect(size['height']!, closeTo(4600, 100)); // Height stays consistent
    });

    test('returns map with width and height keys', () {
      final size = MaidenheadConverter.getGridSquareSize('FN42li');

      expect(size.containsKey('width'), isTrue);
      expect(size.containsKey('height'), isTrue);
      expect(size['width']!, greaterThan(0));
      expect(size['height']!, greaterThan(0));
    });
  });
}
