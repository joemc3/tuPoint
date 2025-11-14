// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'point_drop_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PointDropState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() fetchingLocation,
    required TResult Function() dropping,
    required TResult Function(Point point) success,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? fetchingLocation,
    TResult? Function()? dropping,
    TResult? Function(Point point)? success,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? fetchingLocation,
    TResult Function()? dropping,
    TResult Function(Point point)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_FetchingLocation value) fetchingLocation,
    required TResult Function(_Dropping value) dropping,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_FetchingLocation value)? fetchingLocation,
    TResult? Function(_Dropping value)? dropping,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_FetchingLocation value)? fetchingLocation,
    TResult Function(_Dropping value)? dropping,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PointDropStateCopyWith<$Res> {
  factory $PointDropStateCopyWith(
    PointDropState value,
    $Res Function(PointDropState) then,
  ) = _$PointDropStateCopyWithImpl<$Res, PointDropState>;
}

/// @nodoc
class _$PointDropStateCopyWithImpl<$Res, $Val extends PointDropState>
    implements $PointDropStateCopyWith<$Res> {
  _$PointDropStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PointDropState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
    _$InitialImpl value,
    $Res Function(_$InitialImpl) then,
  ) = __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$PointDropStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PointDropState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'PointDropState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() fetchingLocation,
    required TResult Function() dropping,
    required TResult Function(Point point) success,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? fetchingLocation,
    TResult? Function()? dropping,
    TResult? Function(Point point)? success,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? fetchingLocation,
    TResult Function()? dropping,
    TResult Function(Point point)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_FetchingLocation value) fetchingLocation,
    required TResult Function(_Dropping value) dropping,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_FetchingLocation value)? fetchingLocation,
    TResult? Function(_Dropping value)? dropping,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_FetchingLocation value)? fetchingLocation,
    TResult Function(_Dropping value)? dropping,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements PointDropState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$FetchingLocationImplCopyWith<$Res> {
  factory _$$FetchingLocationImplCopyWith(
    _$FetchingLocationImpl value,
    $Res Function(_$FetchingLocationImpl) then,
  ) = __$$FetchingLocationImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FetchingLocationImplCopyWithImpl<$Res>
    extends _$PointDropStateCopyWithImpl<$Res, _$FetchingLocationImpl>
    implements _$$FetchingLocationImplCopyWith<$Res> {
  __$$FetchingLocationImplCopyWithImpl(
    _$FetchingLocationImpl _value,
    $Res Function(_$FetchingLocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PointDropState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FetchingLocationImpl implements _FetchingLocation {
  const _$FetchingLocationImpl();

  @override
  String toString() {
    return 'PointDropState.fetchingLocation()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FetchingLocationImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() fetchingLocation,
    required TResult Function() dropping,
    required TResult Function(Point point) success,
    required TResult Function(String message) error,
  }) {
    return fetchingLocation();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? fetchingLocation,
    TResult? Function()? dropping,
    TResult? Function(Point point)? success,
    TResult? Function(String message)? error,
  }) {
    return fetchingLocation?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? fetchingLocation,
    TResult Function()? dropping,
    TResult Function(Point point)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (fetchingLocation != null) {
      return fetchingLocation();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_FetchingLocation value) fetchingLocation,
    required TResult Function(_Dropping value) dropping,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return fetchingLocation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_FetchingLocation value)? fetchingLocation,
    TResult? Function(_Dropping value)? dropping,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return fetchingLocation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_FetchingLocation value)? fetchingLocation,
    TResult Function(_Dropping value)? dropping,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (fetchingLocation != null) {
      return fetchingLocation(this);
    }
    return orElse();
  }
}

abstract class _FetchingLocation implements PointDropState {
  const factory _FetchingLocation() = _$FetchingLocationImpl;
}

