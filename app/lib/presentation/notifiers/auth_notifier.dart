import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../domain/entities/auth_state.dart';
import '../../domain/exceptions/repository_exceptions.dart';
import '../../domain/use_cases/profile_use_cases/create_profile_use_case.dart';
import '../../domain/use_cases/profile_use_cases/fetch_profile_use_case.dart';
import '../../domain/use_cases/requests.dart';

/// Notifier that manages authentication state and operations.
///
/// This notifier handles:
/// - Sign in with email/password
/// - Sign in with Google OAuth
/// - Sign in with Apple Sign In
/// - Sign up with email/password (includes profile creation)
/// - Sign out
/// - Auth state persistence via Supabase session management
/// - Profile existence checking
///
/// The notifier listens to Supabase auth state changes to automatically
/// update the app's authentication state when sessions are restored or
/// invalidated.
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _supabaseClient;
  final CreateProfileUseCase _createProfileUseCase;
  final FetchProfileUseCase _fetchProfileUseCase;

  StreamSubscription? _authStateSubscription;

  AuthNotifier({
    required SupabaseClient supabaseClient,
    required CreateProfileUseCase createProfileUseCase,
    required FetchProfileUseCase fetchProfileUseCase,
  })  : _supabaseClient = supabaseClient,
        _createProfileUseCase = createProfileUseCase,
        _fetchProfileUseCase = fetchProfileUseCase,
        super(const AuthState.loading()) {
    _initialize();
  }

  /// Initialize authentication state by checking for existing session
  /// and setting up auth state listener.
  void _initialize() {
    // Listen to Supabase auth state changes
    _authStateSubscription = _supabaseClient.auth.onAuthStateChange.listen(
      (data) {
        final session = data.session;

        if (session == null) {
          state = const AuthState.unauthenticated();
        } else {
          // We have a session, but we need to check profile existence
          // Schedule the profile check asynchronously
          _checkProfileAfterAuthChange(session.user.id);
        }
      },
    );

    // Check current session
    checkAuthStatus();
  }

  /// Check profile existence after auth state change.
  ///
  /// This is called when Supabase reports an auth state change to a
  /// logged-in state. We need to check if the user has a profile.
  Future<void> _checkProfileAfterAuthChange(String userId) async {
    try {
      await _fetchProfileUseCase(FetchProfileRequest(userId: userId));
      // Profile exists
      state = AuthState.authenticated(userId: userId, hasProfile: true);
    } on NotFoundException {
      // Profile doesn't exist
      state = AuthState.authenticated(userId: userId, hasProfile: false);
    } catch (e) {
      // Error checking profile - assume no profile for safety
      state = AuthState.authenticated(userId: userId, hasProfile: false);
    }
  }

  /// Check current authentication status.
  ///
  /// This is called:
  /// - On app initialization
  /// - After sign in/sign up operations
  /// - When explicitly needed by the UI
  ///
  /// If a session exists, it checks whether the user has created a profile.
  Future<void> checkAuthStatus() async {
    try {
      state = const AuthState.loading();

      final session = _supabaseClient.auth.currentSession;

      if (session == null) {
        state = const AuthState.unauthenticated();
        return;
      }

      final userId = session.user.id;

      // Check if user has a profile
      try {
        await _fetchProfileUseCase(FetchProfileRequest(userId: userId));
        // Profile exists
        state = AuthState.authenticated(userId: userId, hasProfile: true);
      } on NotFoundException {
        // Profile doesn't exist - user needs to complete onboarding
        state = AuthState.authenticated(userId: userId, hasProfile: false);
      }
    } catch (e) {
      state = AuthState.error(
        message: 'Failed to check authentication status: ${e.toString()}',
      );
    }
  }

  /// Sign in with email and password.
  ///
  /// Throws user-friendly error messages for common failure scenarios:
  /// - Invalid credentials
  /// - Network errors
  /// - Account not found
  Future<void> signInWithEmail(String email, String password) async {
    try {
      state = const AuthState.loading();

      final response = await _supabaseClient.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.session == null) {
        state = const AuthState.error(
          message: 'Sign in failed. Please check your credentials.',
        );
        return;
      }

      // Check auth status to determine if profile exists
      await checkAuthStatus();
    } on AuthException catch (e) {
      state = AuthState.error(message: _mapAuthExceptionToMessage(e));
    } catch (e) {
      state = AuthState.error(
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sign in with Google OAuth.
  ///
  /// Opens the Google sign-in flow in a web browser or native dialog.
  /// The app will be redirected back after the user completes authentication.
  Future<void> signInWithGoogle() async {
    try {
      state = const AuthState.loading();

      final response = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.tupoint://login-callback/',
      );

      if (!response) {
        state = const AuthState.error(
          message: 'Google sign in was cancelled or failed.',
        );
        return;
      }

      // Note: The actual auth state update will happen via the auth state
      // change listener when the OAuth flow completes and redirects back.
      // For now, we stay in loading state.
    } on AuthException catch (e) {
      state = AuthState.error(message: _mapAuthExceptionToMessage(e));
    } catch (e) {
      state = AuthState.error(
        message: 'An unexpected error occurred during Google sign in.',
      );
    }
  }

  /// Sign in with Apple.
  ///
  /// Opens the Apple sign-in flow using the system's native Apple ID dialog.
  /// Only available on iOS and macOS.
  Future<void> signInWithApple() async {
    try {
      state = const AuthState.loading();

      final response = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.tupoint://login-callback/',
      );

      if (!response) {
        state = const AuthState.error(
          message: 'Apple sign in was cancelled or failed.',
        );
        return;
      }

      // Note: The actual auth state update will happen via the auth state
      // change listener when the OAuth flow completes and redirects back.
      // For now, we stay in loading state.
    } on AuthException catch (e) {
      state = AuthState.error(message: _mapAuthExceptionToMessage(e));
    } catch (e) {
      state = AuthState.error(
        message: 'An unexpected error occurred during Apple sign in.',
      );
    }
  }

  /// Sign up with email and password, then create a profile.
  ///
  /// This is a two-step process:
  /// 1. Create auth.users account via Supabase Auth
  /// 2. Create profile record using CreateProfileUseCase
  ///
  /// If profile creation fails, the auth account still exists but the user
  /// will be prompted to complete profile creation on next sign in.
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password (min 6 characters by Supabase default)
  /// - [username]: Desired username (3-32 chars, alphanumeric + underscore/dash)
  /// - [bio]: Optional biography (max 280 chars)
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    String? bio,
  }) async {
    try {
      state = const AuthState.loading();

      // Step 1: Create auth account
      final response = await _supabaseClient.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.session == null || response.user == null) {
        state = const AuthState.error(
          message: 'Sign up failed. Please try again.',
        );
        return;
      }

      final userId = response.user!.id;

      // Step 2: Create profile
      try {
        await _createProfileUseCase(CreateProfileRequest(
          userId: userId,
          username: username,
          bio: bio,
        ));

        // Success! User is now authenticated with a profile
        state = AuthState.authenticated(userId: userId, hasProfile: true);
      } on DuplicateUsernameException catch (e) {
        // Username is taken - keep user authenticated but without profile
        state = AuthState.authenticated(userId: userId, hasProfile: false);
        // Also set error message for UI to display
        state = AuthState.error(message: e.message);
      } on ValidationException catch (e) {
        // Invalid username format - keep user authenticated but without profile
        state = AuthState.authenticated(userId: userId, hasProfile: false);
        state = AuthState.error(message: e.message);
      } catch (e) {
        // Other profile creation error - keep user authenticated but without profile
        state = AuthState.authenticated(userId: userId, hasProfile: false);
        state = AuthState.error(
          message: 'Profile creation failed: ${e.toString()}',
        );
      }
    } on AuthException catch (e) {
      state = AuthState.error(message: _mapAuthExceptionToMessage(e));
    } catch (e) {
      state = AuthState.error(
        message: 'An unexpected error occurred during sign up.',
      );
    }
  }

  /// Sign up with email and password only (no profile creation).
  ///
  /// This creates a Supabase auth account but does NOT create a profile.
  /// The user will be set to authenticated(hasProfile: false), which routes
  /// them to the ProfileCreationScreen to complete their profile setup.
  ///
  /// This flow is consistent with OAuth sign-in, where profile creation
  /// happens separately after authentication.
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password (min 6 characters by Supabase default)
  Future<void> signUpEmailOnly({
    required String email,
    required String password,
  }) async {
    try {
      state = const AuthState.loading();

      // Create auth account only (no profile)
      final response = await _supabaseClient.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.session == null || response.user == null) {
        state = const AuthState.error(
          message: 'Sign up failed. Please try again.',
        );
        return;
      }

      final userId = response.user!.id;

      // Set state to authenticated without profile
      // User will be routed to ProfileCreationScreen
      state = AuthState.authenticated(userId: userId, hasProfile: false);
    } on AuthException catch (e) {
      state = AuthState.error(message: _mapAuthExceptionToMessage(e));
    } catch (e) {
      state = AuthState.error(
        message: 'An unexpected error occurred during sign up.',
      );
    }
  }

  /// Complete profile creation for an already-authenticated user.
  ///
  /// This is called after OAuth sign-in (Google/Apple) when the user
  /// doesn't have a profile yet. The user is already authenticated via
  /// OAuth, so we just need to create the profile record.
  ///
  /// Throws [DuplicateUsernameException] if username is taken.
  /// Throws [ValidationException] if username format is invalid.
  Future<void> completeProfile({
    required String userId,
    required String username,
    String? bio,
  }) async {
    try {
      state = const AuthState.loading();

      // Create profile for authenticated user
      await _createProfileUseCase(CreateProfileRequest(
        userId: userId,
        username: username,
        bio: bio,
      ));

      // Success! User now has a complete profile
      state = AuthState.authenticated(userId: userId, hasProfile: true);
    } on DuplicateUsernameException catch (e) {
      // Username is taken - stay authenticated but show error
      state = AuthState.authenticated(userId: userId, hasProfile: false);
      // Immediately transition to error state to show message
      state = AuthState.error(message: e.message);
    } on ValidationException catch (e) {
      // Invalid username format - stay authenticated but show error
      state = AuthState.authenticated(userId: userId, hasProfile: false);
      state = AuthState.error(message: e.message);
    } catch (e) {
      // Other error - stay authenticated but show error
      state = AuthState.authenticated(userId: userId, hasProfile: false);
      state = AuthState.error(
        message: 'Failed to create profile. Please try again.',
      );
    }
  }

  /// Sign out the current user.
  ///
  /// Clears the Supabase session and resets to unauthenticated state.
  Future<void> signOut() async {
    try {
      state = const AuthState.loading();

      await _supabaseClient.auth.signOut();

      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(
        message: 'Failed to sign out. Please try again.',
      );
    }
  }

  /// Maps Supabase AuthException to user-friendly error messages.
  String _mapAuthExceptionToMessage(AuthException exception) {
    // Common Supabase auth error messages
    final message = exception.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      return 'Invalid email or password. Please try again.';
    }

    if (message.contains('email not confirmed')) {
      return 'Please verify your email address before signing in.';
    }

    if (message.contains('user already registered')) {
      return 'An account with this email already exists.';
    }

    if (message.contains('password should be at least')) {
      return 'Password must be at least 6 characters long.';
    }

    if (message.contains('unable to validate email address')) {
      return 'Invalid email address format.';
    }

    if (message.contains('network')) {
      return 'Network error. Please check your connection.';
    }

    // Default to the original message if we don't have a specific mapping
    return exception.message;
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
