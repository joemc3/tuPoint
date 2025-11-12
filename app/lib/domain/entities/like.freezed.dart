// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'like.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Like _$LikeFromJson(Map<String, dynamic> json) {
  return _Like.fromJson(json);
}

/// @nodoc
mixin _$Like {
  /// ID of the Point being liked (Foreign Key to points.id)
  @JsonKey(name: 'point_id')
  String get pointId => throw _privateConstructorUsedError;

  /// ID of the user who liked the Point (Foreign Key to auth.users.id)
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;

  /// Timestamp when the like was created
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Like to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Like
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LikeCopyWith<Like> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LikeCopyWith<$Res> {
  factory $LikeCopyWith(Like value, $Res Function(Like) then) =
      _$LikeCopyWithImpl<$Res, Like>;
  @useResult
  $Res call({
    @JsonKey(name: 'point_id') String pointId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$LikeCopyWithImpl<$Res, $Val extends Like>
    implements $LikeCopyWith<$Res> {
  _$LikeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Like
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pointId = null,
    Object? userId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            pointId: null == pointId
                ? _value.pointId
                : pointId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LikeImplCopyWith<$Res> implements $LikeCopyWith<$Res> {
  factory _$$LikeImplCopyWith(
    _$LikeImpl value,
    $Res Function(_$LikeImpl) then,
  ) = __$$LikeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'point_id') String pointId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$LikeImplCopyWithImpl<$Res>
    extends _$LikeCopyWithImpl<$Res, _$LikeImpl>
    implements _$$LikeImplCopyWith<$Res> {
  __$$LikeImplCopyWithImpl(_$LikeImpl _value, $Res Function(_$LikeImpl) _then)
    : super(_value, _then);

  /// Create a copy of Like
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pointId = null,
    Object? userId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$LikeImpl(
        pointId: null == pointId
            ? _value.pointId
            : pointId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LikeImpl implements _Like {
  const _$LikeImpl({
    @JsonKey(name: 'point_id') required this.pointId,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$LikeImpl.fromJson(Map<String, dynamic> json) =>
      _$$LikeImplFromJson(json);

  /// ID of the Point being liked (Foreign Key to points.id)
  @override
  @JsonKey(name: 'point_id')
  final String pointId;

  /// ID of the user who liked the Point (Foreign Key to auth.users.id)
  @override
  @JsonKey(name: 'user_id')
  final String userId;

  /// Timestamp when the like was created
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Like(pointId: $pointId, userId: $userId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LikeImpl &&
            (identical(other.pointId, pointId) || other.pointId == pointId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, pointId, userId, createdAt);

  /// Create a copy of Like
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LikeImplCopyWith<_$LikeImpl> get copyWith =>
      __$$LikeImplCopyWithImpl<_$LikeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LikeImplToJson(this);
  }
}

abstract class _Like implements Like {
  const factory _Like({
    @JsonKey(name: 'point_id') required final String pointId,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$LikeImpl;

  factory _Like.fromJson(Map<String, dynamic> json) = _$LikeImpl.fromJson;

  /// ID of the Point being liked (Foreign Key to points.id)
  @override
  @JsonKey(name: 'point_id')
  String get pointId;

  /// ID of the user who liked the Point (Foreign Key to auth.users.id)
  @override
  @JsonKey(name: 'user_id')
  String get userId;

  /// Timestamp when the like was created
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Like
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LikeImplCopyWith<_$LikeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
