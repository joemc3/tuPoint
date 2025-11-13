import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/domain/entities/profile.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_profile_repository.dart';
import 'package:app/domain/use_cases/profile_use_cases/create_profile_use_case.dart';
import 'package:app/domain/use_cases/requests.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late MockProfileRepository mockRepository;
  late CreateProfileUseCase useCase;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = CreateProfileUseCase(profileRepository: mockRepository);
  });

  group('CreateProfileUseCase', () {
    final validUserId = '123e4567-e89b-12d3-a456-426614174000';
    final now = DateTime.now();

    group('happy path', () {
      test('creates profile with valid inputs', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'valid_user',
          bio: 'This is my bio',
        );

        final expectedProfile = Profile(
          id: validUserId,
          username: 'valid_user',
          bio: 'This is my bio',
          createdAt: now,
          updatedAt: null,
        );

        when(() => mockRepository.createProfile(
              id: validUserId,
              username: 'valid_user',
              bio: 'This is my bio',
            )).thenAnswer((_) async => expectedProfile);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result, equals(expectedProfile));
        verify(() => mockRepository.createProfile(
              id: validUserId,
              username: 'valid_user',
              bio: 'This is my bio',
            )).called(1);
      });

      test('creates profile with null bio', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'user_no_bio',
        );

        final expectedProfile = Profile(
          id: validUserId,
          username: 'user_no_bio',
          bio: null,
          createdAt: now,
          updatedAt: null,
        );

        when(() => mockRepository.createProfile(
              id: validUserId,
              username: 'user_no_bio',
              bio: null,
            )).thenAnswer((_) async => expectedProfile);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.bio, isNull);
        verify(() => mockRepository.createProfile(
              id: validUserId,
              username: 'user_no_bio',
              bio: null,
            )).called(1);
      });

      test('trims and lowercases username', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: '  TrimMe  ',
          bio: 'Test',
        );

        final expectedProfile = Profile(
          id: validUserId,
          username: 'trimme',
          bio: 'Test',
          createdAt: now,
          updatedAt: null,
        );

        when(() => mockRepository.createProfile(
              id: validUserId,
              username: 'trimme',
              bio: 'Test',
            )).thenAnswer((_) async => expectedProfile);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.username, equals('trimme'));
        verify(() => mockRepository.createProfile(
              id: validUserId,
              username: 'trimme',
              bio: 'Test',
            )).called(1);
      });

      test('trims bio but preserves case', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'testuser',
          bio: '  Leading and trailing spaces  ',
        );

        final expectedProfile = Profile(
          id: validUserId,
          username: 'testuser',
          bio: 'Leading and trailing spaces',
          createdAt: now,
          updatedAt: null,
        );

        when(() => mockRepository.createProfile(
              id: validUserId,
              username: 'testuser',
              bio: 'Leading and trailing spaces',
            )).thenAnswer((_) async => expectedProfile);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.bio, equals('Leading and trailing spaces'));
      });

      test('accepts username at minimum length boundary (3 chars)', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'abc',
        );

        final expectedProfile = Profile(
          id: validUserId,
          username: 'abc',
          bio: null,
          createdAt: now,
          updatedAt: null,
        );

        when(() => mockRepository.createProfile(
              id: validUserId,
              username: 'abc',
              bio: null,
            )).thenAnswer((_) async => expectedProfile);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.username, equals('abc'));
      });

      test('accepts username at maximum length boundary (32 chars)', () async {
        // Arrange
        final longUsername = 'a' * 32;
        final request = CreateProfileRequest(
          userId: validUserId,
          username: longUsername,
        );

        final expectedProfile = Profile(
          id: validUserId,
          username: longUsername,
          bio: null,
          createdAt: now,
          updatedAt: null,
        );

        when(() => mockRepository.createProfile(
              id: validUserId,
              username: longUsername,
              bio: null,
            )).thenAnswer((_) async => expectedProfile);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.username, equals(longUsername));
      });

      test('accepts username with underscores and dashes', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'valid_user-name123',
        );

        final expectedProfile = Profile(
          id: validUserId,
          username: 'valid_user-name123',
          bio: null,
          createdAt: now,
          updatedAt: null,
        );

        when(() => mockRepository.createProfile(
              id: validUserId,
              username: 'valid_user-name123',
              bio: null,
            )).thenAnswer((_) async => expectedProfile);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.username, equals('valid_user-name123'));
      });

      test('accepts bio at maximum length boundary (280 chars)', () async {
        // Arrange
        final longBio = 'x' * 280;
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'testuser',
          bio: longBio,
        );

        final expectedProfile = Profile(
          id: validUserId,
          username: 'testuser',
          bio: longBio,
          createdAt: now,
          updatedAt: null,
        );

        when(() => mockRepository.createProfile(
              id: validUserId,
              username: 'testuser',
              bio: longBio,
            )).thenAnswer((_) async => expectedProfile);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.bio?.length, equals(280));
      });
    });

    group('validation - userId', () {
      test('throws ValidationException when userId is empty', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: '',
          username: 'validuser',
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
        verifyNever(() => mockRepository.createProfile(
              id: any(named: 'id'),
              username: any(named: 'username'),
              bio: any(named: 'bio'),
            ));
      });
    });

    group('validation - username', () {
      test('throws ValidationException when username is empty', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: '',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            equals('Username cannot be empty'),
          )),
        );
      });

      test('throws ValidationException when username is only whitespace', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: '   ',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            equals('Username cannot be empty'),
          )),
        );
      });

      test('throws ValidationException when username is too short (< 3 chars)', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'ab',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Username must be 3-32 characters'),
          )),
        );
      });

      test('throws ValidationException when username is too long (> 32 chars)', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'a' * 33,
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Username must be 3-32 characters'),
          )),
        );
      });

      test('throws ValidationException when username contains special characters', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'invalid@user',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Username can only contain letters, numbers, underscore, and dash'),
          )),
        );
      });

      test('throws ValidationException when username contains spaces', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'invalid user',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Username can only contain letters, numbers, underscore, and dash'),
          )),
        );
      });

      test('throws ValidationException when username starts with underscore', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: '_username',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Username cannot start or end with underscore or dash'),
          )),
        );
      });

      test('throws ValidationException when username starts with dash', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: '-username',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Username cannot start or end with underscore or dash'),
          )),
        );
      });

      test('throws ValidationException when username ends with underscore', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'username_',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Username cannot start or end with underscore or dash'),
          )),
        );
      });

      test('throws ValidationException when username ends with dash', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'username-',
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Username cannot start or end with underscore or dash'),
          )),
        );
      });
    });

    group('validation - bio', () {
      test('throws ValidationException when bio exceeds 280 characters', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'validuser',
          bio: 'x' * 281,
        );

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Bio exceeds 280 characters'),
          )),
        );
      });

      test('does not throw when bio with whitespace trims to valid length', () async {
        // Arrange
        final bioWithSpaces = '  ${'x' * 280}  '; // 284 total, 280 after trim
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'validuser',
          bio: bioWithSpaces,
        );

        final expectedProfile = Profile(
          id: validUserId,
          username: 'validuser',
          bio: 'x' * 280,
          createdAt: now,
          updatedAt: null,
        );

        when(() => mockRepository.createProfile(
              id: validUserId,
              username: 'validuser',
              bio: 'x' * 280,
            )).thenAnswer((_) async => expectedProfile);

        // Act
        final result = await useCase(request);

        // Assert
        expect(result.bio?.length, equals(280));
      });
    });

    group('repository exceptions', () {
      test('propagates UnauthorizedException from repository', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'testuser',
        );

        when(() => mockRepository.createProfile(
              id: validUserId,
              username: 'testuser',
              bio: null,
            )).thenThrow(UnauthorizedException('Not authorized'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('propagates ConflictException from repository (duplicate username)', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'existinguser',
        );

        when(() => mockRepository.createProfile(
              id: validUserId,
              username: 'existinguser',
              bio: null,
            )).thenThrow(DuplicateUsernameException('Username already exists'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<DuplicateUsernameException>()),
        );
      });

      test('propagates RepositoryException from repository', () async {
        // Arrange
        final request = CreateProfileRequest(
          userId: validUserId,
          username: 'testuser',
        );

        when(() => mockRepository.createProfile(
              id: validUserId,
              username: 'testuser',
              bio: null,
            )).thenThrow(DatabaseException('Database error'));

        // Act & Assert
        expect(
          () => useCase(request),
          throwsA(isA<DatabaseException>()),
        );
      });
    });
  });
}
