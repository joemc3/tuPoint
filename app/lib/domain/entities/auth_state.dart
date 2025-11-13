import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Represents the authentication state of the application.
///
/// This is a union type that can be in one of four states:
/// - [Unauthenticated]: User is not logged in
/// - [Authenticated]: User is logged in with a valid session
/// - [Loading]: Authentication operation is in progress
/// - [Error]: Authentication operation failed
///
/// This state is managed by [AuthNotifier] and exposed via Riverpod providers.
@freezed
class AuthState with _$AuthState {
  /// User is not authenticated.
  ///
  /// This is the initial state when the app starts and the user has no
  /// active session, or after the user signs out.
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// User is authenticated with a valid session.
  ///
  /// The [userId] is the unique identifier from auth.users table.
  /// This ID is used for all repository operations that require authentication.
  ///
  /// [hasProfile] indicates whether the user has completed profile creation.
  /// If false, the app should redirect to profile creation flow.
  const factory AuthState.authenticated({
    required String userId,
    @Default(true) bool hasProfile,
  }) = _Authenticated;

  /// Authentication operation is in progress.
  ///
  /// This state is shown during:
  /// - Initial app load while checking for existing session
  /// - Sign in / sign up operations
  /// - Profile creation after signup
  const factory AuthState.loading() = _Loading;

  /// Authentication operation failed.
  ///
  /// The [message] provides a user-friendly error description that can
  /// be displayed in the UI. Common errors include:
  /// - Invalid credentials
  /// - Network errors
  /// - Profile creation failures
  const factory AuthState.error({
    required String message,
  }) = _Error;
}
