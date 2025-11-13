import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/domain/entities/like.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_likes_repository.dart';
import 'package:app/domain/use_cases/like_use_cases/like_point_use_case.dart';
import 'package:app/domain/use_cases/requests.dart';

class MockLikesRepository extends Mock implements ILikesRepository {}

void main() {
  late MockLikesRepository mockRepository;
  late LikePointUseCase useCase;

  setUp(() {
    mockRepository = MockLikesRepository();
    useCase = LikePointUseCase(likesRepository: mockRepository);
  });

  group('LikePointUseCase', () {
    final validPointId = 'point-123';
    final validUserId = 'user-456';
    final now = DateTime.now();

    group('happy path', () {
      test('creates like successfully with valid inputs', () async {
        // Arrange
        final request = LikePointRequest(
          pointId: validPointId,
          userId: validUserId,
        );

        final expectedLike = Like(
          pointId: validPointId,
          userId: validUserId,
          createdAt: now,
        );

        when(() => mockRepository.likePoint(
              pointId: validPointId,
              userId: validUserId,
            )).thenAnswer((_) async => expectedLike);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, equals(expectedLike));
        expect(result.pointId, equals(validPointId));
        expect(result.userId, equals(validUserId));
        verify(() => mockRepository.likePoint(
              pointId: validPointId,
              userId: validUserId,
            )).called(1);
      });

      test('creates likes for different point-user combinations', () async {
        // Arrange
        final request1 = LikePointRequest(
          pointId: 'point-1',
          userId: 'user-1',
        );

        final request2 = LikePointRequest(
          pointId: 'point-2',
          userId: 'user-2',
        );

        final like1 = Like(
          pointId: 'point-1',
          userId: 'user-1',
          createdAt: now,
        );

        final like2 = Like(
          pointId: 'point-2',
          userId: 'user-2',
          createdAt: now,
        );

        when(() => mockRepository.likePoint(
              pointId: 'point-1',
              userId: 'user-1',
            )).thenAnswer((_) async => like1);

        when(() => mockRepository.likePoint(
              pointId: 'point-2',
              userId: 'user-2',
            )).thenAnswer((_) async => like2);

        // Act
        final result1 = await useCase(request1);
        final result2 = await useCase(request2);

        // Assert
        expect(result1.pointId, equals('point-1'));
        expect(result1.userId, equals('user-1'));
        expect(result2.pointId, equals('point-2'));
        expect(result2.userId, equals('user-2'));
      });

      test('allows same user to like different points', () async {
        // Arrange
        final userId = 'user-1';

        final request1 = LikePointRequest(
          pointId: 'point-1',
          userId: userId,
        );

        final request2 = LikePointRequest(
          pointId: 'point-2',
          userId: userId,
        );

        final like1 = Like(pointId: 'point-1', userId: userId, createdAt: now);
        final like2 = Like(pointId: 'point-2', userId: userId, createdAt: now);

        when(() => mockRepository.likePoint(pointId: 'point-1', userId: userId))
            .thenAnswer((_) async => like1);
        when(() => mockRepository.likePoint(pointId: 'point-2', userId: userId))
            .thenAnswer((_) async => like2);

        // Act
        final result1 = await useCase(request1);
        final result2 = await useCase(request2);

        // Assert
        expect(result1.pointId, equals('point-1'));
        expect(result2.pointId, equals('point-2'));
      });

      test('allows different users to like same point', () async {
        // Arrange
        final pointId = 'point-1';

        final request1 = LikePointRequest(
          pointId: pointId,
          userId: 'user-1',
        );

        final request2 = LikePointRequest(
          pointId: pointId,
          userId: 'user-2',
        );

        final like1 = Like(pointId: pointId, userId: 'user-1', createdAt: now);
        final like2 = Like(pointId: pointId, userId: 'user-2', createdAt: now);

        when(() => mockRepository.likePoint(pointId: pointId, userId: 'user-1'))
            .thenAnswer((_) async => like1);
        when(() => mockRepository.likePoint(pointId: pointId, userId: 'user-2'))
            .thenAnswer((_) async => like2);

        // Act
        final result1 = await useCase(request1);
        final result2 = await useCase(request2);

        // Assert
        expect(result1.userId, equals('user-1'));
        expect(result2.userId, equals('user-2'));
      });
    });

    group('validation - pointId', () {
      test('throws ValidationException when pointId is empty', () async {
        // Arrange
        final request = LikePointRequest(
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
        verifyNever(() => mockRepository.likePoint(
              pointId: any(named: 'pointId'),
              userId: any(named: 'userId'),
            ));
      });
    });

    group('validation - userId', () {
      test('throws ValidationException when userId is empty', () async {
        // Arrange
        final request = LikePointRequest(
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
        verifyNever(() => mockRepository.likePoint(
              pointId: any(named: 'pointId'),
              userId: any(named: 'userId'),
            ));
      });
    });

    group('validation - both fields', () {
      test('throws ValidationException when both pointId and userId are empty', () async {
        // Arrange
        final request = LikePointRequest(
          pointId: '',
          userId: '',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>()),
        );
        verifyNever(() => mockRepository.likePoint(
              pointId: any(named: 'pointId'),
              userId: any(named: 'userId'),
            ));
      });
    });

    group('repository exceptions', () {
      test('propagates UnauthorizedException from repository', () async {
        // Arrange
        final request = LikePointRequest(
          pointId: validPointId,
          userId: validUserId,
        );

        when(() => mockRepository.likePoint(
              pointId: validPointId,
              userId: validUserId,
            )).thenThrow(UnauthorizedException('Not authorized to like point'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('propagates DuplicateLikeException when user already liked point', () async {
        // Arrange - User trying to like the same point twice
        final request = LikePointRequest(
          pointId: validPointId,
          userId: validUserId,
        );

        when(() => mockRepository.likePoint(
              pointId: validPointId,
              userId: validUserId,
            )).thenThrow(DuplicateLikeException(validPointId, validUserId));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<DuplicateLikeException>().having(
            (e) => e.message,
            'message',
            contains('already liked'),
          )),
        );
      });

      test('propagates NotFoundException when point does not exist', () async {
        // Arrange
        final request = LikePointRequest(
          pointId: 'non-existent-point',
          userId: validUserId,
        );

        when(() => mockRepository.likePoint(
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
        final request = LikePointRequest(
          pointId: validPointId,
          userId: validUserId,
        );

        when(() => mockRepository.likePoint(
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

        final request = LikePointRequest(
          pointId: pointUuid,
          userId: userUuid,
        );

        final expectedLike = Like(
          pointId: pointUuid,
          userId: userUuid,
          createdAt: now,
        );

        when(() => mockRepository.likePoint(
              pointId: pointUuid,
              userId: userUuid,
            )).thenAnswer((_) async => expectedLike);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.pointId, equals(pointUuid));
        expect(result.userId, equals(userUuid));
      });

      test('handles short ID formats', () async {
        // Arrange
        final request = LikePointRequest(
          pointId: 'p1',
          userId: 'u1',
        );

        final expectedLike = Like(
          pointId: 'p1',
          userId: 'u1',
          createdAt: now,
        );

        when(() => mockRepository.likePoint(
              pointId: 'p1',
              userId: 'u1',
            )).thenAnswer((_) async => expectedLike);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.pointId, equals('p1'));
        expect(result.userId, equals('u1'));
      });
    });
  });
}
