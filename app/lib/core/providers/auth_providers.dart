import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/use_cases/profile_use_cases/create_profile_use_case.dart';
import '../../domain/use_cases/profile_use_cases/fetch_profile_use_case.dart';
import '../../presentation/notifiers/auth_notifier.dart';
import 'repository_providers.dart';

/// Provides the CreateProfileUseCase instance.
///
/// This use case is responsible for creating new user profiles during
/// the signup flow. It validates username format and bio length before
/// creating the profile in the database.
///
/// Dependencies:
/// - [profileRepositoryProvider]: Profile repository for database operations
final createProfileUseCaseProvider = Provider<CreateProfileUseCase>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return CreateProfileUseCase(profileRepository: profileRepository);
});

/// Provides the FetchProfileUseCase instance.
///
/// This use case is used to fetch user profile information and check
/// whether a profile exists for a given user ID.
///
/// Dependencies:
/// - [profileRepositoryProvider]: Profile repository for database operations
final fetchProfileUseCaseProvider = Provider<FetchProfileUseCase>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return FetchProfileUseCase(profileRepository: profileRepository);
});

/// Provides the AuthNotifier state notifier.
///
/// This notifier manages all authentication operations including:
/// - Sign in (email/password, Google, Apple)
/// - Sign up with automatic profile creation
/// - Sign out
/// - Session persistence checking
/// - Profile existence validation
///
/// The notifier automatically listens to Supabase auth state changes
/// and updates the application's auth state accordingly.
///
/// Dependencies:
/// - [supabaseClientProvider]: Supabase client for auth operations
/// - [createProfileUseCaseProvider]: Use case for creating profiles during signup
/// - [fetchProfileUseCaseProvider]: Use case for checking profile existence
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final createProfileUseCase = ref.watch(createProfileUseCaseProvider);
  final fetchProfileUseCase = ref.watch(fetchProfileUseCaseProvider);

  return AuthNotifier(
    supabaseClient: supabaseClient,
    createProfileUseCase: createProfileUseCase,
    fetchProfileUseCase: fetchProfileUseCase,
  );
});

/// Provides the current authentication state.
///
/// This is a convenience provider that exposes the current auth state
/// from the [authNotifierProvider]. Use this in widgets that only need
/// to read the auth state without calling auth methods.
///
/// Example:
/// ```dart
/// final authState = ref.watch(authStateProvider);
/// authState.when(
///   authenticated: (userId, hasProfile) => HomeScreen(),
///   unauthenticated: () => LoginScreen(),
///   loading: () => LoadingScreen(),
///   error: (message) => ErrorScreen(message),
/// );
/// ```
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});

/// Provides the current user ID when authenticated, or null otherwise.
///
/// This is a convenience provider that extracts the user ID from the
/// authenticated state. Returns null if the user is not authenticated
/// or if the auth state is loading/error.
///
/// Use this provider in other providers that need the current user ID
/// for operations like fetching user-specific data.
///
/// Example:
/// ```dart
/// final userPointsProvider = FutureProvider((ref) async {
///   final userId = ref.watch(currentUserIdProvider);
///   if (userId == null) return [];
///
///   return ref.read(fetchUserPointsUseCaseProvider)(
///     FetchUserPointsRequest(userId: userId),
///   );
/// });
/// ```
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.maybeWhen(
    authenticated: (userId, hasProfile) => userId,
    orElse: () => null,
  );
});

/// Provides whether the current user has completed profile creation.
///
/// Returns true if authenticated with profile, false otherwise.
/// This is useful for determining whether to show the profile creation
/// screen after signup or OAuth sign in.
///
/// Example:
/// ```dart
/// final hasProfile = ref.watch(hasProfileProvider);
/// if (!hasProfile) {
///   // Show profile creation screen
/// }
/// ```
final hasProfileProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.maybeWhen(
    authenticated: (userId, hasProfile) => hasProfile,
    orElse: () => false,
  );
});
