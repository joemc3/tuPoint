import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/point.dart';
import 'package:app/domain/value_objects/location_coordinate.dart';

void main() {
  group('Point', () {
    group('fromJson', () {
      test('deserializes from snake_case JSON with PostGIS geometry', () {
        // Boston, MA coordinates
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'user_id': '987fcdeb-51a2-43d7-9012-345678901234',
          'content': 'Amazing coffee shop in Back Bay!',
          'geom': {
            'type': 'Point',
            'coordinates': [-71.0589, 42.3601], // [lon, lat]
          },
          'maidenhead_6char': 'FN42al',
          'is_active': true,
          'created_at': '2025-01-15T10:30:00Z',
        };

        final point = Point.fromJson(json);

        expect(point.id, equals('123e4567-e89b-12d3-a456-426614174000'));
        expect(point.userId, equals('987fcdeb-51a2-43d7-9012-345678901234'));
        expect(point.content, equals('Amazing coffee shop in Back Bay!'));
        expect(point.location.latitude, equals(42.3601));
        expect(point.location.longitude, equals(-71.0589));
        expect(point.maidenhead6char, equals('FN42al'));
        expect(point.isActive, isTrue);
        expect(point.createdAt, equals(DateTime.parse('2025-01-15T10:30:00Z')));
      });

      test('deserializes NYC coordinates correctly', () {
        // New York City coordinates
        final json = {
          'id': 'nyc-point-uuid',
          'user_id': 'user-uuid',
          'content': 'Central Park is beautiful today!',
          'geom': {
            'type': 'Point',
            'coordinates': [-74.0060, 40.7128], // [lon, lat]
          },
          'maidenhead_6char': 'FN30ar',
          'is_active': true,
          'created_at': '2025-01-15T14:20:00Z',
        };

        final point = Point.fromJson(json);

        expect(point.location.latitude, equals(40.7128));
        expect(point.location.longitude, equals(-74.0060));
        expect(point.maidenhead6char, equals('FN30ar'));
      });

      test('deserializes inactive point correctly', () {
        final json = {
          'id': 'inactive-point-uuid',
          'user_id': 'user-uuid',
          'content': 'This point has been deleted',
          'geom': {
            'type': 'Point',
            'coordinates': [-71.0589, 42.3601],
          },
          'maidenhead_6char': 'FN42al',
          'is_active': false,
          'created_at': '2025-01-15T10:30:00Z',
        };

        final point = Point.fromJson(json);

        expect(point.isActive, isFalse);
        expect(point.content, equals('This point has been deleted'));
      });

      test('deserializes international coordinates correctly', () {
        // Tokyo, Japan coordinates
        final json = {
          'id': 'tokyo-point-uuid',
          'user_id': 'user-uuid',
          'content': 'Shibuya crossing is packed!',
          'geom': {
            'type': 'Point',
            'coordinates': [139.6503, 35.6762], // [lon, lat]
          },
          'maidenhead_6char': 'PM95ar',
          'is_active': true,
          'created_at': '2025-01-15T03:15:00Z',
        };

        final point = Point.fromJson(json);

        expect(point.location.latitude, equals(35.6762));
        expect(point.location.longitude, equals(139.6503));
        expect(point.content, equals('Shibuya crossing is packed!'));
      });
    });

    group('toJson', () {
      test('serializes to snake_case JSON with PostGIS geometry', () {
        final point = Point(
          id: '123e4567-e89b-12d3-a456-426614174000',
          userId: '987fcdeb-51a2-43d7-9012-345678901234',
          content: 'Great view from the harbor!',
          location: const LocationCoordinate(
            latitude: 42.3601,
            longitude: -71.0589,
          ),
          maidenhead6char: 'FN42al',
          isActive: true,
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final json = point.toJson();

        expect(json['id'], equals('123e4567-e89b-12d3-a456-426614174000'));
        expect(json['user_id'], equals('987fcdeb-51a2-43d7-9012-345678901234'));
        expect(json['content'], equals('Great view from the harbor!'));
        expect(json['geom'], isA<Map<String, dynamic>>());
        expect(json['geom']['type'], equals('Point'));
        expect(json['geom']['coordinates'], equals([-71.0589, 42.3601]));
        expect(json['maidenhead_6char'], equals('FN42al'));
        expect(json['is_active'], isTrue);
        expect(json['created_at'], equals('2025-01-15T10:30:00.000Z'));
      });

      test('serializes inactive point correctly', () {
        final point = Point(
          id: 'inactive-point-uuid',
          userId: 'user-uuid',
          content: 'Soft-deleted content',
          location: const LocationCoordinate(
            latitude: 42.3601,
            longitude: -71.0589,
          ),
          maidenhead6char: 'FN42al',
          isActive: false,
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final json = point.toJson();

        expect(json['is_active'], isFalse);
      });

      test('serializes various coordinates correctly', () {
        // Test with NYC coordinates
        final point = Point(
          id: 'nyc-point',
          userId: 'user-uuid',
          content: 'Times Square!',
          location: const LocationCoordinate(
            latitude: 40.7128,
            longitude: -74.0060,
          ),
          maidenhead6char: 'FN30ar',
          isActive: true,
          createdAt: DateTime.parse('2025-01-15T14:20:00Z'),
        );

        final json = point.toJson();

        expect(json['geom']['coordinates'], equals([-74.0060, 40.7128]));
      });
    });

    group('LocationCoordinateConverter', () {
      test('converts PostGIS geometry to LocationCoordinate', () {
        const converter = LocationCoordinateConverter();
        final geometryJson = {
          'type': 'Point',
          'coordinates': [-71.0589, 42.3601], // [lon, lat]
        };

        final coordinate = converter.fromJson(geometryJson);

        expect(coordinate.latitude, equals(42.3601));
        expect(coordinate.longitude, equals(-71.0589));
      });

      test('converts LocationCoordinate to PostGIS geometry', () {
        const converter = LocationCoordinateConverter();
        const coordinate = LocationCoordinate(
          latitude: 42.3601,
          longitude: -71.0589,
        );

        final geometryJson = converter.toJson(coordinate);

        expect(geometryJson['type'], equals('Point'));
        expect(geometryJson['coordinates'], equals([-71.0589, 42.3601]));
      });

      test('handles negative and positive coordinates', () {
        const converter = LocationCoordinateConverter();

        // Western and Northern hemisphere (Boston)
        final geometry1 = converter.toJson(
          const LocationCoordinate(latitude: 42.3601, longitude: -71.0589),
        );
        expect(geometry1['coordinates'], equals([-71.0589, 42.3601]));

        // Eastern and Northern hemisphere (Tokyo)
        final geometry2 = converter.toJson(
          const LocationCoordinate(latitude: 35.6762, longitude: 139.6503),
        );
        expect(geometry2['coordinates'], equals([139.6503, 35.6762]));

        // Southern hemisphere (Sydney)
        final geometry3 = converter.toJson(
          const LocationCoordinate(latitude: -33.8688, longitude: 151.2093),
        );
        expect(geometry3['coordinates'], equals([151.2093, -33.8688]));
      });

      test('roundtrip conversion preserves coordinate values', () {
        const converter = LocationCoordinateConverter();
        const original = LocationCoordinate(
          latitude: 42.3601,
          longitude: -71.0589,
        );

        final json = converter.toJson(original);
        final recovered = converter.fromJson(json);

        expect(recovered.latitude, equals(original.latitude));
        expect(recovered.longitude, equals(original.longitude));
      });
    });

    group('equality', () {
      test('points with same values are equal', () {
        final point1 = Point(
          id: '123e4567-e89b-12d3-a456-426614174000',
          userId: '987fcdeb-51a2-43d7-9012-345678901234',
          content: 'Test content',
          location: const LocationCoordinate(
            latitude: 42.3601,
            longitude: -71.0589,
          ),
          maidenhead6char: 'FN42al',
          isActive: true,
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final point2 = Point(
          id: '123e4567-e89b-12d3-a456-426614174000',
          userId: '987fcdeb-51a2-43d7-9012-345678901234',
          content: 'Test content',
          location: const LocationCoordinate(
            latitude: 42.3601,
            longitude: -71.0589,
          ),
          maidenhead6char: 'FN42al',
          isActive: true,
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        expect(point1, equals(point2));
        expect(point1.hashCode, equals(point2.hashCode));
      });

      test('points with different IDs are not equal', () {
        final point1 = Point(
          id: 'id-1',
          userId: 'user-uuid',
          content: 'Content',
          location: const LocationCoordinate(
            latitude: 42.3601,
            longitude: -71.0589,
          ),
          maidenhead6char: 'FN42al',
          isActive: true,
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final point2 = Point(
          id: 'id-2',
          userId: 'user-uuid',
          content: 'Content',
          location: const LocationCoordinate(
            latitude: 42.3601,
            longitude: -71.0589,
          ),
          maidenhead6char: 'FN42al',
          isActive: true,
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        expect(point1, isNot(equals(point2)));
      });

      test('points with different locations are not equal', () {
        final point1 = Point(
          id: 'same-id',
          userId: 'user-uuid',
          content: 'Content',
          location: const LocationCoordinate(
            latitude: 42.3601,
            longitude: -71.0589,
          ),
          maidenhead6char: 'FN42al',
          isActive: true,
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final point2 = Point(
          id: 'same-id',
          userId: 'user-uuid',
          content: 'Content',
          location: const LocationCoordinate(
            latitude: 40.7128,
            longitude: -74.0060,
          ),
          maidenhead6char: 'FN30ar',
          isActive: true,
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        expect(point1, isNot(equals(point2)));
      });
    });

    group('copyWith', () {
      test('creates copy with updated content', () {
        final original = Point(
          id: 'point-id',
          userId: 'user-uuid',
          content: 'Original content',
          location: const LocationCoordinate(
            latitude: 42.3601,
            longitude: -71.0589,
          ),
          maidenhead6char: 'FN42al',
          isActive: true,
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final updated = original.copyWith(content: 'Updated content');

        expect(updated.id, equals(original.id));
        expect(updated.userId, equals(original.userId));
        expect(updated.content, equals('Updated content'));
        expect(updated.location, equals(original.location));
        expect(updated.maidenhead6char, equals(original.maidenhead6char));
        expect(updated.isActive, equals(original.isActive));
        expect(updated.createdAt, equals(original.createdAt));
      });

      test('creates copy with updated isActive status', () {
        final original = Point(
          id: 'point-id',
          userId: 'user-uuid',
          content: 'Content',
          location: const LocationCoordinate(
            latitude: 42.3601,
            longitude: -71.0589,
          ),
          maidenhead6char: 'FN42al',
          isActive: true,
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final softDeleted = original.copyWith(isActive: false);

        expect(softDeleted.isActive, isFalse);
        expect(softDeleted.id, equals(original.id));
        expect(softDeleted.content, equals(original.content));
      });

      test('preserves all fields when no changes', () {
        final original = Point(
          id: 'point-id',
          userId: 'user-uuid',
          content: 'Content',
          location: const LocationCoordinate(
            latitude: 42.3601,
            longitude: -71.0589,
          ),
          maidenhead6char: 'FN42al',
          isActive: true,
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('JSON roundtrip', () {
      test('deserialize then serialize preserves all data', () {
        final originalJson = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'user_id': '987fcdeb-51a2-43d7-9012-345678901234',
          'content': 'Roundtrip test content',
          'geom': {
            'type': 'Point',
            'coordinates': [-71.0589, 42.3601],
          },
          'maidenhead_6char': 'FN42al',
          'is_active': true,
          'created_at': '2025-01-15T10:30:00.000Z',
        };

        final point = Point.fromJson(originalJson);
        final resultJson = point.toJson();

        expect(resultJson['id'], equals(originalJson['id']));
        expect(resultJson['user_id'], equals(originalJson['user_id']));
        expect(resultJson['content'], equals(originalJson['content']));
        expect(resultJson['geom']['type'], equals('Point'));
        expect(resultJson['geom']['coordinates'],
            equals((originalJson['geom'] as Map<String, dynamic>)['coordinates']));
        expect(resultJson['maidenhead_6char'],
            equals(originalJson['maidenhead_6char']));
        expect(resultJson['is_active'], equals(originalJson['is_active']));
        expect(resultJson['created_at'], equals(originalJson['created_at']));
      });

      test('multiple roundtrips maintain coordinate precision', () {
        final originalJson = {
          'id': 'test-id',
          'user_id': 'test-user',
          'content': 'Precision test',
          'geom': {
            'type': 'Point',
            'coordinates': [-71.0589, 42.3601],
          },
          'maidenhead_6char': 'FN42al',
          'is_active': true,
          'created_at': '2025-01-15T10:30:00.000Z',
        };

        final point1 = Point.fromJson(originalJson);
        final json1 = point1.toJson();
        final point2 = Point.fromJson(json1);
        final json2 = point2.toJson();

        expect(point1.location.latitude, equals(point2.location.latitude));
        expect(point1.location.longitude, equals(point2.location.longitude));
        expect(json1['geom']['coordinates'], equals(json2['geom']['coordinates']));
      });
    });

    group('LocationCoordinate integration', () {
      test('uses existing LocationCoordinate value object', () {
        final point = Point(
          id: 'test-id',
          userId: 'test-user',
          content: 'Integration test',
          location: const LocationCoordinate(
            latitude: 42.3601,
            longitude: -71.0589,
          ),
          maidenhead6char: 'FN42al',
          isActive: true,
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        expect(point.location, isA<LocationCoordinate>());
        expect(point.location.latitude, equals(42.3601));
        expect(point.location.longitude, equals(-71.0589));
      });

      test('LocationCoordinate validation is enforced', () {
        // Valid coordinates should work
        expect(
          () => Point(
            id: 'test-id',
            userId: 'test-user',
            content: 'Valid location',
            location: const LocationCoordinate(
              latitude: 42.3601,
              longitude: -71.0589,
            ),
            maidenhead6char: 'FN42al',
            isActive: true,
            createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
          ),
          returnsNormally,
        );

        // Invalid latitude should throw
        expect(
          () => LocationCoordinate(latitude: 91.0, longitude: 0.0),
          throwsA(isA<AssertionError>()),
        );

        // Invalid longitude should throw
        expect(
          () => LocationCoordinate(latitude: 0.0, longitude: 181.0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('works with real-world test coordinates', () {
        // Boston
        final bostonPoint = Point(
          id: 'boston-id',
          userId: 'user-id',
          content: 'Boston Commons',
          location: const LocationCoordinate(
            latitude: 42.3601,
            longitude: -71.0589,
          ),
          maidenhead6char: 'FN42al',
          isActive: true,
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        // NYC
        final nycPoint = Point(
          id: 'nyc-id',
          userId: 'user-id',
          content: 'Central Park',
          location: const LocationCoordinate(
            latitude: 40.7128,
            longitude: -74.0060,
          ),
          maidenhead6char: 'FN30ar',
          isActive: true,
          createdAt: DateTime.parse('2025-01-15T14:20:00Z'),
        );

        expect(bostonPoint.location.latitude, equals(42.3601));
        expect(nycPoint.location.latitude, equals(40.7128));
      });
    });
  });
}
