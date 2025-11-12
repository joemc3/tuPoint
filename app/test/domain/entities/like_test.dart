import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/like.dart';

void main() {
  group('Like', () {
    group('fromJson', () {
      test('deserializes from snake_case JSON correctly', () {
        final json = {
          'point_id': '123e4567-e89b-12d3-a456-426614174000',
          'user_id': '987fcdeb-51a2-43d7-9012-345678901234',
          'created_at': '2025-01-15T10:30:00Z',
        };

        final like = Like.fromJson(json);

        expect(like.pointId, equals('123e4567-e89b-12d3-a456-426614174000'));
        expect(like.userId, equals('987fcdeb-51a2-43d7-9012-345678901234'));
        expect(like.createdAt, equals(DateTime.parse('2025-01-15T10:30:00Z')));
      });

      test('deserializes multiple likes with different IDs', () {
        final json1 = {
          'point_id': 'point-uuid-1',
          'user_id': 'user-uuid-1',
          'created_at': '2025-01-15T10:30:00Z',
        };

        final json2 = {
          'point_id': 'point-uuid-2',
          'user_id': 'user-uuid-2',
          'created_at': '2025-01-15T11:45:00Z',
        };

        final like1 = Like.fromJson(json1);
        final like2 = Like.fromJson(json2);

        expect(like1.pointId, equals('point-uuid-1'));
        expect(like1.userId, equals('user-uuid-1'));
        expect(like2.pointId, equals('point-uuid-2'));
        expect(like2.userId, equals('user-uuid-2'));
      });
    });

    group('toJson', () {
      test('serializes to snake_case JSON correctly', () {
        final like = Like(
          pointId: '123e4567-e89b-12d3-a456-426614174000',
          userId: '987fcdeb-51a2-43d7-9012-345678901234',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final json = like.toJson();

        expect(json['point_id'], equals('123e4567-e89b-12d3-a456-426614174000'));
        expect(json['user_id'], equals('987fcdeb-51a2-43d7-9012-345678901234'));
        expect(json['created_at'], equals('2025-01-15T10:30:00.000Z'));
      });

      test('serializes multiple likes independently', () {
        final like1 = Like(
          pointId: 'point-uuid-1',
          userId: 'user-uuid-1',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final like2 = Like(
          pointId: 'point-uuid-2',
          userId: 'user-uuid-2',
          createdAt: DateTime.parse('2025-01-15T11:45:00Z'),
        );

        final json1 = like1.toJson();
        final json2 = like2.toJson();

        expect(json1['point_id'], equals('point-uuid-1'));
        expect(json2['point_id'], equals('point-uuid-2'));
      });
    });

    group('equality', () {
      test('likes with same composite key are equal', () {
        final like1 = Like(
          pointId: '123e4567-e89b-12d3-a456-426614174000',
          userId: '987fcdeb-51a2-43d7-9012-345678901234',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final like2 = Like(
          pointId: '123e4567-e89b-12d3-a456-426614174000',
          userId: '987fcdeb-51a2-43d7-9012-345678901234',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        expect(like1, equals(like2));
        expect(like1.hashCode, equals(like2.hashCode));
      });

      test('likes with different point_id are not equal', () {
        final like1 = Like(
          pointId: 'point-uuid-1',
          userId: 'user-uuid-1',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final like2 = Like(
          pointId: 'point-uuid-2',
          userId: 'user-uuid-1',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        expect(like1, isNot(equals(like2)));
      });

      test('likes with different user_id are not equal', () {
        final like1 = Like(
          pointId: 'point-uuid-1',
          userId: 'user-uuid-1',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final like2 = Like(
          pointId: 'point-uuid-1',
          userId: 'user-uuid-2',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        expect(like1, isNot(equals(like2)));
      });

      test('likes with different timestamps are not equal', () {
        final like1 = Like(
          pointId: 'point-uuid-1',
          userId: 'user-uuid-1',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final like2 = Like(
          pointId: 'point-uuid-1',
          userId: 'user-uuid-1',
          createdAt: DateTime.parse('2025-01-15T11:45:00Z'),
        );

        expect(like1, isNot(equals(like2)));
      });
    });

    group('copyWith', () {
      test('creates copy with updated point_id', () {
        final original = Like(
          pointId: 'original-point-id',
          userId: 'user-uuid-1',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final updated = original.copyWith(pointId: 'new-point-id');

        expect(updated.pointId, equals('new-point-id'));
        expect(updated.userId, equals(original.userId));
        expect(updated.createdAt, equals(original.createdAt));
      });

      test('creates copy with updated user_id', () {
        final original = Like(
          pointId: 'point-uuid-1',
          userId: 'original-user-id',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final updated = original.copyWith(userId: 'new-user-id');

        expect(updated.pointId, equals(original.pointId));
        expect(updated.userId, equals('new-user-id'));
        expect(updated.createdAt, equals(original.createdAt));
      });

      test('preserves all fields when no changes', () {
        final original = Like(
          pointId: 'point-uuid-1',
          userId: 'user-uuid-1',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('JSON roundtrip', () {
      test('deserialize then serialize preserves data', () {
        final originalJson = {
          'point_id': '123e4567-e89b-12d3-a456-426614174000',
          'user_id': '987fcdeb-51a2-43d7-9012-345678901234',
          'created_at': '2025-01-15T10:30:00.000Z',
        };

        final like = Like.fromJson(originalJson);
        final resultJson = like.toJson();

        expect(resultJson['point_id'], equals(originalJson['point_id']));
        expect(resultJson['user_id'], equals(originalJson['user_id']));
        expect(resultJson['created_at'], equals(originalJson['created_at']));
      });

      test('multiple roundtrips maintain integrity', () {
        final originalJson = {
          'point_id': 'test-point',
          'user_id': 'test-user',
          'created_at': '2025-01-15T10:30:00.000Z',
        };

        final like1 = Like.fromJson(originalJson);
        final json1 = like1.toJson();
        final like2 = Like.fromJson(json1);
        final json2 = like2.toJson();

        expect(like1, equals(like2));
        expect(json1, equals(json2));
      });
    });

    group('composite key behavior', () {
      test('represents unique constraint on point_id and user_id', () {
        // Same user liking same point - should be equal
        final like1 = Like(
          pointId: 'point-1',
          userId: 'user-1',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        final like2 = Like(
          pointId: 'point-1',
          userId: 'user-1',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        expect(like1, equals(like2));
      });

      test('different combinations create distinct likes', () {
        // User 1 likes Point 1
        final like1 = Like(
          pointId: 'point-1',
          userId: 'user-1',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        // User 2 likes Point 1 (different user, same point)
        final like2 = Like(
          pointId: 'point-1',
          userId: 'user-2',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        // User 1 likes Point 2 (same user, different point)
        final like3 = Like(
          pointId: 'point-2',
          userId: 'user-1',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
        );

        expect(like1, isNot(equals(like2)));
        expect(like1, isNot(equals(like3)));
        expect(like2, isNot(equals(like3)));
      });
    });
  });
}