/// @nodoc
abstract class _$$DroppingImplCopyWith<$Res> {
  factory _$$DroppingImplCopyWith(
    _$DroppingImpl value,
    $Res Function(_$DroppingImpl) then,
  ) = __$$DroppingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DroppingImplCopyWithImpl<$Res>
    extends _$PointDropStateCopyWithImpl<$Res, _$DroppingImpl>
    implements _$$DroppingImplCopyWith<$Res> {
  __$$DroppingImplCopyWithImpl(
    _$DroppingImpl _value,
    $Res Function(_$DroppingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PointDropState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$DroppingImpl implements _Dropping {
  const _$DroppingImpl();

  @override
  String toString() {
    return 'PointDropState.dropping()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DroppingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() fetchingLocation,
    required TResult Function() dropping,
    required TResult Function(Point point) success,
    required TResult Function(String message) error,
  }) {
    return dropping();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? fetchingLocation,
    TResult? Function()? dropping,
    TResult? Function(Point point)? success,
    TResult? Function(String message)? error,
  }) {
    return dropping?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? fetchingLocation,
    TResult Function()? dropping,
    TResult Function(Point point)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (dropping != null) {
      return dropping();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_FetchingLocation value) fetchingLocation,
    required TResult Function(_Dropping value) dropping,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return dropping(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_FetchingLocation value)? fetchingLocation,
    TResult? Function(_Dropping value)? dropping,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return dropping?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_FetchingLocation value)? fetchingLocation,
    TResult Function(_Dropping value)? dropping,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (dropping != null) {
      return dropping(this);
    }
    return orElse();
  }
}

abstract class _Dropping implements PointDropState {
  const factory _Dropping() = _$DroppingImpl;
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<$Res> {
  factory _$$SuccessImplCopyWith(
    _$SuccessImpl value,
    $Res Function(_$SuccessImpl) then,
  ) = __$$SuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Point point});

  $PointCopyWith<$Res> get point;
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<$Res>
    extends _$PointDropStateCopyWithImpl<$Res, _$SuccessImpl>
    implements _$$SuccessImplCopyWith<$Res> {
  __$$SuccessImplCopyWithImpl(
    _$SuccessImpl _value,
    $Res Function(_$SuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PointDropState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? point = null}) {
    return _then(
      _$SuccessImpl(
        point: null == point
            ? _value.point
            : point // ignore: cast_nullable_to_non_nullable
                  as Point,
      ),
    );
  }

  /// Create a copy of PointDropState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PointCopyWith<$Res> get point {
    return $PointCopyWith<$Res>(_value.point, (value) {
      return _then(_value.copyWith(point: value));
    });
  }
}

/// @nodoc

class _$SuccessImpl implements _Success {
  const _$SuccessImpl({required this.point});

  @override
  final Point point;

  @override
  String toString() {
    return 'PointDropState.success(point: $point)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl &&
            (identical(other.point, point) || other.point == point));
  }

  @override
  int get hashCode => Object.hash(runtimeType, point);

  /// Create a copy of PointDropState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      __$$SuccessImplCopyWithImpl<_$SuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() fetchingLocation,
    required TResult Function() dropping,
    required TResult Function(Point point) success,
    required TResult Function(String message) error,
  }) {
    return success(point);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? fetchingLocation,
    TResult? Function()? dropping,
    TResult? Function(Point point)? success,
    TResult? Function(String message)? error,
  }) {
    return success?.call(point);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? fetchingLocation,
    TResult Function()? dropping,
    TResult Function(Point point)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(point);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_FetchingLocation value) fetchingLocation,
    required TResult Function(_Dropping value) dropping,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_FetchingLocation value)? fetchingLocation,
    TResult? Function(_Dropping value)? dropping,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_FetchingLocation value)? fetchingLocation,
    TResult Function(_Dropping value)? dropping,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _Success implements PointDropState {
  const factory _Success({required final Point point}) = _$SuccessImpl;

  Point get point;

  /// Create a copy of PointDropState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$PointDropStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PointDropState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'PointDropState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of PointDropState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() fetchingLocation,
    required TResult Function() dropping,
    required TResult Function(Point point) success,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? fetchingLocation,
    TResult? Function()? dropping,
    TResult? Function(Point point)? success,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? fetchingLocation,
    TResult Function()? dropping,
    TResult Function(Point point)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_FetchingLocation value) fetchingLocation,
    required TResult Function(_Dropping value) dropping,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_FetchingLocation value)? fetchingLocation,
    TResult? Function(_Dropping value)? dropping,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_FetchingLocation value)? fetchingLocation,
    TResult Function(_Dropping value)? dropping,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements PointDropState {
  const factory _Error({required final String message}) = _$ErrorImpl;

  String get message;

  /// Create a copy of PointDropState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
