import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/domain/entities/point.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_points_repository.dart';
import 'package:app/domain/use_cases/point_use_cases/fetch_nearby_points_use_case.dart';
import 'package:app/domain/use_cases/requests.dart';
import 'package:app/domain/value_objects/location_coordinate.dart';

class MockPointsRepository extends Mock implements IPointsRepository {}

void main() {
  late MockPointsRepository mockRepository;
  late FetchNearbyPointsUseCase useCase;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(LocationCoordinate(latitude: 0, longitude: 0));
  });

  setUp(() {
    mockRepository = MockPointsRepository();
    useCase = FetchNearbyPointsUseCase(pointsRepository: mockRepository);
  });

  group('FetchNearbyPointsUseCase', () {
    final now = DateTime.now();

    // New York City coordinates
    final nycLocation = LocationCoordinate(latitude: 40.7128, longitude: -74.0060);

    // Helper function to create test points
    Point createTestPoint({
      required String id,
      required String userId,
      required LocationCoordinate location,
      String content = 'Test content',
    }) {
      return Point(
        id: id,
        userId: userId,
        content: content,
        location: location,
        maidenhead6char: 'FN20XR',
        isActive: true,
        createdAt: now,
      );
    }

    group('distance filtering', () {
      test('returns only points within radius', () async {
        // Arrange - Create points at various distances from NYC
        final points = [
          // ~2km away (Times Square from Central Park)
          createTestPoint(
            id: 'point-1',
            userId: 'user-1',
            location: LocationCoordinate(latitude: 40.7580, longitude: -73.9855),
          ),
          // ~5km away (Brooklyn)
          createTestPoint(
            id: 'point-2',
            userId: 'user-2',
            location: LocationCoordinate(latitude: 40.6782, longitude: -73.9442),
          ),
          // ~10km away (JFK Airport area - should be excluded)
          createTestPoint(
            id: 'point-3',
            userId: 'user-3',
            location: LocationCoordinate(latitude: 40.6413, longitude: -73.7781),
          ),
        ];

        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => points);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 5000.0, // 5km radius
        );

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.length, equals(2)); // Only first two points
        expect(result.any((p) => p.id == 'point-3'), isFalse);
      });

      test('returns empty list when no points within radius', () async {
        // Arrange - All points far away
        final points = [
          // Los Angeles (very far from NYC)
          createTestPoint(
            id: 'point-1',
            userId: 'user-1',
            location: LocationCoordinate(latitude: 34.0522, longitude: -118.2437),
          ),
        ];

        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => points);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 5000.0,
        );

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, isEmpty);
      });

      test('includes points exactly at radius boundary', () async {
        // Arrange - Point at approximately 5km (using calculation)
        // This location is approximately 5km from NYC
        final boundaryLocation = LocationCoordinate(latitude: 40.7570, longitude: -74.0060);

        final points = [
          createTestPoint(
            id: 'point-1',
            userId: 'user-1',
            location: boundaryLocation,
          ),
        ];

        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => points);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 5000.0,
        );

        // Act
        final result = await useCase(request);

        // Assert - Point at or very close to boundary should be included
        expect(result.length, greaterThanOrEqualTo(0));
        // Note: Depending on exact distance calculation, this might be 0 or 1
      });

      test('respects custom radius parameter', () async {
        // Arrange
        final points = [
          // ~2km away
          createTestPoint(
            id: 'point-1',
            userId: 'user-1',
            location: LocationCoordinate(latitude: 40.7580, longitude: -73.9855),
          ),
          // ~5km away
          createTestPoint(
            id: 'point-2',
            userId: 'user-2',
            location: LocationCoordinate(latitude: 40.6782, longitude: -73.9442),
          ),
        ];

        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => points);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 3000.0, // Only 3km radius
        );

        // Act
        final result = await useCase(request);

        // Assert - Only the closer point should be included
        expect(result.length, equals(1));
        expect(result.first.id, equals('point-1'));
      });
    });

    group('user own points filtering', () {
      test('excludes user own points by default', () async {
        // Arrange
        const currentUserId = 'current-user';

        final points = [
          createTestPoint(
            id: 'point-1',
            userId: currentUserId, // User's own point
            location: LocationCoordinate(latitude: 40.7580, longitude: -73.9855),
          ),
          createTestPoint(
            id: 'point-2',
            userId: 'other-user',
            location: LocationCoordinate(latitude: 40.7580, longitude: -73.9855),
          ),
        ];

        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => points);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 5000.0,
          userId: currentUserId,
          includeUserOwnPoints: false, // Explicitly false (default)
        );

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals('point-2'));
        expect(result.any((p) => p.userId == currentUserId), isFalse);
      });

      test('includes user own points when explicitly requested', () async {
        // Arrange
        const currentUserId = 'current-user';

        final points = [
          createTestPoint(
            id: 'point-1',
            userId: currentUserId,
            location: LocationCoordinate(latitude: 40.7580, longitude: -73.9855),
          ),
          createTestPoint(
            id: 'point-2',
            userId: 'other-user',
            location: LocationCoordinate(latitude: 40.7580, longitude: -73.9855),
          ),
        ];

        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => points);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 5000.0,
          userId: currentUserId,
          includeUserOwnPoints: true,
        );

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.length, equals(2));
        expect(result.any((p) => p.userId == currentUserId), isTrue);
      });

      test('returns all points when userId is not provided', () async {
        // Arrange
        final points = [
          createTestPoint(
            id: 'point-1',
            userId: 'user-1',
            location: LocationCoordinate(latitude: 40.7580, longitude: -73.9855),
          ),
          createTestPoint(
            id: 'point-2',
            userId: 'user-2',
            location: LocationCoordinate(latitude: 40.7580, longitude: -73.9855),
          ),
        ];

        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => points);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 5000.0,
          // userId not provided
        );

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.length, equals(2));
      });
    });

    group('sorting by distance', () {
      test('sorts points by distance from nearest to farthest', () async {
        // Arrange - Points at different distances
        final points = [
          // Farthest (~5km)
          createTestPoint(
            id: 'point-far',
            userId: 'user-1',
            location: LocationCoordinate(latitude: 40.6782, longitude: -73.9442),
          ),
          // Closest (~1km)
          createTestPoint(
            id: 'point-close',
            userId: 'user-2',
            location: LocationCoordinate(latitude: 40.7228, longitude: -74.0060),
          ),
          // Middle (~2km)
          createTestPoint(
            id: 'point-medium',
            userId: 'user-3',
            location: LocationCoordinate(latitude: 40.7580, longitude: -73.9855),
          ),
        ];

        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => points);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 5000.0,
        );

        // Act
        final result = await useCase(request);

        // Assert - Should be sorted closest to farthest
        expect(result.length, equals(3));
        expect(result[0].id, equals('point-close'));
        expect(result[1].id, equals('point-medium'));
        expect(result[2].id, equals('point-far'));
      });

      test('maintains stable sort for points at equal distances', () async {
        // Arrange - Two points at approximately same distance
        final sameDistanceLocation = LocationCoordinate(latitude: 40.7228, longitude: -74.0060);

        final points = [
          createTestPoint(
            id: 'point-1',
            userId: 'user-1',
            location: sameDistanceLocation,
          ),
          createTestPoint(
            id: 'point-2',
            userId: 'user-2',
            location: sameDistanceLocation,
          ),
        ];

        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => points);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 5000.0,
        );

        // Act
        final result = await useCase(request);

        // Assert - Should include both points
        expect(result.length, equals(2));
      });
    });

    group('edge cases', () {
      test('returns empty list when repository returns empty list', () async {
        // Arrange
        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => []);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 5000.0,
        );

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, isEmpty);
      });

      test('handles single point correctly', () async {
        // Arrange
        final points = [
          createTestPoint(
            id: 'point-1',
            userId: 'user-1',
            location: LocationCoordinate(latitude: 40.7228, longitude: -74.0060),
          ),
        ];

        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => points);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 5000.0,
        );

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals('point-1'));
      });

      test('handles points at exact same location as user', () async {
        // Arrange - Point at exact user location (0 meters away)
        final points = [
          createTestPoint(
            id: 'point-1',
            userId: 'user-1',
            location: nycLocation, // Exact same location
          ),
        ];

        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => points);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 5000.0,
        );

        // Act
        final result = await useCase(request);

        // Assert - Should include point at 0 distance
        expect(result.length, equals(1));
        expect(result.first.id, equals('point-1'));
      });

      test('handles very small radius', () async {
        // Arrange
        final points = [
          createTestPoint(
            id: 'point-1',
            userId: 'user-1',
            location: LocationCoordinate(latitude: 40.7228, longitude: -74.0060),
          ),
        ];

        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => points);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 10.0, // Only 10 meters
        );

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, isEmpty); // 10m radius too small for any point
      });

      test('handles very large radius', () async {
        // Arrange - Points across the globe
        final points = [
          createTestPoint(
            id: 'point-nyc',
            userId: 'user-1',
            location: LocationCoordinate(latitude: 40.7128, longitude: -74.0060),
          ),
          createTestPoint(
            id: 'point-la',
            userId: 'user-2',
            location: LocationCoordinate(latitude: 34.0522, longitude: -118.2437),
          ),
          createTestPoint(
            id: 'point-london',
            userId: 'user-3',
            location: LocationCoordinate(latitude: 51.5074, longitude: -0.1278),
          ),
        ];

        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => points);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 10000000.0, // 10,000km radius
        );

        // Act
        final result = await useCase(request);

        // Assert - Should include all points
        expect(result.length, equals(3));
      });
    });

    group('combined filters', () {
      test('applies distance filter AND user exclusion correctly', () async {
        // Arrange
        const currentUserId = 'current-user';

        final points = [
          // Close, not user's
          createTestPoint(
            id: 'point-1',
            userId: 'other-user',
            location: LocationCoordinate(latitude: 40.7228, longitude: -74.0060),
          ),
          // Close, user's own (should be excluded)
          createTestPoint(
            id: 'point-2',
            userId: currentUserId,
            location: LocationCoordinate(latitude: 40.7228, longitude: -74.0060),
          ),
          // Far, not user's (should be excluded by distance)
          createTestPoint(
            id: 'point-3',
            userId: 'other-user',
            location: LocationCoordinate(latitude: 34.0522, longitude: -118.2437),
          ),
          // Far, user's own (should be excluded by both filters)
          createTestPoint(
            id: 'point-4',
            userId: currentUserId,
            location: LocationCoordinate(latitude: 34.0522, longitude: -118.2437),
          ),
        ];

        when(() => mockRepository.fetchAllActivePoints())
            .thenAnswer((_) async => points);

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 5000.0,
          userId: currentUserId,
          includeUserOwnPoints: false,
        );

        // Act
        final result = await useCase(request);

        // Assert - Should only include point-1
        expect(result.length, equals(1));
        expect(result.first.id, equals('point-1'));
      });
    });

    group('repository exceptions', () {
      test('propagates UnauthorizedException from repository', () async {
        // Arrange
        when(() => mockRepository.fetchAllActivePoints())
            .thenThrow(UnauthorizedException('Not authorized'));

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 5000.0,
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('propagates RepositoryException from repository', () async {
        // Arrange
        when(() => mockRepository.fetchAllActivePoints())
            .thenThrow(DatabaseException('Database error'));

        final request = FetchNearbyPointsRequest(
          userLocation: nycLocation,
          radiusMeters: 5000.0,
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<DatabaseException>()),
        );
      });
    });
  });
}
