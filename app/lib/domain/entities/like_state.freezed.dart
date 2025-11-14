// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'like_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$LikeState {
  /// Map of point IDs to whether the current user has liked that point.
  ///
  /// - `true`: User has liked the point
  /// - `false`: User has not liked the point
  /// - Missing key: Like status not yet fetched
  ///
  /// This map is updated optimistically during toggle operations and
  /// rolled back if the server operation fails.
  Map<String, bool> get likedByUser => throw _privateConstructorUsedError;

  /// Map of point IDs to the total number of likes for that point.
  ///
  /// - `n > 0`: Point has n likes
  /// - `0`: Point has no likes
  /// - Missing key: Like count not yet fetched
  ///
  /// This map is updated optimistically during toggle operations and
  /// rolled back if the server operation fails.
  Map<String, int> get likeCounts => throw _privateConstructorUsedError;

  /// Map of point IDs to loading state during toggle operations.
  ///
  /// - `true`: Toggle operation in progress (disable button)
  /// - `false`: No operation in progress (enable button)
  /// - Missing key: Defaults to false (not loading)
  ///
  /// This is used to disable like buttons during toggle operations
  /// to prevent duplicate requests.
  Map<String, bool> get loadingStates => throw _privateConstructorUsedError;

  /// Map of point IDs to error messages if operations failed.
  ///
  /// - `null`: No error
  /// - Non-null string: Error message to display
  /// - Missing key: Defaults to null (no error)
  ///
  /// Errors are point-specific and are cleared when a new toggle
  /// operation is initiated for that point.
  Map<String, String?> get errors => throw _privateConstructorUsedError;

  /// Create a copy of LikeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LikeStateCopyWith<LikeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LikeStateCopyWith<$Res> {
  factory $LikeStateCopyWith(LikeState value, $Res Function(LikeState) then) =
      _$LikeStateCopyWithImpl<$Res, LikeState>;
  @useResult
  $Res call({
    Map<String, bool> likedByUser,
    Map<String, int> likeCounts,
    Map<String, bool> loadingStates,
    Map<String, String?> errors,
  });
}

