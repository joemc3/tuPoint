import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app/domain/entities/profile.dart';

part 'profile_state.freezed.dart';

/// Represents the state of profile operations in the application.
///
/// This is a union type that can be in one of four states:
/// - [Initial]: No profile operation has been performed yet
/// - [Loading]: Profile operation is in progress (fetch or update)
/// - [Loaded]: Profile was successfully loaded or updated
/// - [Error]: Profile operation failed
///
/// This state is managed by [ProfileNotifier] and exposed via Riverpod providers.
@freezed
class ProfileState with _$ProfileState {
  /// No profile loaded yet.
  ///
  /// This is the initial state before any profile operations have been
  /// performed. The UI should typically show a placeholder or prompt the
  /// user to take an action.
  const factory ProfileState.initial() = _Initial;

  /// Profile operation is in progress.
  ///
  /// This state is shown during:
  /// - Profile fetch operations
  /// - Profile update operations
  ///
  /// The UI should display a loading indicator while in this state.
  const factory ProfileState.loading() = _Loading;

  /// Profile was successfully loaded or updated.
  ///
  /// The [profile] contains the complete user profile data including
  /// username, bio, and timestamps.
  ///
  /// This is the success state where the UI can display profile information
  /// and allow further interactions.
  const factory ProfileState.loaded({
    required Profile profile,
  }) = _Loaded;

  /// Profile operation failed.
  ///
  /// The [message] provides a user-friendly error description that can
  /// be displayed in the UI. Common errors include:
  /// - Profile not found
  /// - Network errors
  /// - Validation errors (invalid username/bio)
  /// - Authorization errors
  /// - Duplicate username errors
  const factory ProfileState.error({
    required String message,
  }) = _Error;
}
