import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/domain/entities/profile.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_profile_repository.dart';
import 'package:app/domain/use_cases/profile_use_cases/fetch_profile_use_case.dart';
import 'package:app/domain/use_cases/requests.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late MockProfileRepository mockRepository;
  late FetchProfileUseCase useCase;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = FetchProfileUseCase(profileRepository: mockRepository);
  });

  group('FetchProfileUseCase', () {
    final validUserId = '123e4567-e89b-12d3-a456-426614174000';
    final now = DateTime.now();

    group('happy path', () {
      test('fetches profile successfully with all fields', () async {
        // Arrange
        final request = FetchProfileRequest(userId: validUserId);

        final expectedProfile = Profile(
          id: validUserId,
          username: 'testuser',
          bio: 'This is my bio',
          createdAt: now,
          updatedAt: now,
        );

        when(() => mockRepository.fetchProfileById(validUserId))
            .thenAnswer((_) async => expectedProfile);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, equals(expectedProfile));
        expect(result.id, equals(validUserId));
        expect(result.username, equals('testuser'));
        expect(result.bio, equals('This is my bio'));
        verify(() => mockRepository.fetchProfileById(validUserId)).called(1);
      });

      test('fetches profile with null bio', () async {
        // Arrange
        final request = FetchProfileRequest(userId: validUserId);

        final expectedProfile = Profile(
          id: validUserId,
          username: 'user_no_bio',
          bio: null,
          createdAt: now,
          updatedAt: null,
        );

        when(() => mockRepository.fetchProfileById(validUserId))
            .thenAnswer((_) async => expectedProfile);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.bio, isNull);
        expect(result.updatedAt, isNull);
        expect(result.username, equals('user_no_bio'));
      });

      test('fetches different profiles based on userId', () async {
        // Arrange
        final userId1 = '123e4567-e89b-12d3-a456-426614174000';
        final userId2 = '987e6543-e21b-12d3-a456-426614174999';

        final profile1 = Profile(
          id: userId1,
          username: 'user1',
          bio: 'First user',
          createdAt: now,
          updatedAt: null,
        );

        final profile2 = Profile(
          id: userId2,
          username: 'user2',
          bio: 'Second user',
          createdAt: now,
          updatedAt: null,
        );

        when(() => mockRepository.fetchProfileById(userId1))
            .thenAnswer((_) async => profile1);
        when(() => mockRepository.fetchProfileById(userId2))
            .thenAnswer((_) async => profile2);

        // Act
        final result1 = await useCase(FetchProfileRequest(userId: userId1));
        final result2 = await useCase(FetchProfileRequest(userId: userId2));

        // Assert
        expect(result1.id, equals(userId1));
        expect(result1.username, equals('user1'));
        expect(result2.id, equals(userId2));
        expect(result2.username, equals('user2'));
      });
    });

    group('validation', () {
      test('throws ValidationException when userId is empty', () async {
        // Arrange
        final request = FetchProfileRequest(userId: '');

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            equals('User ID cannot be empty'),
          )),
        );
        verifyNever(() => mockRepository.fetchProfileById(any()));
      });
    });

    group('repository exceptions', () {
      test('propagates NotFoundException when profile does not exist', () async {
        // Arrange
        final request = FetchProfileRequest(userId: validUserId);

        when(() => mockRepository.fetchProfileById(validUserId))
            .thenThrow(NotFoundException('Profile not found'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<NotFoundException>().having(
            (e) => e.message,
            'message',
            equals('Profile not found'),
          )),
        );
      });

      test('propagates UnauthorizedException from repository', () async {
        // Arrange
        final request = FetchProfileRequest(userId: validUserId);

        when(() => mockRepository.fetchProfileById(validUserId))
            .thenThrow(UnauthorizedException('Not authorized to view profile'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('propagates RepositoryException from repository', () async {
        // Arrange
        final request = FetchProfileRequest(userId: validUserId);

        when(() => mockRepository.fetchProfileById(validUserId))
            .thenThrow(DatabaseException('Database connection failed'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('edge cases', () {
      test('handles profile with very long bio', () async {
        // Arrange
        final request = FetchProfileRequest(userId: validUserId);
        final longBio = 'x' * 280;

        final expectedProfile = Profile(
          id: validUserId,
          username: 'longbiouser',
          bio: longBio,
          createdAt: now,
          updatedAt: null,
        );

        when(() => mockRepository.fetchProfileById(validUserId))
            .thenAnswer((_) async => expectedProfile);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.bio?.length, equals(280));
      });

      test('handles profile with minimum length username', () async {
        // Arrange
        final request = FetchProfileRequest(userId: validUserId);

        final expectedProfile = Profile(
          id: validUserId,
          username: 'abc',
          bio: null,
          createdAt: now,
          updatedAt: null,
        );

        when(() => mockRepository.fetchProfileById(validUserId))
            .thenAnswer((_) async => expectedProfile);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.username, equals('abc'));
        expect(result.username.length, equals(3));
      });

      test('handles profile with special characters in username', () async {
        // Arrange
        final request = FetchProfileRequest(userId: validUserId);

        final expectedProfile = Profile(
          id: validUserId,
          username: 'user_name-123',
          bio: null,
          createdAt: now,
          updatedAt: null,
        );

        when(() => mockRepository.fetchProfileById(validUserId))
            .thenAnswer((_) async => expectedProfile);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.username, equals('user_name-123'));
      });
    });
  });
}
