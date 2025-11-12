import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/entities/profile.dart';

void main() {
  group('Profile', () {
    group('fromJson', () {
      test('deserializes from snake_case JSON correctly', () {
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'username': 'testuser',
          'bio': 'Hello, I am a test user!',
          'created_at': '2025-01-15T10:30:00Z',
          'updated_at': '2025-01-16T14:45:00Z',
        };

        final profile = Profile.fromJson(json);

        expect(profile.id, equals('123e4567-e89b-12d3-a456-426614174000'));
        expect(profile.username, equals('testuser'));
        expect(profile.bio, equals('Hello, I am a test user!'));
        expect(profile.createdAt, equals(DateTime.parse('2025-01-15T10:30:00Z')));
        expect(profile.updatedAt, equals(DateTime.parse('2025-01-16T14:45:00Z')));
      });

      test('deserializes with null bio correctly', () {
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'username': 'userwithnobio',
          'bio': null,
          'created_at': '2025-01-15T10:30:00Z',
          'updated_at': null,
        };

        final profile = Profile.fromJson(json);

        expect(profile.id, equals('123e4567-e89b-12d3-a456-426614174000'));
        expect(profile.username, equals('userwithnobio'));
        expect(profile.bio, isNull);
        expect(profile.updatedAt, isNull);
      });

      test('deserializes with missing optional fields', () {
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'username': 'minimaluser',
          'created_at': '2025-01-15T10:30:00Z',
        };

        final profile = Profile.fromJson(json);

        expect(profile.id, equals('123e4567-e89b-12d3-a456-426614174000'));
        expect(profile.username, equals('minimaluser'));
        expect(profile.bio, isNull);
        expect(profile.createdAt, equals(DateTime.parse('2025-01-15T10:30:00Z')));
        expect(profile.updatedAt, isNull);
      });
    });

    group('toJson', () {
      test('serializes to snake_case JSON correctly', () {
        final profile = Profile(
          id: '123e4567-e89b-12d3-a456-426614174000',
          username: 'testuser',
          bio: 'Hello, I am a test user!',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
          updatedAt: DateTime.parse('2025-01-16T14:45:00Z'),
        );

        final json = profile.toJson();

        expect(json['id'], equals('123e4567-e89b-12d3-a456-426614174000'));
        expect(json['username'], equals('testuser'));
        expect(json['bio'], equals('Hello, I am a test user!'));
        expect(json['created_at'], equals('2025-01-15T10:30:00.000Z'));
        expect(json['updated_at'], equals('2025-01-16T14:45:00.000Z'));
      });

      test('serializes with null bio correctly', () {
        final profile = Profile(
          id: '123e4567-e89b-12d3-a456-426614174000',
          username: 'userwithnobio',
          bio: null,
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
          updatedAt: null,
        );

        final json = profile.toJson();

        expect(json['id'], equals('123e4567-e89b-12d3-a456-426614174000'));
        expect(json['username'], equals('userwithnobio'));
        expect(json['bio'], isNull);
        expect(json['created_at'], equals('2025-01-15T10:30:00.000Z'));
        expect(json['updated_at'], isNull);
      });
    });

    group('equality', () {
      test('profiles with same values are equal', () {
        final profile1 = Profile(
          id: '123e4567-e89b-12d3-a456-426614174000',
          username: 'testuser',
          bio: 'Test bio',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
          updatedAt: DateTime.parse('2025-01-16T14:45:00Z'),
        );

        final profile2 = Profile(
          id: '123e4567-e89b-12d3-a456-426614174000',
          username: 'testuser',
          bio: 'Test bio',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
          updatedAt: DateTime.parse('2025-01-16T14:45:00Z'),
        );

        expect(profile1, equals(profile2));
        expect(profile1.hashCode, equals(profile2.hashCode));
      });

      test('profiles with different values are not equal', () {
        final profile1 = Profile(
          id: '123e4567-e89b-12d3-a456-426614174000',
          username: 'testuser',
          bio: 'Test bio',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
          updatedAt: null,
        );

        final profile2 = Profile(
          id: '123e4567-e89b-12d3-a456-426614174000',
          username: 'differentuser',
          bio: 'Test bio',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
          updatedAt: null,
        );

        expect(profile1, isNot(equals(profile2)));
      });
    });

    group('copyWith', () {
      test('creates copy with updated bio', () {
        final original = Profile(
          id: '123e4567-e89b-12d3-a456-426614174000',
          username: 'testuser',
          bio: 'Original bio',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
          updatedAt: null,
        );

        final updated = original.copyWith(
          bio: 'Updated bio',
          updatedAt: DateTime.parse('2025-01-16T14:45:00Z'),
        );

        expect(updated.id, equals(original.id));
        expect(updated.username, equals(original.username));
        expect(updated.bio, equals('Updated bio'));
        expect(updated.createdAt, equals(original.createdAt));
        expect(updated.updatedAt, equals(DateTime.parse('2025-01-16T14:45:00Z')));
      });

      test('creates copy with bio set to null', () {
        final original = Profile(
          id: '123e4567-e89b-12d3-a456-426614174000',
          username: 'testuser',
          bio: 'Original bio',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
          updatedAt: null,
        );

        final updated = original.copyWith(bio: null);

        expect(updated.bio, isNull);
        expect(updated.username, equals(original.username));
      });

      test('preserves all fields when no changes', () {
        final original = Profile(
          id: '123e4567-e89b-12d3-a456-426614174000',
          username: 'testuser',
          bio: 'Original bio',
          createdAt: DateTime.parse('2025-01-15T10:30:00Z'),
          updatedAt: DateTime.parse('2025-01-16T14:45:00Z'),
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('JSON roundtrip', () {
      test('deserialize then serialize preserves data', () {
        final originalJson = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'username': 'roundtripuser',
          'bio': 'Testing JSON roundtrip',
          'created_at': '2025-01-15T10:30:00.000Z',
          'updated_at': '2025-01-16T14:45:00.000Z',
        };

        final profile = Profile.fromJson(originalJson);
        final resultJson = profile.toJson();

        expect(resultJson['id'], equals(originalJson['id']));
        expect(resultJson['username'], equals(originalJson['username']));
        expect(resultJson['bio'], equals(originalJson['bio']));
        expect(resultJson['created_at'], equals(originalJson['created_at']));
        expect(resultJson['updated_at'], equals(originalJson['updated_at']));
      });

      test('deserialize then serialize with nulls preserves structure', () {
        final originalJson = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'username': 'nulluser',
          'created_at': '2025-01-15T10:30:00.000Z',
        };

        final profile = Profile.fromJson(originalJson);
        final resultJson = profile.toJson();

        expect(resultJson['id'], equals(originalJson['id']));
        expect(resultJson['username'], equals(originalJson['username']));
        expect(resultJson['bio'], isNull);
        expect(resultJson['updated_at'], isNull);
      });
    });
  });
}
