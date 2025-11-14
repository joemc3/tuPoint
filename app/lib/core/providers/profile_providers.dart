import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_state.dart';
import '../../domain/use_cases/profile_use_cases/update_profile_use_case.dart';
import '../../presentation/notifiers/profile_notifier.dart';
import 'auth_providers.dart';
import 'repository_providers.dart';

/// Provides the UpdateProfileUseCase instance.
///
/// This use case is responsible for updating user profile information
/// including username and bio. It validates input format and handles
/// authorization checks before updating the profile in the database.
///
/// Dependencies:
/// - [profileRepositoryProvider]: Profile repository for database operations
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return UpdateProfileUseCase(profileRepository: profileRepository);
});

/// Provides the ProfileNotifier state notifier.
///
/// This notifier manages all profile operations including:
/// - Fetching user profiles by ID
/// - Updating profile information (username and bio)
/// - Error handling with user-friendly messages
/// - State management for loading and error states
///
/// The notifier starts in the [ProfileState.initial] state and transitions
/// through loading, loaded, and error states as operations are performed.
///
/// Dependencies:
/// - [fetchProfileUseCaseProvider]: Use case for fetching profiles
/// - [updateProfileUseCaseProvider]: Use case for updating profiles
final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final fetchProfileUseCase = ref.watch(fetchProfileUseCaseProvider);
  final updateProfileUseCase = ref.watch(updateProfileUseCaseProvider);

  return ProfileNotifier(
    fetchProfileUseCase: fetchProfileUseCase,
    updateProfileUseCase: updateProfileUseCase,
  );
});

/// Provides the current profile state.
///
/// This is a convenience provider that exposes the current profile state
/// from the [profileNotifierProvider]. Use this in widgets that only need
/// to read the profile state without calling profile methods.
///
/// Example:
/// ```dart
/// final profileState = ref.watch(profileStateProvider);
/// profileState.when(
///   initial: () => Text('No profile loaded'),
///   loading: () => CircularProgressIndicator(),
///   loaded: (profile) => ProfileCard(profile: profile),
///   error: (message) => ErrorMessage(message),
/// );
/// ```
final profileStateProvider = Provider<ProfileState>((ref) {
  return ref.watch(profileNotifierProvider);
});

/// Provides the currently loaded profile, or null if not loaded.
///
/// This is a convenience provider that extracts the Profile from the
/// loaded state. Returns null if the profile state is initial, loading,
/// or error.
///
/// Use this provider when you need direct access to profile data and
/// want to handle the null case yourself rather than using state.when().
///
/// Example:
/// ```dart
/// final profile = ref.watch(currentProfileProvider);
/// if (profile != null) {
///   return Text('Welcome, ${profile.username}!');
/// }
/// return Text('No profile loaded');
/// ```
final currentProfileProvider = Provider<Profile?>((ref) {
  final profileState = ref.watch(profileStateProvider);

  return profileState.maybeWhen(
    loaded: (profile) => profile,
    orElse: () => null,
  );
});
