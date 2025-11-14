import 'package:flutter_test/flutter_test.dart';
import 'package:app/data/repositories/supabase_points_repository.dart';
import 'package:app/data/repositories/supabase_profile_repository.dart';
import 'package:app/domain/value_objects/location_coordinate.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import '../../helpers/supabase_test_helper.dart';

/// Integration tests for SupabasePointsRepository.
///
/// These tests use a real local Supabase instance running in Docker.
/// Run `supabase start` before running these tests.
void main() {
  late SupabasePointsRepository repository;
  late SupabaseProfileRepository profileRepository;

  setUpAll(() async {
    await SupabaseTestHelper.initialize();
  });

  setUp(() async {
    repository = SupabasePointsRepository(SupabaseTestHelper.client);
    profileRepository = SupabaseProfileRepository(SupabaseTestHelper.client);
    await SupabaseTestHelper.cleanupTestData();
  });

  tearDown() async {
    await SupabaseTestHelper.cleanupTestData();
  }

  group('SupabasePointsRepository Integration Tests', () {
    group('createPoint', () {
      test('creates point successfully with valid data', () async {
        // Arrange: Create authenticated user with profile
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-point@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'pointuser');

        final location = LocationCoordinate(latitude: 40.7128, longitude: -74.0060);

        // Act
        final point = await repository.createPoint(
          userId: userId,
          content: 'Test point content',
          location: location,
          maidenhead6char: 'FN20xr',
        );

        // Assert
        expect(point.userId, equals(userId));
        expect(point.content, equals('Test point content'));
        expect(point.location.latitude, equals(40.7128));
        expect(point.location.longitude, equals(-74.0060));
        expect(point.maidenhead6char, equals('FN20xr'));
        expect(point.isActive, isTrue);
        expect(point.createdAt, isNotNull);
      });

      test('throws UnauthorizedException when user is not authenticated',
          () async {
        // Arrange: Sign out
        await SupabaseTestHelper.signOutTestUser();

        // Act & Assert
        expect(
          () => repository.createPoint(
            userId: '123e4567-e89b-12d3-a456-426614174000',
            content: 'Test content',
            location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
            maidenhead6char: 'FN20aa',
          ),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('throws UnauthorizedException when userId does not match authenticated user',
          () async {
        // Arrange: Create user A
        await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'usera-point@example.com',
          password: 'TestPass123',
        );

        // Act & Assert: Try to create point for user B
        expect(
          () => repository.createPoint(
            userId: '00000000-0000-0000-0000-000000000001',
            content: 'Test content',
            location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
            maidenhead6char: 'FN20aa',
          ),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('throws ValidationException when content exceeds 280 characters',
          () async {
        // Arrange
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-longcontent@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'longuser');

        final longContent = 'a' * 281; // 281 characters

        // Act & Assert
        expect(
          () => repository.createPoint(
            userId: userId,
            content: longContent,
            location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
            maidenhead6char: 'FN20aa',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('accepts content with exactly 280 characters', () async {
        // Arrange
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-exact280@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'exact280');

        final exactContent = 'a' * 280; // Exactly 280 characters

        // Act
        final point = await repository.createPoint(
          userId: userId,
          content: exactContent,
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        // Assert
        expect(point.content.length, equals(280));
      });
    });

    group('fetchAllActivePoints', () {
      test('fetches all active points sorted by created_at descending',
          () async {
        // Arrange: Create user and multiple points
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-fetchall@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'fetchalluser');

        final location = LocationCoordinate(latitude: 40.0, longitude: -74.0);

        await repository.createPoint(
          userId: userId,
          content: 'Point 1',
          location: location,
          maidenhead6char: 'FN20aa',
        );

        await repository.createPoint(
          userId: userId,
          content: 'Point 2',
          location: location,
          maidenhead6char: 'FN20aa',
        );

        await repository.createPoint(
          userId: userId,
          content: 'Point 3',
          location: location,
          maidenhead6char: 'FN20aa',
        );

        // Act
        final points = await repository.fetchAllActivePoints();

        // Assert
        expect(points.length, equals(3));
        // Should be sorted by created_at descending (newest first)
        expect(points[0].content, equals('Point 3'));
        expect(points[1].content, equals('Point 2'));
        expect(points[2].content, equals('Point 1'));
      });

      test('returns only active points', () async {
        // Arrange: Create user and points
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-activeonly@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'activeuser');

        final location = LocationCoordinate(latitude: 40.0, longitude: -74.0);

        final point1 = await repository.createPoint(
          userId: userId,
          content: 'Active point',
          location: location,
          maidenhead6char: 'FN20aa',
        );

        final point2 = await repository.createPoint(
          userId: userId,
          content: 'To be deactivated',
          location: location,
          maidenhead6char: 'FN20aa',
        );

        // Deactivate point2
        await repository.deactivatePoint(pointId: point2.id, userId: userId);

        // Act
        final points = await repository.fetchAllActivePoints();

        // Assert
        expect(points.length, equals(1));
        expect(points[0].id, equals(point1.id));
        expect(points[0].content, equals('Active point'));
      });

      test('returns empty list when no active points exist', () async {
        // Arrange: Create authenticated user
        await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-nopoints@example.com',
          password: 'TestPass123',
        );

        // Act
        final points = await repository.fetchAllActivePoints();

        // Assert
        expect(points, isEmpty);
      });
    });

    group('fetchPointById', () {
      test('fetches existing point successfully', () async {
        // Arrange
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-fetchbyid@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'fetchbyiduser');

        final createdPoint = await repository.createPoint(
          userId: userId,
          content: 'Point to fetch',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        // Act
        final point = await repository.fetchPointById(createdPoint.id);

        // Assert
        expect(point.id, equals(createdPoint.id));
        expect(point.content, equals('Point to fetch'));
      });

      test('throws NotFoundException when point does not exist', () async {
        // Arrange: Create authenticated user
        await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-notfound@example.com',
          password: 'TestPass123',
        );

        // Act & Assert
        expect(
          () => repository.fetchPointById('00000000-0000-0000-0000-000000000099'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('fetchPointsByUserId', () {
      test('fetches all points for a user sorted by created_at descending',
          () async {
        // Arrange: Create two users
        final userId1 = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'user1-points@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId1, username: 'user1points');

        final location = LocationCoordinate(latitude: 40.0, longitude: -74.0);

        await repository.createPoint(
          userId: userId1,
          content: 'User 1 Point 1',
          location: location,
          maidenhead6char: 'FN20aa',
        );

        await repository.createPoint(
          userId: userId1,
          content: 'User 1 Point 2',
          location: location,
          maidenhead6char: 'FN20aa',
        );

        // Create user 2 with a point
        await SupabaseTestHelper.signOutTestUser();
        final userId2 = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'user2-points@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId2, username: 'user2points');

        await repository.createPoint(
          userId: userId2,
          content: 'User 2 Point 1',
          location: location,
          maidenhead6char: 'FN20aa',
        );

        // Act: Fetch user1's points
        final user1Points = await repository.fetchPointsByUserId(userId1);

        // Assert
        expect(user1Points.length, equals(2));
        expect(user1Points[0].content, equals('User 1 Point 2'));
        expect(user1Points[1].content, equals('User 1 Point 1'));
      });

      test('returns empty list when user has no points', () async {
        // Arrange: Create authenticated user
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-nopoints2@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'nopointsuser');

        // Act
        final points = await repository.fetchPointsByUserId(userId);

        // Assert
        expect(points, isEmpty);
      });
    });

    group('updatePointContent', () {
      test('updates content successfully', () async {
        // Arrange
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-update@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'updateuser');

        final point = await repository.createPoint(
          userId: userId,
          content: 'Original content',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        // Act
        final updatedPoint = await repository.updatePointContent(
          pointId: point.id,
          userId: userId,
          content: 'Updated content',
        );

        // Assert
        expect(updatedPoint.id, equals(point.id));
        expect(updatedPoint.content, equals('Updated content'));
      });

      test('throws UnauthorizedException when user is not authenticated',
          () async {
        // Arrange: Sign out
        await SupabaseTestHelper.signOutTestUser();

        // Act & Assert
        expect(
          () => repository.updatePointContent(
            pointId: '123e4567-e89b-12d3-a456-426614174000',
            userId: '123e4567-e89b-12d3-a456-426614174000',
            content: 'New content',
          ),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('throws UnauthorizedException when userId does not match authenticated user',
          () async {
        // Arrange: Create user A
        await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'usera-update@example.com',
          password: 'TestPass123',
        );

        // Act & Assert: Try to update as user B
        expect(
          () => repository.updatePointContent(
            pointId: '123e4567-e89b-12d3-a456-426614174000',
            userId: '00000000-0000-0000-0000-000000000001',
            content: 'New content',
          ),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('throws ValidationException when content exceeds 280 characters',
          () async {
        // Arrange
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-updatelong@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'updatelonguser');

        final point = await repository.createPoint(
          userId: userId,
          content: 'Original',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        final longContent = 'a' * 281;

        // Act & Assert
        expect(
          () => repository.updatePointContent(
            pointId: point.id,
            userId: userId,
            content: longContent,
          ),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('deactivatePoint', () {
      test('deactivates point successfully', () async {
        // Arrange
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-deactivate@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'deactivateuser');

        final point = await repository.createPoint(
          userId: userId,
          content: 'To be deactivated',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        expect(point.isActive, isTrue);

        // Act
        await repository.deactivatePoint(
          pointId: point.id,
          userId: userId,
        );

        // Assert: Verify it's not in active points list
        final activePoints = await repository.fetchAllActivePoints();
        expect(activePoints.where((p) => p.id == point.id), isEmpty);
      });

      test('throws UnauthorizedException when user is not authenticated',
          () async {
        // Arrange: Sign out
        await SupabaseTestHelper.signOutTestUser();

        // Act & Assert
        expect(
          () => repository.deactivatePoint(
            pointId: '123e4567-e89b-12d3-a456-426614174000',
            userId: '123e4567-e89b-12d3-a456-426614174000',
          ),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('throws UnauthorizedException when userId does not match authenticated user',
          () async {
        // Arrange: Create user A
        await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'usera-deactivate@example.com',
          password: 'TestPass123',
        );

        // Act & Assert: Try to deactivate as user B
        expect(
          () => repository.deactivatePoint(
            pointId: '123e4567-e89b-12d3-a456-426614174000',
            userId: '00000000-0000-0000-0000-000000000001',
          ),
          throwsA(isA<UnauthorizedException>()),
        );
      });
    });
  });
}
