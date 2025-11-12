import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/value_objects/location_coordinate.dart';
import 'package:app/domain/utils/haversine_calculator.dart';

void main() {
  group('HaversineCalculator.calculateDistance', () {
    test('calculates distance between Boston and Cambridge', () {
      // Boston, MA: 42.3601°N, 71.0589°W
      final boston = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      // Cambridge, MA: 42.3736°N, 71.1097°W
      final cambridge = LocationCoordinate(latitude: 42.3736, longitude: -71.1097);

      final distance = HaversineCalculator.calculateDistance(boston, cambridge);

      // Expected: ~4,435 meters (actual precise calculation)
      expect(distance, closeTo(4435, 100));
    });

    test('calculates distance between Boston and New York', () {
      // Boston, MA: 42.3601°N, 71.0589°W
      final boston = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      // New York, NY: 40.7128°N, 74.0060°W
      final nyc = LocationCoordinate(latitude: 40.7128, longitude: -74.0060);

      final distance = HaversineCalculator.calculateDistance(boston, nyc);

      // Expected: ~306 km (306,000 meters)
      expect(distance, closeTo(306000, 5000));
    });

    test('calculates distance between Tokyo and Osaka', () {
      // Tokyo, Japan: 35.6762°N, 139.6503°E
      final tokyo = LocationCoordinate(latitude: 35.6762, longitude: 139.6503);
      // Osaka, Japan: 34.6937°N, 135.5023°E
      final osaka = LocationCoordinate(latitude: 34.6937, longitude: 135.5023);

      final distance = HaversineCalculator.calculateDistance(tokyo, osaka);

      // Expected: ~400 km
      expect(distance, closeTo(400000, 10000));
    });

    test('returns zero for identical coordinates', () {
      final coord = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final distance = HaversineCalculator.calculateDistance(coord, coord);

      expect(distance, equals(0.0));
    });

    test('returns zero for same location different object', () {
      final coord1 = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final coord2 = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final distance = HaversineCalculator.calculateDistance(coord1, coord2);

      expect(distance, equals(0.0));
    });

    test('calculates very short distances accurately', () {
      // Two points ~100m apart
      final coord1 = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final coord2 = LocationCoordinate(latitude: 42.3610, longitude: -71.0589);

      final distance = HaversineCalculator.calculateDistance(coord1, coord2);

      // Expected: ~100 meters (0.0009° latitude ≈ 100m)
      expect(distance, closeTo(100, 10));
    });

    test('handles crossing the Date Line correctly', () {
      // Fiji: 17.7134°S, 178.0650°E
      final fiji = LocationCoordinate(latitude: -17.7134, longitude: 178.0650);
      // Samoa: 13.7590°S, -172.1046°W
      final samoa = LocationCoordinate(latitude: -13.7590, longitude: -172.1046);

      final distance = HaversineCalculator.calculateDistance(fiji, samoa);

      // Expected: ~1,140 km (actual distance across Pacific)
      expect(distance, closeTo(1140000, 30000));
    });

    test('handles crossing the Prime Meridian correctly', () {
      // London: 51.5074°N, 0.1278°W
      final london = LocationCoordinate(latitude: 51.5074, longitude: -0.1278);
      // Paris: 48.8566°N, 2.3522°E
      final paris = LocationCoordinate(latitude: 48.8566, longitude: 2.3522);

      final distance = HaversineCalculator.calculateDistance(london, paris);

      // Expected: ~344 km
      expect(distance, closeTo(344000, 5000));
    });

    test('calculates distance near equator', () {
      // Singapore: 1.3521°N, 103.8198°E
      final singapore = LocationCoordinate(latitude: 1.3521, longitude: 103.8198);
      // Kuala Lumpur: 3.1390°N, 101.6869°E
      final kl = LocationCoordinate(latitude: 3.1390, longitude: 101.6869);

      final distance = HaversineCalculator.calculateDistance(singapore, kl);

      // Expected: ~309 km (precise calculation)
      expect(distance, closeTo(309000, 5000));
    });

    test('calculates distance near poles', () {
      // Alert, Canada (northernmost settlement): 82.5°N, 62.3°W
      final alert = LocationCoordinate(latitude: 82.5, longitude: -62.3);
      // Nord, Greenland: 81.6°N, 16.7°W
      final nord = LocationCoordinate(latitude: 81.6, longitude: -16.7);

      final distance = HaversineCalculator.calculateDistance(alert, nord);

      // Expected: ~600-700 km (less accurate near poles due to spherical approximation)
      expect(distance, closeTo(650000, 100000));
    });

    test('is commutative (distance A to B equals B to A)', () {
      final boston = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final nyc = LocationCoordinate(latitude: 40.7128, longitude: -74.0060);

      final distanceAB = HaversineCalculator.calculateDistance(boston, nyc);
      final distanceBA = HaversineCalculator.calculateDistance(nyc, boston);

      expect(distanceAB, equals(distanceBA));
    });

    test('calculates maximum distance (antipodal points)', () {
      // Madrid: 40.4168°N, 3.7038°W
      final madrid = LocationCoordinate(latitude: 40.4168, longitude: -3.7038);
      // Antipodal point in Pacific Ocean: 40.4168°S, 176.2962°E
      final antipode = LocationCoordinate(latitude: -40.4168, longitude: 176.2962);

      final distance = HaversineCalculator.calculateDistance(madrid, antipode);

      // Expected: ~20,015 km (half Earth's circumference)
      expect(distance, closeTo(20015000, 50000));
    });
  });

  group('HaversineCalculator.isWithinRadius', () {
    test('returns true when point is within radius', () {
      final center = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final point = LocationCoordinate(latitude: 42.3736, longitude: -71.1097);

      // Distance is ~4.2km, check 5km radius
      expect(HaversineCalculator.isWithinRadius(center, point, 5000), isTrue);
    });

    test('returns false when point is outside radius', () {
      final center = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final point = LocationCoordinate(latitude: 42.3736, longitude: -71.1097);

      // Distance is ~4.2km, check 3km radius
      expect(HaversineCalculator.isWithinRadius(center, point, 3000), isFalse);
    });

    test('returns true when point is exactly on radius boundary', () {
      final center = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final point = LocationCoordinate(latitude: 42.3736, longitude: -71.1097);

      final exactDistance = HaversineCalculator.calculateDistance(center, point);
      expect(HaversineCalculator.isWithinRadius(center, point, exactDistance), isTrue);
    });

    test('returns true for identical coordinates', () {
      final coord = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);

      expect(HaversineCalculator.isWithinRadius(coord, coord, 0), isTrue);
      expect(HaversineCalculator.isWithinRadius(coord, coord, 1000), isTrue);
    });

    test('works with tuPoint default 5km radius', () {
      final userLocation = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);

      // Point within 5km (Cambridge, ~4.4km away)
      final nearbyPoint = LocationCoordinate(latitude: 42.3736, longitude: -71.1097);
      expect(HaversineCalculator.isWithinRadius(userLocation, nearbyPoint, 5000), isTrue);

      // Point outside 5km (Medford, ~7km away)
      final farPoint = LocationCoordinate(latitude: 42.4184, longitude: -71.1062);
      expect(HaversineCalculator.isWithinRadius(userLocation, farPoint, 5000), isFalse);
    });
  });

  group('HaversineCalculator.calculateBearing', () {
    test('calculates bearing from Boston to NYC (southwest)', () {
      final boston = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final nyc = LocationCoordinate(latitude: 40.7128, longitude: -74.0060);

      final bearing = HaversineCalculator.calculateBearing(boston, nyc);

      // Expected: ~240° (Southwest)
      expect(bearing, closeTo(240, 10));
    });

    test('calculates bearing due north', () {
      final start = LocationCoordinate(latitude: 42.0, longitude: -71.0);
      final end = LocationCoordinate(latitude: 43.0, longitude: -71.0);

      final bearing = HaversineCalculator.calculateBearing(start, end);

      // Expected: 0° or 360° (North)
      expect(bearing, closeTo(0, 1));
    });

    test('calculates bearing due south', () {
      final start = LocationCoordinate(latitude: 43.0, longitude: -71.0);
      final end = LocationCoordinate(latitude: 42.0, longitude: -71.0);

      final bearing = HaversineCalculator.calculateBearing(start, end);

      // Expected: 180° (South)
      expect(bearing, closeTo(180, 1));
    });

    test('calculates bearing due east', () {
      final start = LocationCoordinate(latitude: 42.0, longitude: -72.0);
      final end = LocationCoordinate(latitude: 42.0, longitude: -71.0);

      final bearing = HaversineCalculator.calculateBearing(start, end);

      // Expected: 90° (East)
      expect(bearing, closeTo(90, 1));
    });

    test('calculates bearing due west', () {
      final start = LocationCoordinate(latitude: 42.0, longitude: -71.0);
      final end = LocationCoordinate(latitude: 42.0, longitude: -72.0);

      final bearing = HaversineCalculator.calculateBearing(start, end);

      // Expected: 270° (West)
      expect(bearing, closeTo(270, 1));
    });

    test('returns bearing in range 0-360', () {
      final start = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final end = LocationCoordinate(latitude: 40.7128, longitude: -74.0060);

      final bearing = HaversineCalculator.calculateBearing(start, end);

      expect(bearing, greaterThanOrEqualTo(0));
      expect(bearing, lessThan(360));
    });
  });

  group('HaversineCalculator.calculateDestination', () {
    test('calculates destination 5km north of Boston', () {
      final boston = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final destination = HaversineCalculator.calculateDestination(boston, 5000, 0);

      // Should be roughly same longitude, higher latitude
      expect(destination.longitude, closeTo(-71.0589, 0.01));
      expect(destination.latitude, greaterThan(boston.latitude));

      // Verify distance back to original
      final distanceBack = HaversineCalculator.calculateDistance(boston, destination);
      expect(distanceBack, closeTo(5000, 10));
    });

    test('calculates destination 5km east of Boston', () {
      final boston = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final destination = HaversineCalculator.calculateDestination(boston, 5000, 90);

      // Should be roughly same latitude, higher longitude (less negative)
      expect(destination.latitude, closeTo(42.3601, 0.01));
      expect(destination.longitude, greaterThan(boston.longitude));

      // Verify distance
      final distanceBack = HaversineCalculator.calculateDistance(boston, destination);
      expect(distanceBack, closeTo(5000, 10));
    });

    test('round-trip distance and bearing preserves location', () {
      final start = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);

      // Calculate destination 10km northeast
      final destination = HaversineCalculator.calculateDestination(start, 10000, 45);

      // Calculate distance back
      final distance = HaversineCalculator.calculateDistance(start, destination);
      expect(distance, closeTo(10000, 10));

      // Calculate bearing back
      final bearing = HaversineCalculator.calculateBearing(start, destination);
      expect(bearing, closeTo(45, 1));
    });

    test('handles crossing date line', () {
      // Start near date line
      final start = LocationCoordinate(latitude: 0, longitude: 179);

      // Travel 200km east (should cross date line)
      final destination = HaversineCalculator.calculateDestination(start, 200000, 90);

      // Should wrap around to negative longitude
      expect(destination.longitude, lessThan(-170));

      // Verify distance
      final distance = HaversineCalculator.calculateDistance(start, destination);
      expect(distance, closeTo(200000, 1000));
    });

    test('handles zero distance', () {
      final start = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);
      final destination = HaversineCalculator.calculateDestination(start, 0, 45);

      // Should return same location
      expect(destination.latitude, closeTo(start.latitude, 0.0001));
      expect(destination.longitude, closeTo(start.longitude, 0.0001));
    });

    test('handles various bearings correctly', () {
      final start = LocationCoordinate(latitude: 42.3601, longitude: -71.0589);

      for (var bearing = 0.0; bearing < 360; bearing += 45) {
        final destination = HaversineCalculator.calculateDestination(start, 5000, bearing);

        // Verify distance is correct regardless of bearing
        final distance = HaversineCalculator.calculateDistance(start, destination);
        expect(distance, closeTo(5000, 10));

        // Verify calculated bearing matches
        final calculatedBearing = HaversineCalculator.calculateBearing(start, destination);
        expect(calculatedBearing, closeTo(bearing, 1));
      }
    });
  });
}
