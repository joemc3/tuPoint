// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_service_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$LocationServiceState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(LocationCoordinate location) available,
    required TResult Function(String message, bool isPermanent)
    permissionDenied,
    required TResult Function(String message) serviceDisabled,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(LocationCoordinate location)? available,
    TResult? Function(String message, bool isPermanent)? permissionDenied,
    TResult? Function(String message)? serviceDisabled,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(LocationCoordinate location)? available,
    TResult Function(String message, bool isPermanent)? permissionDenied,
    TResult Function(String message)? serviceDisabled,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Available value) available,
    required TResult Function(_PermissionDenied value) permissionDenied,
    required TResult Function(_ServiceDisabled value) serviceDisabled,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Available value)? available,
    TResult? Function(_PermissionDenied value)? permissionDenied,
    TResult? Function(_ServiceDisabled value)? serviceDisabled,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Available value)? available,
    TResult Function(_PermissionDenied value)? permissionDenied,
    TResult Function(_ServiceDisabled value)? serviceDisabled,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationServiceStateCopyWith<$Res> {
  factory $LocationServiceStateCopyWith(
    LocationServiceState value,
    $Res Function(LocationServiceState) then,
  ) = _$LocationServiceStateCopyWithImpl<$Res, LocationServiceState>;
}

/// @nodoc
class _$LocationServiceStateCopyWithImpl<
  $Res,
  $Val extends LocationServiceState
>
    implements $LocationServiceStateCopyWith<$Res> {
  _$LocationServiceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationServiceState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$LocationServiceStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationServiceState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'LocationServiceState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(LocationCoordinate location) available,
    required TResult Function(String message, bool isPermanent)
    permissionDenied,
    required TResult Function(String message) serviceDisabled,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(LocationCoordinate location)? available,
    TResult? Function(String message, bool isPermanent)? permissionDenied,
    TResult? Function(String message)? serviceDisabled,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(LocationCoordinate location)? available,
    TResult Function(String message, bool isPermanent)? permissionDenied,
    TResult Function(String message)? serviceDisabled,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Available value) available,
    required TResult Function(_PermissionDenied value) permissionDenied,
    required TResult Function(_ServiceDisabled value) serviceDisabled,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Available value)? available,
    TResult? Function(_PermissionDenied value)? permissionDenied,
    TResult? Function(_ServiceDisabled value)? serviceDisabled,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Available value)? available,
    TResult Function(_PermissionDenied value)? permissionDenied,
    TResult Function(_ServiceDisabled value)? serviceDisabled,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements LocationServiceState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$AvailableImplCopyWith<$Res> {
  factory _$$AvailableImplCopyWith(
    _$AvailableImpl value,
    $Res Function(_$AvailableImpl) then,
  ) = __$$AvailableImplCopyWithImpl<$Res>;
  @useResult
  $Res call({LocationCoordinate location});
}

/// @nodoc
class __$$AvailableImplCopyWithImpl<$Res>
    extends _$LocationServiceStateCopyWithImpl<$Res, _$AvailableImpl>
    implements _$$AvailableImplCopyWith<$Res> {
  __$$AvailableImplCopyWithImpl(
    _$AvailableImpl _value,
    $Res Function(_$AvailableImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationServiceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? location = null}) {
    return _then(
      _$AvailableImpl(
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as LocationCoordinate,
      ),
    );
  }
}

/// @nodoc

class _$AvailableImpl implements _Available {
  const _$AvailableImpl({required this.location});

  @override
  final LocationCoordinate location;

