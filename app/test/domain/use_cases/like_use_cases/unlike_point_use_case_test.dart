import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_likes_repository.dart';
import 'package:app/domain/use_cases/like_use_cases/unlike_point_use_case.dart';
import 'package:app/domain/use_cases/requests.dart';

class MockLikesRepository extends Mock implements ILikesRepository {}

void main() {
  late MockLikesRepository mockRepository;
  late UnlikePointUseCase useCase;

  setUp(() {
    mockRepository = MockLikesRepository();
    useCase = UnlikePointUseCase(likesRepository: mockRepository);
  });

  group('UnlikePointUseCase', () {
    final validPointId = 'point-123';
    final validUserId = 'user-456';

    group('happy path', () {
      test('unlikes point successfully with valid inputs', () async {
        // Arrange
        final request = UnlikePointRequest(
          pointId: validPointId,
          userId: validUserId,
        );

        when(() => mockRepository.unlikePoint(
              pointId: validPointId,
              userId: validUserId,
            )).thenAnswer((_) async => {});

        // Act
        await useCase(request);

        // Assert
        verify(() => mockRepository.unlikePoint(
              pointId: validPointId,
              userId: validUserId,
            )).called(1);
      });

      test('unlikes different point-user combinations', () async {
        // Arrange
        final request1 = UnlikePointRequest(
          pointId: 'point-1',
          userId: 'user-1',
        );

        final request2 = UnlikePointRequest(
          pointId: 'point-2',
          userId: 'user-2',
        );

        when(() => mockRepository.unlikePoint(
              pointId: 'point-1',
              userId: 'user-1',
            )).thenAnswer((_) async => {});

        when(() => mockRepository.unlikePoint(
              pointId: 'point-2',
              userId: 'user-2',
            )).thenAnswer((_) async => {});

        // Act
        await useCase(request1);
        await useCase(request2);

        // Assert
        verify(() => mockRepository.unlikePoint(
              pointId: 'point-1',
              userId: 'user-1',
            )).called(1);
        verify(() => mockRepository.unlikePoint(
              pointId: 'point-2',
              userId: 'user-2',
            )).called(1);
      });

      test('allows same user to unlike different points', () async {
        // Arrange
        final userId = 'user-1';

        final request1 = UnlikePointRequest(
          pointId: 'point-1',
          userId: userId,
        );

        final request2 = UnlikePointRequest(
          pointId: 'point-2',
          userId: userId,
        );

        when(() => mockRepository.unlikePoint(pointId: 'point-1', userId: userId))
            .thenAnswer((_) async => {});
        when(() => mockRepository.unlikePoint(pointId: 'point-2', userId: userId))
            .thenAnswer((_) async => {});

        // Act
        await useCase(request1);
        await useCase(request2);

        // Assert
        verify(() => mockRepository.unlikePoint(pointId: 'point-1', userId: userId)).called(1);
        verify(() => mockRepository.unlikePoint(pointId: 'point-2', userId: userId)).called(1);
      });

      test('allows different users to unlike same point', () async {
        // Arrange
        final pointId = 'point-1';

        final request1 = UnlikePointRequest(
          pointId: pointId,
          userId: 'user-1',
        );

        final request2 = UnlikePointRequest(
          pointId: pointId,
          userId: 'user-2',
        );

        when(() => mockRepository.unlikePoint(pointId: pointId, userId: 'user-1'))
            .thenAnswer((_) async => {});
        when(() => mockRepository.unlikePoint(pointId: pointId, userId: 'user-2'))
            .thenAnswer((_) async => {});

        // Act
        await useCase(request1);
        await useCase(request2);

        // Assert
        verify(() => mockRepository.unlikePoint(pointId: pointId, userId: 'user-1')).called(1);
        verify(() => mockRepository.unlikePoint(pointId: pointId, userId: 'user-2')).called(1);
      });
    });

    group('validation - pointId', () {
      test('throws ValidationException when pointId is empty', () async {
        // Arrange
        final request = UnlikePointRequest(
          pointId: '',
          userId: validUserId,
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            equals('Point ID cannot be empty'),
          )),
        );
        verifyNever(() => mockRepository.unlikePoint(
              pointId: any(named: 'pointId'),
              userId: any(named: 'userId'),
            ));
      });
    });

    group('validation - userId', () {
      test('throws ValidationException when userId is empty', () async {
        // Arrange
        final request = UnlikePointRequest(
          pointId: validPointId,
          userId: '',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            equals('User ID cannot be empty'),
          )),
        );
        verifyNever(() => mockRepository.unlikePoint(
              pointId: any(named: 'pointId'),
              userId: any(named: 'userId'),
            ));
      });
    });

    group('validation - both fields', () {
      test('throws ValidationException when both pointId and userId are empty', () async {
        // Arrange
        final request = UnlikePointRequest(
          pointId: '',
          userId: '',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>()),
        );
        verifyNever(() => mockRepository.unlikePoint(
              pointId: any(named: 'pointId'),
              userId: any(named: 'userId'),
            ));
      });
    });

    group('repository exceptions', () {
      test('propagates UnauthorizedException from repository', () async {
        // Arrange
        final request = UnlikePointRequest(
          pointId: validPointId,
          userId: validUserId,
        );

        when(() => mockRepository.unlikePoint(
              pointId: validPointId,
              userId: validUserId,
            )).thenThrow(UnauthorizedException('Not authorized to unlike point'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('propagates NotFoundException when like does not exist', () async {
        // Arrange - User trying to unlike a point they never liked
        final request = UnlikePointRequest(
          pointId: validPointId,
          userId: validUserId,
        );

        when(() => mockRepository.unlikePoint(
              pointId: validPointId,
              userId: validUserId,
            )).thenThrow(NotFoundException('Like not found'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<NotFoundException>().having(
            (e) => e.message,
            'message',
            contains('not found'),
          )),
        );
      });

      test('propagates NotFoundException when point does not exist', () async {
        // Arrange
        final request = UnlikePointRequest(
          pointId: 'non-existent-point',
          userId: validUserId,
        );

        when(() => mockRepository.unlikePoint(
              pointId: 'non-existent-point',
              userId: validUserId,
            )).thenThrow(NotFoundException('Point not found'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('propagates DatabaseException from repository', () async {
        // Arrange
        final request = UnlikePointRequest(
          pointId: validPointId,
          userId: validUserId,
        );

        when(() => mockRepository.unlikePoint(
              pointId: validPointId,
              userId: validUserId,
            )).thenThrow(DatabaseException('Database error'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('edge cases', () {
      test('handles UUID format for point and user IDs', () async {
        // Arrange
        final pointUuid = '123e4567-e89b-12d3-a456-426614174000';
        final userUuid = '987e6543-e21b-12d3-a456-426614174999';

        final request = UnlikePointRequest(
          pointId: pointUuid,
          userId: userUuid,
        );

        when(() => mockRepository.unlikePoint(
              pointId: pointUuid,
              userId: userUuid,
            )).thenAnswer((_) async => {});

        // Act
        await useCase(request);

        // Assert
        verify(() => mockRepository.unlikePoint(
              pointId: pointUuid,
              userId: userUuid,
            )).called(1);
      });

      test('handles short ID formats', () async {
        // Arrange
        final request = UnlikePointRequest(
          pointId: 'p1',
          userId: 'u1',
        );

        when(() => mockRepository.unlikePoint(
              pointId: 'p1',
              userId: 'u1',
            )).thenAnswer((_) async => {});

        // Act
        await useCase(request);

        // Assert
        verify(() => mockRepository.unlikePoint(
              pointId: 'p1',
              userId: 'u1',
            )).called(1);
      });

      test('unlike operation is idempotent-like in intent', () async {
        // Arrange - First unlike should succeed, second should throw NotFoundException
        final request = UnlikePointRequest(
          pointId: validPointId,
          userId: validUserId,
        );

        // First call succeeds
        when(() => mockRepository.unlikePoint(
              pointId: validPointId,
              userId: validUserId,
            )).thenAnswer((_) async {});

        // Act
        await useCase(request); // First unlike succeeds

        // Arrange - Second call throws
        when(() => mockRepository.unlikePoint(
              pointId: validPointId,
              userId: validUserId,
            )).thenThrow(NotFoundException('Like not found'));

        // Assert - Second unlike should throw
        expect(
          () => useCase(request),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('returns void and completes successfully', () async {
        // Arrange
        final request = UnlikePointRequest(
          pointId: validPointId,
          userId: validUserId,
        );

        when(() => mockRepository.unlikePoint(
              pointId: validPointId,
              userId: validUserId,
            )).thenAnswer((_) async => {});

        // Act
        final result = useCase(request);

        // Assert - Should complete without error and return void
        expect(result, completes);
      });
    });
  });
}
