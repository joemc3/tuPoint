import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/domain/entities/point.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_points_repository.dart';
import 'package:app/domain/use_cases/point_use_cases/fetch_user_points_use_case.dart';
import 'package:app/domain/use_cases/requests.dart';
import 'package:app/domain/value_objects/location_coordinate.dart';

class MockPointsRepository extends Mock implements IPointsRepository {}

void main() {
  late MockPointsRepository mockRepository;
  late FetchUserPointsUseCase useCase;

  setUp(() {
    mockRepository = MockPointsRepository();
    useCase = FetchUserPointsUseCase(pointsRepository: mockRepository);
  });

  group('FetchUserPointsUseCase', () {
    final validUserId = '123e4567-e89b-12d3-a456-426614174000';
    final location = LocationCoordinate(latitude: 40.7128, longitude: -74.0060);

    // Helper function to create test points with specific timestamps
    Point createTestPoint({
      required String id,
      required DateTime createdAt,
    }) {
      return Point(
        id: id,
        userId: validUserId,
        content: 'Test content for $id',
        location: location,
        maidenhead6char: 'FN20XR',
        isActive: true,
        createdAt: createdAt,
      );
    }

    group('happy path', () {
      test('fetches user points successfully', () async {
        // Arrange
        final request = FetchUserPointsRequest(userId: validUserId);
        final now = DateTime.now();

        final points = [
          createTestPoint(id: 'point-1', createdAt: now),
          createTestPoint(id: 'point-2', createdAt: now.subtract(Duration(hours: 1))),
        ];

        when(() => mockRepository.fetchPointsByUserId(validUserId))
            .thenAnswer((_) async => points);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.length, equals(2));
        verify(() => mockRepository.fetchPointsByUserId(validUserId)).called(1);
      });

      test('returns empty list when user has no points', () async {
        // Arrange
        final request = FetchUserPointsRequest(userId: validUserId);

        when(() => mockRepository.fetchPointsByUserId(validUserId))
            .thenAnswer((_) async => []);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('sorting', () {
      test('sorts points by creation date (newest first)', () async {
        // Arrange
        final request = FetchUserPointsRequest(userId: validUserId);
        final now = DateTime.now();

        // Create points in non-chronological order
        final points = [
          createTestPoint(
            id: 'point-middle',
            createdAt: now.subtract(Duration(days: 1)),
          ),
          createTestPoint(
            id: 'point-oldest',
            createdAt: now.subtract(Duration(days: 2)),
          ),
          createTestPoint(
            id: 'point-newest',
            createdAt: now,
          ),
        ];

        when(() => mockRepository.fetchPointsByUserId(validUserId))
            .thenAnswer((_) async => points);

        // Act
        final result = await useCase(request);

        // Assert - Should be sorted newest to oldest
        expect(result.length, equals(3));
        expect(result[0].id, equals('point-newest'));
        expect(result[1].id, equals('point-middle'));
        expect(result[2].id, equals('point-oldest'));
      });

      test('handles points with same creation time', () async {
        // Arrange
        final request = FetchUserPointsRequest(userId: validUserId);
        final sameTime = DateTime.now();

        final points = [
          createTestPoint(id: 'point-1', createdAt: sameTime),
          createTestPoint(id: 'point-2', createdAt: sameTime),
          createTestPoint(id: 'point-3', createdAt: sameTime),
        ];

        when(() => mockRepository.fetchPointsByUserId(validUserId))
            .thenAnswer((_) async => points);

        // Act
        final result = await useCase(request);

        // Assert - All points should be included
        expect(result.length, equals(3));
        // Order doesn't matter since they have same timestamp
      });

      test('sorts large number of points correctly', () async {
        // Arrange
        final request = FetchUserPointsRequest(userId: validUserId);
        final now = DateTime.now();

        // Create 10 points with different timestamps
        final points = List.generate(
          10,
          (index) => createTestPoint(
            id: 'point-$index',
            createdAt: now.subtract(Duration(hours: index)),
          ),
        );

        when(() => mockRepository.fetchPointsByUserId(validUserId))
            .thenAnswer((_) async => points);

        // Act
        final result = await useCase(request);

        // Assert - Should be sorted newest to oldest
        expect(result.length, equals(10));
        for (int i = 0; i < result.length - 1; i++) {
          expect(
            result[i].createdAt.isAfter(result[i + 1].createdAt) ||
                result[i].createdAt.isAtSameMomentAs(result[i + 1].createdAt),
            isTrue,
            reason: 'Point at index $i should be newer than or equal to point at ${i + 1}',
          );
        }
      });

      test('preserves all point properties during sorting', () async {
        // Arrange
        final request = FetchUserPointsRequest(userId: validUserId);
        final now = DateTime.now();

        final point1 = Point(
          id: 'point-1',
          userId: validUserId,
          content: 'First point with specific content',
          location: LocationCoordinate(latitude: 40.7128, longitude: -74.0060),
          maidenhead6char: 'FN20XR',
          isActive: true,
          createdAt: now,
        );

        final point2 = Point(
          id: 'point-2',
          userId: validUserId,
          content: 'Second point with different content',
          location: LocationCoordinate(latitude: 40.7580, longitude: -73.9855),
          maidenhead6char: 'FN30AS',
          isActive: true,
          createdAt: now.subtract(Duration(hours: 1)),
        );

        when(() => mockRepository.fetchPointsByUserId(validUserId))
            .thenAnswer((_) async => [point2, point1]);

        // Act
        final result = await useCase(request);

        // Assert - Check that all properties are preserved
        expect(result.length, equals(2));
        expect(result[0].id, equals('point-1'));
        expect(result[0].content, equals('First point with specific content'));
        expect(result[0].maidenhead6char, equals('FN20XR'));
        expect(result[1].id, equals('point-2'));
        expect(result[1].content, equals('Second point with different content'));
        expect(result[1].maidenhead6char, equals('FN30AS'));
      });
    });

    group('validation', () {
      test('throws ValidationException when userId is empty', () async {
        // Arrange
        final request = FetchUserPointsRequest(userId: '');

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            equals('User ID cannot be empty'),
          )),
        );
        verifyNever(() => mockRepository.fetchPointsByUserId(any()));
      });
    });

    group('repository exceptions', () {
      test('propagates UnauthorizedException from repository', () async {
        // Arrange
        final request = FetchUserPointsRequest(userId: validUserId);

        when(() => mockRepository.fetchPointsByUserId(validUserId))
            .thenThrow(UnauthorizedException('Not authorized'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('propagates RepositoryException from repository', () async {
        // Arrange
        final request = FetchUserPointsRequest(userId: validUserId);

        when(() => mockRepository.fetchPointsByUserId(validUserId))
            .thenThrow(DatabaseException('Database error'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('edge cases', () {
      test('handles single point correctly', () async {
        // Arrange
        final request = FetchUserPointsRequest(userId: validUserId);
        final now = DateTime.now();

        final points = [
          createTestPoint(id: 'only-point', createdAt: now),
        ];

        when(() => mockRepository.fetchPointsByUserId(validUserId))
            .thenAnswer((_) async => points);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals('only-point'));
      });

      test('fetches points for different users independently', () async {
        // Arrange
        final userId1 = 'user-1';
        final userId2 = 'user-2';
        final now = DateTime.now();

        final user1Points = [
          Point(
            id: 'user1-point',
            userId: userId1,
            content: 'User 1 content',
            location: location,
            maidenhead6char: 'FN20XR',
            isActive: true,
            createdAt: now,
          ),
        ];

        final user2Points = [
          Point(
            id: 'user2-point',
            userId: userId2,
            content: 'User 2 content',
            location: location,
            maidenhead6char: 'FN20XR',
            isActive: true,
            createdAt: now,
          ),
        ];

        when(() => mockRepository.fetchPointsByUserId(userId1))
            .thenAnswer((_) async => user1Points);
        when(() => mockRepository.fetchPointsByUserId(userId2))
            .thenAnswer((_) async => user2Points);

        // Act
        final result1 = await useCase(FetchUserPointsRequest(userId: userId1));
        final result2 = await useCase(FetchUserPointsRequest(userId: userId2));

        // Assert
        expect(result1.first.id, equals('user1-point'));
        expect(result1.first.userId, equals(userId1));
        expect(result2.first.id, equals('user2-point'));
        expect(result2.first.userId, equals(userId2));
      });

      test('handles points with very close timestamps', () async {
        // Arrange
        final request = FetchUserPointsRequest(userId: validUserId);
        final baseTime = DateTime.now();

        // Create points 1 millisecond apart
        final points = [
          createTestPoint(
            id: 'point-1',
            createdAt: baseTime,
          ),
          createTestPoint(
            id: 'point-2',
            createdAt: baseTime.add(Duration(milliseconds: 1)),
          ),
          createTestPoint(
            id: 'point-3',
            createdAt: baseTime.add(Duration(milliseconds: 2)),
          ),
        ];

        when(() => mockRepository.fetchPointsByUserId(validUserId))
            .thenAnswer((_) async => points);

        // Act
        final result = await useCase(request);

        // Assert - Should be sorted correctly even with very close timestamps
        expect(result.length, equals(3));
        expect(result[0].id, equals('point-3')); // Most recent
        expect(result[1].id, equals('point-2'));
        expect(result[2].id, equals('point-1')); // Oldest
      });
    });
  });
}