  @override
  String toString() {
    return 'LocationServiceState.available(location: $location)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailableImpl &&
            (identical(other.location, location) ||
                other.location == location));
  }

  @override
  int get hashCode => Object.hash(runtimeType, location);

  /// Create a copy of LocationServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailableImplCopyWith<_$AvailableImpl> get copyWith =>
      __$$AvailableImplCopyWithImpl<_$AvailableImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(LocationCoordinate location) available,
    required TResult Function(String message, bool isPermanent)
    permissionDenied,
    required TResult Function(String message) serviceDisabled,
    required TResult Function(String message) error,
  }) {
    return available(location);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(LocationCoordinate location)? available,
    TResult? Function(String message, bool isPermanent)? permissionDenied,
    TResult? Function(String message)? serviceDisabled,
    TResult? Function(String message)? error,
  }) {
    return available?.call(location);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(LocationCoordinate location)? available,
    TResult Function(String message, bool isPermanent)? permissionDenied,
    TResult Function(String message)? serviceDisabled,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (available != null) {
      return available(location);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Available value) available,
    required TResult Function(_PermissionDenied value) permissionDenied,
    required TResult Function(_ServiceDisabled value) serviceDisabled,
    required TResult Function(_Error value) error,
  }) {
    return available(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Available value)? available,
    TResult? Function(_PermissionDenied value)? permissionDenied,
    TResult? Function(_ServiceDisabled value)? serviceDisabled,
    TResult? Function(_Error value)? error,
  }) {
    return available?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Available value)? available,
    TResult Function(_PermissionDenied value)? permissionDenied,
    TResult Function(_ServiceDisabled value)? serviceDisabled,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (available != null) {
      return available(this);
    }
    return orElse();
  }
}

abstract class _Available implements LocationServiceState {
  const factory _Available({required final LocationCoordinate location}) =
      _$AvailableImpl;

  LocationCoordinate get location;

  /// Create a copy of LocationServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvailableImplCopyWith<_$AvailableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PermissionDeniedImplCopyWith<$Res> {
  factory _$$PermissionDeniedImplCopyWith(
    _$PermissionDeniedImpl value,
    $Res Function(_$PermissionDeniedImpl) then,
  ) = __$$PermissionDeniedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, bool isPermanent});
}

/// @nodoc
class __$$PermissionDeniedImplCopyWithImpl<$Res>
    extends _$LocationServiceStateCopyWithImpl<$Res, _$PermissionDeniedImpl>
    implements _$$PermissionDeniedImplCopyWith<$Res> {
  __$$PermissionDeniedImplCopyWithImpl(
    _$PermissionDeniedImpl _value,
    $Res Function(_$PermissionDeniedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationServiceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? isPermanent = null}) {
    return _then(
      _$PermissionDeniedImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        isPermanent: null == isPermanent
            ? _value.isPermanent
            : isPermanent // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$PermissionDeniedImpl implements _PermissionDenied {
  const _$PermissionDeniedImpl({
    required this.message,
    this.isPermanent = false,
  });

  @override
  final String message;
  @override
  @JsonKey()
  final bool isPermanent;

  @override
  String toString() {
    return 'LocationServiceState.permissionDenied(message: $message, isPermanent: $isPermanent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionDeniedImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.isPermanent, isPermanent) ||
                other.isPermanent == isPermanent));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, isPermanent);

  /// Create a copy of LocationServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PermissionDeniedImplCopyWith<_$PermissionDeniedImpl> get copyWith =>
      __$$PermissionDeniedImplCopyWithImpl<_$PermissionDeniedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(LocationCoordinate location) available,
    required TResult Function(String message, bool isPermanent)
    permissionDenied,
    required TResult Function(String message) serviceDisabled,
    required TResult Function(String message) error,
  }) {
    return permissionDenied(message, isPermanent);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(LocationCoordinate location)? available,
    TResult? Function(String message, bool isPermanent)? permissionDenied,
    TResult? Function(String message)? serviceDisabled,
    TResult? Function(String message)? error,
  }) {
    return permissionDenied?.call(message, isPermanent);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(LocationCoordinate location)? available,
    TResult Function(String message, bool isPermanent)? permissionDenied,
    TResult Function(String message)? serviceDisabled,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (permissionDenied != null) {
      return permissionDenied(message, isPermanent);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Available value) available,
    required TResult Function(_PermissionDenied value) permissionDenied,
    required TResult Function(_ServiceDisabled value) serviceDisabled,
    required TResult Function(_Error value) error,
  }) {
    return permissionDenied(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Available value)? available,
    TResult? Function(_PermissionDenied value)? permissionDenied,
    TResult? Function(_ServiceDisabled value)? serviceDisabled,
    TResult? Function(_Error value)? error,
  }) {
    return permissionDenied?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Available value)? available,
    TResult Function(_PermissionDenied value)? permissionDenied,
    TResult Function(_ServiceDisabled value)? serviceDisabled,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (permissionDenied != null) {
      return permissionDenied(this);
    }
    return orElse();
  }
}

abstract class _PermissionDenied implements LocationServiceState {
  const factory _PermissionDenied({
    required final String message,
    final bool isPermanent,
  }) = _$PermissionDeniedImpl;

