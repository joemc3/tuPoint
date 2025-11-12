// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Point _$PointFromJson(Map<String, dynamic> json) {
  return _Point.fromJson(json);
}

/// @nodoc
mixin _$Point {
  /// Unique identifier for the Point (UUID). Primary Key.
  String get id => throw _privateConstructorUsedError;

  /// ID of the user who created this Point (Foreign Key to auth.users.id)
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;

  /// Text content of the Point (max 280 characters)
  String get content => throw _privateConstructorUsedError;

  /// Geographic location using LocationCoordinate value object.
  /// Serialized to/from PostGIS geometry format.
  @JsonKey(name: 'geom')
  @LocationCoordinateConverter()
  LocationCoordinate get location => throw _privateConstructorUsedError;

  /// 6-character Maidenhead grid locator (e.g., "FN42aa")
  /// Provides ~800m precision for generalized location display.
  @JsonKey(name: 'maidenhead_6char')
  String get maidenhead6char => throw _privateConstructorUsedError;

  /// Whether the Point is currently active. Used for soft-delete.
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Timestamp when the Point was created
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Point to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Point
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PointCopyWith<Point> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PointCopyWith<$Res> {
  factory $PointCopyWith(Point value, $Res Function(Point) then) =
      _$PointCopyWithImpl<$Res, Point>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String content,
    @JsonKey(name: 'geom')
    @LocationCoordinateConverter()
    LocationCoordinate location,
    @JsonKey(name: 'maidenhead_6char') String maidenhead6char,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$PointCopyWithImpl<$Res, $Val extends Point>
    implements $PointCopyWith<$Res> {
  _$PointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Point
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? content = null,
    Object? location = null,
    Object? maidenhead6char = null,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as LocationCoordinate,
            maidenhead6char: null == maidenhead6char
                ? _value.maidenhead6char
                : maidenhead6char // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$PointImplCopyWith<$Res> implements $PointCopyWith<$Res> {
  factory _$$PointImplCopyWith(
    _$PointImpl value,
    $Res Function(_$PointImpl) then,
  ) = __$$PointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String content,
    @JsonKey(name: 'geom')
    @LocationCoordinateConverter()
    LocationCoordinate location,
    @JsonKey(name: 'maidenhead_6char') String maidenhead6char,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$PointImplCopyWithImpl<$Res>
    extends _$PointCopyWithImpl<$Res, _$PointImpl>
    implements _$$PointImplCopyWith<$Res> {
  __$$PointImplCopyWithImpl(
    _$PointImpl _value,
    $Res Function(_$PointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Point
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? content = null,
    Object? location = null,
    Object? maidenhead6char = null,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$PointImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as LocationCoordinate,
        maidenhead6char: null == maidenhead6char
            ? _value.maidenhead6char
            : maidenhead6char // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$PointImpl implements _Point {
  const _$PointImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    required this.content,
    @JsonKey(name: 'geom')
    @LocationCoordinateConverter()
    required this.location,
    @JsonKey(name: 'maidenhead_6char') required this.maidenhead6char,
    @JsonKey(name: 'is_active') required this.isActive,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$PointImpl.fromJson(Map<String, dynamic> json) =>
      _$$PointImplFromJson(json);

  /// Unique identifier for the Point (UUID). Primary Key.
  @override
  final String id;

  /// ID of the user who created this Point (Foreign Key to auth.users.id)
  @override
  @JsonKey(name: 'user_id')
  final String userId;

  /// Text content of the Point (max 280 characters)
  @override
  final String content;

  /// Geographic location using LocationCoordinate value object.
  /// Serialized to/from PostGIS geometry format.
  @override
  @JsonKey(name: 'geom')
  @LocationCoordinateConverter()
  final LocationCoordinate location;

  /// 6-character Maidenhead grid locator (e.g., "FN42aa")
  /// Provides ~800m precision for generalized location display.
  @override
  @JsonKey(name: 'maidenhead_6char')
  final String maidenhead6char;

  /// Whether the Point is currently active. Used for soft-delete.
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Timestamp when the Point was created
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Point(id: $id, userId: $userId, content: $content, location: $location, maidenhead6char: $maidenhead6char, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PointImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.maidenhead6char, maidenhead6char) ||
                other.maidenhead6char == maidenhead6char) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    content,
    location,
    maidenhead6char,
    isActive,
    createdAt,
  );

  /// Create a copy of Point
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PointImplCopyWith<_$PointImpl> get copyWith =>
      __$$PointImplCopyWithImpl<_$PointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PointImplToJson(this);
  }
}

abstract class _Point implements Point {
  const factory _Point({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    required final String content,
    @JsonKey(name: 'geom')
    @LocationCoordinateConverter()
    required final LocationCoordinate location,
    @JsonKey(name: 'maidenhead_6char') required final String maidenhead6char,
    @JsonKey(name: 'is_active') required final bool isActive,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$PointImpl;

  factory _Point.fromJson(Map<String, dynamic> json) = _$PointImpl.fromJson;

  /// Unique identifier for the Point (UUID). Primary Key.
  @override
  String get id;

  /// ID of the user who created this Point (Foreign Key to auth.users.id)
  @override
  @JsonKey(name: 'user_id')
  String get userId;

  /// Text content of the Point (max 280 characters)
  @override
  String get content;

  /// Geographic location using LocationCoordinate value object.
  /// Serialized to/from PostGIS geometry format.
  @override
  @JsonKey(name: 'geom')
  @LocationCoordinateConverter()
  LocationCoordinate get location;

  /// 6-character Maidenhead grid locator (e.g., "FN42aa")
  /// Provides ~800m precision for generalized location display.
  @override
  @JsonKey(name: 'maidenhead_6char')
  String get maidenhead6char;

  /// Whether the Point is currently active. Used for soft-delete.
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Timestamp when the Point was created
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Point
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PointImplCopyWith<_$PointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
