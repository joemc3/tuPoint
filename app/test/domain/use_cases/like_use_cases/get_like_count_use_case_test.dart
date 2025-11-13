import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_likes_repository.dart';
import 'package:app/domain/use_cases/like_use_cases/get_like_count_use_case.dart';
import 'package:app/domain/use_cases/requests.dart';

class MockLikesRepository extends Mock implements ILikesRepository {}

void main() {
  late MockLikesRepository mockRepository;
  late GetLikeCountUseCase useCase;

  setUp(() {
    mockRepository = MockLikesRepository();
    useCase = GetLikeCountUseCase(likesRepository: mockRepository);
  });

  group('GetLikeCountUseCase', () {
    final validPointId = 'point-123';

    group('happy path', () {
      test('returns like count for point with likes', () async {
        // Arrange
        final request = GetLikeCountRequest(pointId: validPointId);

        when(() => mockRepository.getLikeCountForPoint(validPointId))
            .thenAnswer((_) async => 5);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, equals(5));
        verify(() => mockRepository.getLikeCountForPoint(validPointId)).called(1);
      });

      test('returns 0 for point with no likes', () async {
        // Arrange
        final request = GetLikeCountRequest(pointId: validPointId);

        when(() => mockRepository.getLikeCountForPoint(validPointId))
            .thenAnswer((_) async => 0);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, equals(0));
      });

      test('returns correct count for different points', () async {
        // Arrange
        when(() => mockRepository.getLikeCountForPoint('point-1'))
            .thenAnswer((_) async => 10);
        when(() => mockRepository.getLikeCountForPoint('point-2'))
            .thenAnswer((_) async => 3);
        when(() => mockRepository.getLikeCountForPoint('point-3'))
            .thenAnswer((_) async => 0);

        // Act
        final result1 = await useCase(GetLikeCountRequest(pointId: 'point-1'));
        final result2 = await useCase(GetLikeCountRequest(pointId: 'point-2'));
        final result3 = await useCase(GetLikeCountRequest(pointId: 'point-3'));

        // Assert
        expect(result1, equals(10));
        expect(result2, equals(3));
        expect(result3, equals(0));
      });

      test('returns 1 for point with single like', () async {
        // Arrange
        final request = GetLikeCountRequest(pointId: validPointId);

        when(() => mockRepository.getLikeCountForPoint(validPointId))
            .thenAnswer((_) async => 1);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, equals(1));
      });

      test('returns large like count', () async {
        // Arrange
        final request = GetLikeCountRequest(pointId: validPointId);

        when(() => mockRepository.getLikeCountForPoint(validPointId))
            .thenAnswer((_) async => 9999);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, equals(9999));
      });
    });

    group('validation', () {
      test('throws ValidationException when pointId is empty', () async {
        // Arrange
        final request = GetLikeCountRequest(pointId: '');

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            equals('Point ID cannot be empty'),
          )),
        );
        verifyNever(() => mockRepository.getLikeCountForPoint(any()));
      });
    });

    group('repository exceptions', () {
      test('propagates DatabaseException from repository', () async {
        // Arrange
        final request = GetLikeCountRequest(pointId: validPointId);

        when(() => mockRepository.getLikeCountForPoint(validPointId))
            .thenThrow(DatabaseException('Database error'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('propagates UnauthorizedException from repository', () async {
        // Arrange
        final request = GetLikeCountRequest(pointId: validPointId);

        when(() => mockRepository.getLikeCountForPoint(validPointId))
            .thenThrow(UnauthorizedException('Not authorized'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<UnauthorizedException>()),
        );
      });
    });

    group('edge cases', () {
      test('handles UUID format for point ID', () async {
        // Arrange
        final pointUuid = '123e4567-e89b-12d3-a456-426614174000';
        final request = GetLikeCountRequest(pointId: pointUuid);

        when(() => mockRepository.getLikeCountForPoint(pointUuid))
            .thenAnswer((_) async => 7);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, equals(7));
        verify(() => mockRepository.getLikeCountForPoint(pointUuid)).called(1);
      });

      test('handles short ID format', () async {
        // Arrange
        final request = GetLikeCountRequest(pointId: 'p1');

        when(() => mockRepository.getLikeCountForPoint('p1'))
            .thenAnswer((_) async => 2);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, equals(2));
      });

      test('returns 0 for non-existent point rather than throwing', () async {
        // Arrange - According to use case comments, it should return 0 for non-existent points
        final request = GetLikeCountRequest(pointId: 'non-existent-point');

        when(() => mockRepository.getLikeCountForPoint('non-existent-point'))
            .thenAnswer((_) async => 0);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, equals(0));
      });

      test('multiple calls for same point return consistent results', () async {
        // Arrange
        final request = GetLikeCountRequest(pointId: validPointId);

        when(() => mockRepository.getLikeCountForPoint(validPointId))
            .thenAnswer((_) async => 5);

        // Act
        final result1 = await useCase(request);
        final result2 = await useCase(request);
        final result3 = await useCase(request);

        // Assert
        expect(result1, equals(5));
        expect(result2, equals(5));
        expect(result3, equals(5));
        verify(() => mockRepository.getLikeCountForPoint(validPointId)).called(3);
      });

      test('returns integer type not double', () async {
        // Arrange
        final request = GetLikeCountRequest(pointId: validPointId);

        when(() => mockRepository.getLikeCountForPoint(validPointId))
            .thenAnswer((_) async => 10);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, isA<int>());
        expect(result, equals(10));
      });
    });

    group('business logic', () {
      test('count can increase as likes are added', () async {
        // Arrange - Simulate count changing over time
        final request = GetLikeCountRequest(pointId: validPointId);

        when(() => mockRepository.getLikeCountForPoint(validPointId))
            .thenAnswer((_) async => 5);

        // Act - First call
        final initialCount = await useCase(request);
        expect(initialCount, equals(5));

        // Arrange - Count increased
        when(() => mockRepository.getLikeCountForPoint(validPointId))
            .thenAnswer((_) async => 6);

        // Act - Second call
        final updatedCount = await useCase(request);

        // Assert
        expect(updatedCount, equals(6));
      });

      test('count can decrease as likes are removed', () async {
        // Arrange - Simulate count decreasing
        final request = GetLikeCountRequest(pointId: validPointId);

        when(() => mockRepository.getLikeCountForPoint(validPointId))
            .thenAnswer((_) async => 5);

        // Act - First call
        final initialCount = await useCase(request);
        expect(initialCount, equals(5));

        // Arrange - Count decreased
        when(() => mockRepository.getLikeCountForPoint(validPointId))
            .thenAnswer((_) async => 4);

        // Act - Second call
        final updatedCount = await useCase(request);

        // Assert
        expect(updatedCount, equals(4));
      });

      test('count of 0 is valid (not an error)', () async {
        // Arrange
        final request = GetLikeCountRequest(pointId: validPointId);

        when(() => mockRepository.getLikeCountForPoint(validPointId))
            .thenAnswer((_) async => 0);

        // Act
        final result = await useCase(request);

        // Assert - Should not throw, 0 is a valid count
        expect(result, equals(0));
      });
    });
  });
}
