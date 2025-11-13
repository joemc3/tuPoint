import 'package:flutter_test/flutter_test.dart';
import 'package:app/data/repositories/supabase_profile_repository.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import '../../helpers/supabase_test_helper.dart';

/// Integration tests for SupabaseProfileRepository.
///
/// These tests use a real local Supabase instance running in Docker.
/// Run `supabase start` before running these tests.
///
/// **Prerequisites:**
/// - Local Supabase must be running (`supabase start`)
/// - Database migrations must be applied
/// - config.toml should have `enable_confirmations = false` for auto-confirmed users
void main() {
  late SupabaseProfileRepository repository;

  setUpAll(() async {
    await SupabaseTestHelper.initialize();
  });

  setUp(() async {
    repository = SupabaseProfileRepository(SupabaseTestHelper.client);
    // Clean up any leftover test data
    await SupabaseTestHelper.cleanupTestData();
  });

  tearDown(() async {
    // Clean up after each test
    await SupabaseTestHelper.cleanupTestData();
  });

  group('SupabaseProfileRepository Integration Tests', () {
    group('createProfile', () {
      test('creates profile successfully with authenticated user', () async {
        // Arrange: Create and authenticate a test user
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-create@example.com',
          password: 'password123',
        );

        // Act: Create profile
        final profile = await repository.createProfile(
          id: userId,
          username: 'testuser',
          bio: 'Test bio',
        );

        // Assert
        expect(profile.id, equals(userId));
        expect(profile.username, equals('testuser'));
        expect(profile.bio, equals('Test bio'));
        expect(profile.createdAt, isNotNull);
      });

      test('creates profile with null bio', () async {
        // Arrange
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-nobio@example.com',
          password: 'password123',
        );

        // Act
        final profile = await repository.createProfile(
          id: userId,
          username: 'usernobio',
        );

        // Assert
        expect(profile.id, equals(userId));
        expect(profile.username, equals('usernobio'));
        expect(profile.bio, isNull);
      });

      test('throws UnauthorizedException when user is not authenticated',
          () async {
        // Arrange: Sign out
        await SupabaseTestHelper.signOutTestUser();

        // Act & Assert
        expect(
          () => repository.createProfile(
            id: '123e4567-e89b-12d3-a456-426614174000',
            username: 'testuser',
          ),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('throws UnauthorizedException when userId does not match authenticated user',
          () async {
        // Arrange: Create user A
        await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'usera@example.com',
          password: 'password123',
        );

        // Act & Assert: Try to create profile for user B
        expect(
          () => repository.createProfile(
            id: '00000000-0000-0000-0000-000000000001',
            username: 'userb',
          ),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('throws ValidationException when username is empty', () async {
        // Arrange
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-emptyusername@example.com',
          password: 'password123',
        );

        // Act & Assert
        expect(
          () => repository.createProfile(
            id: userId,
            username: '',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('throws DuplicateUsernameException when username already exists',
          () async {
        // Arrange: Create first user with username
        final userId1 = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'user1@example.com',
          password: 'password123',
        );
        await repository.createProfile(
          id: userId1,
          username: 'duplicateuser',
        );

        // Create second user
        await SupabaseTestHelper.signOutTestUser();
        final userId2 = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'user2@example.com',
          password: 'password123',
        );

        // Act & Assert: Try to create profile with same username
        expect(
          () => repository.createProfile(
            id: userId2,
            username: 'duplicateuser',
          ),
          throwsA(isA<DuplicateUsernameException>()),
        );
      });
    });

    group('fetchProfileById', () {
      test('fetches existing profile successfully', () async {
        // Arrange: Create a profile
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-fetch@example.com',
          password: 'password123',
        );
        await repository.createProfile(
          id: userId,
          username: 'fetchtest',
          bio: 'Fetch me',
        );

        // Act
        final profile = await repository.fetchProfileById(userId);

        // Assert
        expect(profile.id, equals(userId));
        expect(profile.username, equals('fetchtest'));
        expect(profile.bio, equals('Fetch me'));
      });

      test('throws NotFoundException when profile does not exist', () async {
        // Arrange: Create authenticated user (needed for SELECT RLS)
        await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-auth@example.com',
          password: 'password123',
        );

        // Act & Assert
        expect(
          () => repository.fetchProfileById('00000000-0000-0000-0000-000000000099'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('fetchProfileByUsername', () {
      test('fetches existing profile by username', () async {
        // Arrange
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-username@example.com',
          password: 'password123',
        );
        await repository.createProfile(
          id: userId,
          username: 'uniqueuser',
          bio: 'Find me by username',
        );

        // Act
        final profile = await repository.fetchProfileByUsername('uniqueuser');

        // Assert
        expect(profile.id, equals(userId));
        expect(profile.username, equals('uniqueuser'));
        expect(profile.bio, equals('Find me by username'));
      });

      test('throws NotFoundException when username does not exist', () async {
        // Arrange: Create authenticated user
        await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-auth2@example.com',
          password: 'password123',
        );

        // Act & Assert
        expect(
          () => repository.fetchProfileByUsername('nonexistentuser'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('fetchAllProfiles', () {
      test('fetches all profiles sorted by created_at descending', () async {
        // Arrange: Create multiple profiles
        final userId1 = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'user1-all@example.com',
          password: 'password123',
        );
        await repository.createProfile(id: userId1, username: 'user1');

        await SupabaseTestHelper.signOutTestUser();
        final userId2 = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'user2-all@example.com',
          password: 'password123',
        );
        await repository.createProfile(id: userId2, username: 'user2');

        await SupabaseTestHelper.signOutTestUser();
        final userId3 = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'user3-all@example.com',
          password: 'password123',
        );
        await repository.createProfile(id: userId3, username: 'user3');

        // Act
        final profiles = await repository.fetchAllProfiles();

        // Assert
        expect(profiles.length, equals(3));
        // Should be sorted by created_at descending (newest first)
        expect(profiles[0].username, equals('user3'));
        expect(profiles[1].username, equals('user2'));
        expect(profiles[2].username, equals('user1'));
      });

      test('returns empty list when no profiles exist', () async {
        // Arrange: Create authenticated user but no profile
        await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-empty@example.com',
          password: 'password123',
        );

        // Act
        final profiles = await repository.fetchAllProfiles();

        // Assert
        expect(profiles, isEmpty);
      });
    });

    group('updateProfile', () {
      test('updates username successfully', () async {
        // Arrange: Create profile
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-update@example.com',
          password: 'password123',
        );
        await repository.createProfile(
          id: userId,
          username: 'oldusername',
          bio: 'Old bio',
        );

        // Act
        final updatedProfile = await repository.updateProfile(
          userId: userId,
          username: 'newusername',
        );

        // Assert
        expect(updatedProfile.id, equals(userId));
        expect(updatedProfile.username, equals('newusername'));
        expect(updatedProfile.bio, equals('Old bio')); // Bio unchanged
        expect(updatedProfile.updatedAt, isNotNull);
      });

      test('updates bio successfully', () async {
        // Arrange
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-updatebio@example.com',
          password: 'password123',
        );
        await repository.createProfile(
          id: userId,
          username: 'keepusername',
          bio: 'Old bio',
        );

        // Act
        final updatedProfile = await repository.updateProfile(
          userId: userId,
          bio: 'New bio',
        );

        // Assert
        expect(updatedProfile.username, equals('keepusername')); // Username unchanged
        expect(updatedProfile.bio, equals('New bio'));
      });

      test('updates both username and bio', () async {
        // Arrange
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-updateboth@example.com',
          password: 'password123',
        );
        await repository.createProfile(
          id: userId,
          username: 'oldusername',
          bio: 'Old bio',
        );

        // Act
        final updatedProfile = await repository.updateProfile(
          userId: userId,
          username: 'newusername',
          bio: 'New bio',
        );

        // Assert
        expect(updatedProfile.username, equals('newusername'));
        expect(updatedProfile.bio, equals('New bio'));
      });

      test('returns current profile when no fields to update', () async {
        // Arrange
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-noupdate@example.com',
          password: 'password123',
        );
        await repository.createProfile(
          id: userId,
          username: 'sameusername',
          bio: 'Same bio',
        );

        // Act
        final profile = await repository.updateProfile(userId: userId);

        // Assert
        expect(profile.username, equals('sameusername'));
        expect(profile.bio, equals('Same bio'));
      });

      test('throws UnauthorizedException when user is not authenticated',
          () async {
        // Arrange: Sign out
        await SupabaseTestHelper.signOutTestUser();

        // Act & Assert
        expect(
          () => repository.updateProfile(
            userId: '123e4567-e89b-12d3-a456-426614174000',
            username: 'newname',
          ),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('throws UnauthorizedException when userId does not match authenticated user',
          () async {
        // Arrange: Create user A
        await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'usera-update@example.com',
          password: 'password123',
        );

        // Act & Assert: Try to update profile for user B
        expect(
          () => repository.updateProfile(
            userId: '00000000-0000-0000-0000-000000000001',
            username: 'newname',
          ),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('throws ValidationException when username is empty', () async {
        // Arrange
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-emptyupdate@example.com',
          password: 'password123',
        );
        await repository.createProfile(id: userId, username: 'oldname');

        // Act & Assert
        expect(
          () => repository.updateProfile(
            userId: userId,
            username: '',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('throws DuplicateUsernameException when new username already exists',
          () async {
        // Arrange: Create two users
        final userId1 = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'user1-dup@example.com',
          password: 'password123',
        );
        await repository.createProfile(id: userId1, username: 'existinguser');

        await SupabaseTestHelper.signOutTestUser();
        final userId2 = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'user2-dup@example.com',
          password: 'password123',
        );
        await repository.createProfile(id: userId2, username: 'anotheruser');

        // Act & Assert: Try to update user2's username to user1's username
        expect(
          () => repository.updateProfile(
            userId: userId2,
            username: 'existinguser',
          ),
          throwsA(isA<DuplicateUsernameException>()),
        );
      });
    });
  });
}
