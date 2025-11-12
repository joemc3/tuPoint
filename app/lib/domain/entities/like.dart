import 'package:freezed_annotation/freezed_annotation.dart';

part 'like.freezed.dart';
part 'like.g.dart';

/// Represents a like interaction on a Point in the tuPoint application.
///
/// A Like represents a social interaction where a user likes a specific Point.
/// The combination of [pointId] and [userId] must be unique (composite key).
///
/// Maps to the `likes` table in the database schema.
@freezed
class Like with _$Like {
  /// Creates a Like instance.
  ///
  /// [pointId] - ID of the Point being liked
  /// [userId] - ID of the user who performed the like action
  /// [createdAt] - Timestamp when the like was created
  const factory Like({
    /// ID of the Point being liked (Foreign Key to points.id)
    @JsonKey(name: 'point_id') required String pointId,

    /// ID of the user who liked the Point (Foreign Key to auth.users.id)
    @JsonKey(name: 'user_id') required String userId,

    /// Timestamp when the like was created
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Like;

  /// Creates a Like instance from JSON data.
  ///
  /// Maps snake_case JSON keys from the database to camelCase Dart fields.
  factory Like.fromJson(Map<String, dynamic> json) => _$LikeFromJson(json);
}
