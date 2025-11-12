import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// Represents a user profile in the tuPoint application.
///
/// Contains user metadata including username and optional bio.
/// Maps to the `profile` table in the database schema.
///
/// Fields are immutable and use Freezed for equality, copyWith,
/// and JSON serialization support.
@freezed
class Profile with _$Profile {
  /// Creates a Profile instance.
  ///
  /// [id] - Unique identifier, matches auth.users.id (UUID format)
  /// [username] - Unique username for the user (required)
  /// [bio] - Optional user biography or description
  /// [createdAt] - Timestamp when the profile was created
  /// [updatedAt] - Timestamp of the last profile update (nullable)
  const factory Profile({
    /// Unique identifier (UUID). Primary Key and Foreign Key to auth.users.id
    required String id,

    /// Unique username for the user. Must be unique across all profiles.
    required String username,

    /// Optional biography or description text
    String? bio,

    /// Timestamp when the profile was created
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Timestamp of the last profile update (nullable)
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Profile;

  /// Creates a Profile instance from JSON data.
  ///
  /// Maps snake_case JSON keys from the database to camelCase Dart fields.
  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
