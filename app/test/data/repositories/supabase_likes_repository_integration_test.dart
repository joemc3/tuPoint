import 'package:flutter_test/flutter_test.dart';
import 'package:app/data/repositories/supabase_likes_repository.dart';
import 'package:app/data/repositories/supabase_points_repository.dart';
import 'package:app/data/repositories/supabase_profile_repository.dart';
import 'package:app/domain/value_objects/location_coordinate.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import '../../helpers/supabase_test_helper.dart';

/// Integration tests for SupabaseLikesRepository.
///
/// These tests use a real local Supabase instance running in Docker.
/// Run `supabase start` before running these tests.
void main() {
  late SupabaseLikesRepository repository;
  late SupabasePointsRepository pointsRepository;
  late SupabaseProfileRepository profileRepository;

  setUpAll(() async {
    await SupabaseTestHelper.initialize();
  });

  setUp(() async {
    repository = SupabaseLikesRepository(SupabaseTestHelper.client);
    pointsRepository = SupabasePointsRepository(SupabaseTestHelper.client);
    profileRepository = SupabaseProfileRepository(SupabaseTestHelper.client);
    await SupabaseTestHelper.cleanupTestData();
  });

  tearDown() async {
    await SupabaseTestHelper.cleanupTestData();
  }

  group('SupabaseLikesRepository Integration Tests', () {
    group('likePoint', () {
      test('likes a point successfully', () async {
        // Arrange: Create user and point
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-like@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'likeuser');

        final point = await pointsRepository.createPoint(
          userId: userId,
          content: 'Point to like',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        // Act
        final like = await repository.likePoint(
          pointId: point.id,
          userId: userId,
        );

        // Assert
        expect(like.pointId, equals(point.id));
        expect(like.userId, equals(userId));
        expect(like.createdAt, isNotNull);
      });

      test('throws UnauthorizedException when user is not authenticated',
          () async {
        // Arrange: Sign out
        await SupabaseTestHelper.signOutTestUser();

        // Act & Assert
        expect(
          () => repository.likePoint(
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
          email: 'usera-like@example.com',
          password: 'TestPass123',
        );

        // Act & Assert: Try to like as user B
        expect(
          () => repository.likePoint(
            pointId: '123e4567-e89b-12d3-a456-426614174000',
            userId: '00000000-0000-0000-0000-000000000001',
          ),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('throws NotFoundException when point does not exist', () async {
        // Arrange
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-likenotfound@example.com',
          password: 'TestPass123',
        );

        // Act & Assert
        expect(
          () => repository.likePoint(
            pointId: '00000000-0000-0000-0000-000000000099',
            userId: userId,
          ),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('throws DuplicateLikeException when user already liked the point',
          () async {
        // Arrange: Create user and point
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-duplicatelike@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'duplikeuser');

        final point = await pointsRepository.createPoint(
          userId: userId,
          content: 'Point for duplicate like',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        // Like the point once
        await repository.likePoint(pointId: point.id, userId: userId);

        // Act & Assert: Try to like again
        expect(
          () => repository.likePoint(pointId: point.id, userId: userId),
          throwsA(isA<DuplicateLikeException>()),
        );
      });
    });

    group('unlikePoint', () {
      test('unlikes a point successfully', () async {
        // Arrange: Create user, point, and like
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-unlike@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'unlikeuser');

        final point = await pointsRepository.createPoint(
          userId: userId,
          content: 'Point to unlike',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        await repository.likePoint(pointId: point.id, userId: userId);

        // Verify like exists
        final likesBefore = await repository.fetchLikesForPoint(point.id);
        expect(likesBefore.length, equals(1));

        // Act
        await repository.unlikePoint(pointId: point.id, userId: userId);

        // Assert
        final likesAfter = await repository.fetchLikesForPoint(point.id);
        expect(likesAfter, isEmpty);
      });

      test('succeeds silently when like does not exist (idempotent)', () async {
        // Arrange: Create user and point (but no like)
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-unlikeidempotent@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'idempotentuser');

        final point = await pointsRepository.createPoint(
          userId: userId,
          content: 'Point never liked',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        // Act & Assert: Should not throw
        await repository.unlikePoint(pointId: point.id, userId: userId);

        // Verify no likes
        final likes = await repository.fetchLikesForPoint(point.id);
        expect(likes, isEmpty);
      });

      test('throws UnauthorizedException when user is not authenticated',
          () async {
        // Arrange: Sign out
        await SupabaseTestHelper.signOutTestUser();

        // Act & Assert
        expect(
          () => repository.unlikePoint(
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
          email: 'usera-unlike@example.com',
          password: 'TestPass123',
        );

        // Act & Assert: Try to unlike as user B
        expect(
          () => repository.unlikePoint(
            pointId: '123e4567-e89b-12d3-a456-426614174000',
            userId: '00000000-0000-0000-0000-000000000001',
          ),
          throwsA(isA<UnauthorizedException>()),
        );
      });
    });

    group('getLikesForPoint', () {
      test('fetches all likes for a point', () async {
        // Arrange: Create user and point
        final userId1 = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'user1-getlikes@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId1, username: 'getlikesuser1');

        final point = await pointsRepository.createPoint(
          userId: userId1,
          content: 'Popular point',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        // User 1 likes it
        await repository.likePoint(pointId: point.id, userId: userId1);

        // Create user 2 and like
        await SupabaseTestHelper.signOutTestUser();
        final userId2 = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'user2-getlikes@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId2, username: 'getlikesuser2');

        await repository.likePoint(pointId: point.id, userId: userId2);

        // Act
        final likes = await repository.fetchLikesForPoint(point.id);

        // Assert
        expect(likes.length, equals(2));
        expect(likes.map((l) => l.userId), containsAll([userId1, userId2]));
      });

      test('returns empty list when point has no likes', () async {
        // Arrange: Create user and point
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-nolikes@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'nolikesuser');

        final point = await pointsRepository.createPoint(
          userId: userId,
          content: 'Unliked point',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        // Act
        final likes = await repository.fetchLikesForPoint(point.id);

        // Assert
        expect(likes, isEmpty);
      });
    });

    group('getLikesForUser', () {
      test('fetches all likes by a user', () async {
        // Arrange: Create user and multiple points
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-userlikes@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'userlikesuser');

        final point1 = await pointsRepository.createPoint(
          userId: userId,
          content: 'Point 1',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        final point2 = await pointsRepository.createPoint(
          userId: userId,
          content: 'Point 2',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        // Like both points
        await repository.likePoint(pointId: point1.id, userId: userId);
        await repository.likePoint(pointId: point2.id, userId: userId);

        // Act
        final likes = await repository.fetchLikesByUserId(userId);

        // Assert
        expect(likes.length, equals(2));
        expect(likes.map((l) => l.pointId), containsAll([point1.id, point2.id]));
      });

      test('returns empty list when user has not liked anything', () async {
        // Arrange: Create user
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-nouserlikes@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'nouserlikesuser');

        // Act
        final likes = await repository.fetchLikesByUserId(userId);

        // Assert
        expect(likes, isEmpty);
      });
    });

    group('hasUserLikedPoint', () {
      test('returns true when user has liked the point', () async {
        // Arrange: Create user and point
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-hasliked@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'haslikeduser');

        final point = await pointsRepository.createPoint(
          userId: userId,
          content: 'Liked point',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        await repository.likePoint(pointId: point.id, userId: userId);

        // Act
        final hasLiked = await repository.hasUserLikedPoint(
          pointId: point.id,
          userId: userId,
        );

        // Assert
        expect(hasLiked, isTrue);
      });

      test('returns false when user has not liked the point', () async {
        // Arrange: Create user and point
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-notliked@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'notlikeduser');

        final point = await pointsRepository.createPoint(
          userId: userId,
          content: 'Not liked point',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        // Act
        final hasLiked = await repository.hasUserLikedPoint(
          pointId: point.id,
          userId: userId,
        );

        // Assert
        expect(hasLiked, isFalse);
      });

      test('returns false after unliking a point', () async {
        // Arrange: Create user, point, and like
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-unlikedagain@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'unlikedagainuser');

        final point = await pointsRepository.createPoint(
          userId: userId,
          content: 'Point to unlike',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        await repository.likePoint(pointId: point.id, userId: userId);
        await repository.unlikePoint(pointId: point.id, userId: userId);

        // Act
        final hasLiked = await repository.hasUserLikedPoint(
          pointId: point.id,
          userId: userId,
        );

        // Assert
        expect(hasLiked, isFalse);
      });
    });

    group('getLikeCountForPoint', () {
      test('returns correct count for point with multiple likes', () async {
        // Arrange: Create users and point
        final userId1 = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'user1-count@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId1, username: 'countuser1');

        final point = await pointsRepository.createPoint(
          userId: userId1,
          content: 'Point with likes',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        await repository.likePoint(pointId: point.id, userId: userId1);

        await SupabaseTestHelper.signOutTestUser();
        final userId2 = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'user2-count@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId2, username: 'countuser2');

        await repository.likePoint(pointId: point.id, userId: userId2);

        await SupabaseTestHelper.signOutTestUser();
        final userId3 = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'user3-count@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId3, username: 'countuser3');

        await repository.likePoint(pointId: point.id, userId: userId3);

        // Act
        final count = await repository.getLikeCountForPoint(point.id);

        // Assert
        expect(count, equals(3));
      });

      test('returns 0 for point with no likes', () async {
        // Arrange: Create user and point
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-zerocount@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'zerocountuser');

        final point = await pointsRepository.createPoint(
          userId: userId,
          content: 'Point with no likes',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        // Act
        final count = await repository.getLikeCountForPoint(point.id);

        // Assert
        expect(count, equals(0));
      });

      test('decrements count after unlike', () async {
        // Arrange: Create user and point
        final userId = await SupabaseTestHelper.createAuthenticatedTestUser(
          email: 'test-decrementcount@example.com',
          password: 'TestPass123',
        );
        await profileRepository.createProfile(id: userId, username: 'decrementcountuser');

        final point = await pointsRepository.createPoint(
          userId: userId,
          content: 'Point for decrement',
          location: LocationCoordinate(latitude: 40.0, longitude: -74.0),
          maidenhead6char: 'FN20aa',
        );

        await repository.likePoint(pointId: point.id, userId: userId);

        final countBefore = await repository.getLikeCountForPoint(point.id);
        expect(countBefore, equals(1));

        // Act
        await repository.unlikePoint(pointId: point.id, userId: userId);

        // Assert
        final countAfter = await repository.getLikeCountForPoint(point.id);
        expect(countAfter, equals(0));
      });
    });
  });
}