/// @nodoc
class _$LikeStateCopyWithImpl<$Res, $Val extends LikeState>
    implements $LikeStateCopyWith<$Res> {
  _$LikeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LikeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? likedByUser = null,
    Object? likeCounts = null,
    Object? loadingStates = null,
    Object? errors = null,
  }) {
    return _then(
      _value.copyWith(
            likedByUser: null == likedByUser
                ? _value.likedByUser
                : likedByUser // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>,
            likeCounts: null == likeCounts
                ? _value.likeCounts
                : likeCounts // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            loadingStates: null == loadingStates
                ? _value.loadingStates
                : loadingStates // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as Map<String, String?>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LikeStateImplCopyWith<$Res>
    implements $LikeStateCopyWith<$Res> {
  factory _$$LikeStateImplCopyWith(
    _$LikeStateImpl value,
    $Res Function(_$LikeStateImpl) then,
  ) = __$$LikeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<String, bool> likedByUser,
    Map<String, int> likeCounts,
    Map<String, bool> loadingStates,
    Map<String, String?> errors,
  });
}

/// @nodoc
class __$$LikeStateImplCopyWithImpl<$Res>
    extends _$LikeStateCopyWithImpl<$Res, _$LikeStateImpl>
    implements _$$LikeStateImplCopyWith<$Res> {
  __$$LikeStateImplCopyWithImpl(
    _$LikeStateImpl _value,
    $Res Function(_$LikeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LikeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? likedByUser = null,
    Object? likeCounts = null,
    Object? loadingStates = null,
    Object? errors = null,
  }) {
    return _then(
      _$LikeStateImpl(
        likedByUser: null == likedByUser
            ? _value._likedByUser
            : likedByUser // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>,
        likeCounts: null == likeCounts
            ? _value._likeCounts
            : likeCounts // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        loadingStates: null == loadingStates
            ? _value._loadingStates
            : loadingStates // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as Map<String, String?>,
      ),
    );
  }
}

/// @nodoc

class _$LikeStateImpl implements _LikeState {
  const _$LikeStateImpl({
    final Map<String, bool> likedByUser = const {},
    final Map<String, int> likeCounts = const {},
    final Map<String, bool> loadingStates = const {},
    final Map<String, String?> errors = const {},
  }) : _likedByUser = likedByUser,
       _likeCounts = likeCounts,
       _loadingStates = loadingStates,
       _errors = errors;

  /// Map of point IDs to whether the current user has liked that point.
  ///
  /// - `true`: User has liked the point
  /// - `false`: User has not liked the point
  /// - Missing key: Like status not yet fetched
  ///
  /// This map is updated optimistically during toggle operations and
  /// rolled back if the server operation fails.
  final Map<String, bool> _likedByUser;

  /// Map of point IDs to whether the current user has liked that point.
  ///
  /// - `true`: User has liked the point
  /// - `false`: User has not liked the point
  /// - Missing key: Like status not yet fetched
  ///
  /// This map is updated optimistically during toggle operations and
  /// rolled back if the server operation fails.
  @override
  @JsonKey()
  Map<String, bool> get likedByUser {
    if (_likedByUser is EqualUnmodifiableMapView) return _likedByUser;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_likedByUser);
  }

  /// Map of point IDs to the total number of likes for that point.
  ///
  /// - `n > 0`: Point has n likes
  /// - `0`: Point has no likes
  /// - Missing key: Like count not yet fetched
  ///
  /// This map is updated optimistically during toggle operations and
  /// rolled back if the server operation fails.
  final Map<String, int> _likeCounts;

  /// Map of point IDs to the total number of likes for that point.
  ///
  /// - `n > 0`: Point has n likes
  /// - `0`: Point has no likes
  /// - Missing key: Like count not yet fetched
  ///
  /// This map is updated optimistically during toggle operations and
  /// rolled back if the server operation fails.
  @override
  @JsonKey()
  Map<String, int> get likeCounts {
    if (_likeCounts is EqualUnmodifiableMapView) return _likeCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_likeCounts);
  }

  /// Map of point IDs to loading state during toggle operations.
  ///
  /// - `true`: Toggle operation in progress (disable button)
  /// - `false`: No operation in progress (enable button)
  /// - Missing key: Defaults to false (not loading)
  ///
  /// This is used to disable like buttons during toggle operations
  /// to prevent duplicate requests.
  final Map<String, bool> _loadingStates;

  /// Map of point IDs to loading state during toggle operations.
  ///
  /// - `true`: Toggle operation in progress (disable button)
  /// - `false`: No operation in progress (enable button)
  /// - Missing key: Defaults to false (not loading)
  ///
  /// This is used to disable like buttons during toggle operations
  /// to prevent duplicate requests.
  @override
  @JsonKey()
  Map<String, bool> get loadingStates {
    if (_loadingStates is EqualUnmodifiableMapView) return _loadingStates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_loadingStates);
  }

  /// Map of point IDs to error messages if operations failed.
  ///
  /// - `null`: No error
  /// - Non-null string: Error message to display
  /// - Missing key: Defaults to null (no error)
  ///
  /// Errors are point-specific and are cleared when a new toggle
  /// operation is initiated for that point.
  final Map<String, String?> _errors;

  /// Map of point IDs to error messages if operations failed.
  ///
  /// - `null`: No error
  /// - Non-null string: Error message to display
  /// - Missing key: Defaults to null (no error)
  ///
  /// Errors are point-specific and are cleared when a new toggle
  /// operation is initiated for that point.
  @override
  @JsonKey()
  Map<String, String?> get errors {
    if (_errors is EqualUnmodifiableMapView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_errors);
  }

  @override
  String toString() {
    return 'LikeState(likedByUser: $likedByUser, likeCounts: $likeCounts, loadingStates: $loadingStates, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LikeStateImpl &&
            const DeepCollectionEquality().equals(
              other._likedByUser,
              _likedByUser,
            ) &&
            const DeepCollectionEquality().equals(
              other._likeCounts,
              _likeCounts,
            ) &&
            const DeepCollectionEquality().equals(
              other._loadingStates,
              _loadingStates,
            ) &&
            const DeepCollectionEquality().equals(other._errors, _errors));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_likedByUser),
    const DeepCollectionEquality().hash(_likeCounts),
    const DeepCollectionEquality().hash(_loadingStates),
    const DeepCollectionEquality().hash(_errors),
  );

  /// Create a copy of LikeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LikeStateImplCopyWith<_$LikeStateImpl> get copyWith =>
      __$$LikeStateImplCopyWithImpl<_$LikeStateImpl>(this, _$identity);
}

abstract class _LikeState implements LikeState {
  const factory _LikeState({
    final Map<String, bool> likedByUser,
    final Map<String, int> likeCounts,
    final Map<String, bool> loadingStates,
    final Map<String, String?> errors,
  }) = _$LikeStateImpl;

  /// Map of point IDs to whether the current user has liked that point.
  ///
  /// - `true`: User has liked the point
  /// - `false`: User has not liked the point
  /// - Missing key: Like status not yet fetched
  ///
  /// This map is updated optimistically during toggle operations and
  /// rolled back if the server operation fails.
  @override
  Map<String, bool> get likedByUser;

  /// Map of point IDs to the total number of likes for that point.
  ///
  /// - `n > 0`: Point has n likes
  /// - `0`: Point has no likes
  /// - Missing key: Like count not yet fetched
  ///
  /// This map is updated optimistically during toggle operations and
  /// rolled back if the server operation fails.
  @override
  Map<String, int> get likeCounts;

  /// Map of point IDs to loading state during toggle operations.
  ///
  /// - `true`: Toggle operation in progress (disable button)
  /// - `false`: No operation in progress (enable button)
  /// - Missing key: Defaults to false (not loading)
  ///
  /// This is used to disable like buttons during toggle operations
  /// to prevent duplicate requests.
  @override
  Map<String, bool> get loadingStates;

  /// Map of point IDs to error messages if operations failed.
  ///
  /// - `null`: No error
  /// - Non-null string: Error message to display
  /// - Missing key: Defaults to null (no error)
  ///
  /// Errors are point-specific and are cleared when a new toggle
  /// operation is initiated for that point.
  @override
  Map<String, String?> get errors;

  /// Create a copy of LikeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LikeStateImplCopyWith<_$LikeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