  String get message;
  bool get isPermanent;

  /// Create a copy of LocationServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PermissionDeniedImplCopyWith<_$PermissionDeniedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ServiceDisabledImplCopyWith<$Res> {
  factory _$$ServiceDisabledImplCopyWith(
    _$ServiceDisabledImpl value,
    $Res Function(_$ServiceDisabledImpl) then,
  ) = __$$ServiceDisabledImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ServiceDisabledImplCopyWithImpl<$Res>
    extends _$LocationServiceStateCopyWithImpl<$Res, _$ServiceDisabledImpl>
    implements _$$ServiceDisabledImplCopyWith<$Res> {
  __$$ServiceDisabledImplCopyWithImpl(
    _$ServiceDisabledImpl _value,
    $Res Function(_$ServiceDisabledImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationServiceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ServiceDisabledImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ServiceDisabledImpl implements _ServiceDisabled {
  const _$ServiceDisabledImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'LocationServiceState.serviceDisabled(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceDisabledImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of LocationServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceDisabledImplCopyWith<_$ServiceDisabledImpl> get copyWith =>
      __$$ServiceDisabledImplCopyWithImpl<_$ServiceDisabledImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(LocationCoordinate location) available,
    required TResult Function(String message, bool isPermanent)
    permissionDenied,
    required TResult Function(String message) serviceDisabled,
    required TResult Function(String message) error,
  }) {
    return serviceDisabled(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(LocationCoordinate location)? available,
    TResult? Function(String message, bool isPermanent)? permissionDenied,
    TResult? Function(String message)? serviceDisabled,
    TResult? Function(String message)? error,
  }) {
    return serviceDisabled?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(LocationCoordinate location)? available,
    TResult Function(String message, bool isPermanent)? permissionDenied,
    TResult Function(String message)? serviceDisabled,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (serviceDisabled != null) {
      return serviceDisabled(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Available value) available,
    required TResult Function(_PermissionDenied value) permissionDenied,
    required TResult Function(_ServiceDisabled value) serviceDisabled,
    required TResult Function(_Error value) error,
  }) {
    return serviceDisabled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Available value)? available,
    TResult? Function(_PermissionDenied value)? permissionDenied,
    TResult? Function(_ServiceDisabled value)? serviceDisabled,
    TResult? Function(_Error value)? error,
  }) {
    return serviceDisabled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Available value)? available,
    TResult Function(_PermissionDenied value)? permissionDenied,
    TResult Function(_ServiceDisabled value)? serviceDisabled,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (serviceDisabled != null) {
      return serviceDisabled(this);
    }
    return orElse();
  }
}

abstract class _ServiceDisabled implements LocationServiceState {
  const factory _ServiceDisabled({required final String message}) =
      _$ServiceDisabledImpl;

  String get message;

  /// Create a copy of LocationServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceDisabledImplCopyWith<_$ServiceDisabledImpl> get copyWith =>
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
    extends _$LocationServiceStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationServiceState
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
    return 'LocationServiceState.error(message: $message)';
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

  /// Create a copy of LocationServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(LocationCoordinate location) available,
    required TResult Function(String message, bool isPermanent)
    permissionDenied,
    required TResult Function(String message) serviceDisabled,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(LocationCoordinate location)? available,
    TResult? Function(String message, bool isPermanent)? permissionDenied,
    TResult? Function(String message)? serviceDisabled,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(LocationCoordinate location)? available,
    TResult Function(String message, bool isPermanent)? permissionDenied,
    TResult Function(String message)? serviceDisabled,
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
    required TResult Function(_Loading value) loading,
    required TResult Function(_Available value) available,
    required TResult Function(_PermissionDenied value) permissionDenied,
    required TResult Function(_ServiceDisabled value) serviceDisabled,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Available value)? available,
    TResult? Function(_PermissionDenied value)? permissionDenied,
    TResult? Function(_ServiceDisabled value)? serviceDisabled,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Available value)? available,
    TResult Function(_PermissionDenied value)? permissionDenied,
    TResult Function(_ServiceDisabled value)? serviceDisabled,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements LocationServiceState {
  const factory _Error({required final String message}) = _$ErrorImpl;

  String get message;

  /// Create a copy of LocationServiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
