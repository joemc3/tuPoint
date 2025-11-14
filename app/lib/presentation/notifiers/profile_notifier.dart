import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile_state.dart';
import '../../domain/exceptions/repository_exceptions.dart';
import '../../domain/use_cases/profile_use_cases/fetch_profile_use_case.dart';
import '../../domain/use_cases/profile_use_cases/update_profile_use_case.dart';
import '../../domain/use_cases/requests.dart';

/// Notifier that manages profile state and operations.
///
/// This notifier handles:
/// - Fetching user profiles by ID
/// - Updating profile information (username and bio)
/// - Error handling with user-friendly messages
/// - State management for loading and error states
///
/// The notifier provides a clean API for profile operations and maps
/// repository exceptions to user-friendly error messages that can be
/// displayed in the UI.
class ProfileNotifier extends StateNotifier<ProfileState> {
  final FetchProfileUseCase _fetchProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  ProfileNotifier({
    required FetchProfileUseCase fetchProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _fetchProfileUseCase = fetchProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        super(const ProfileState.initial());

  /// Fetches a user's profile by user ID.
  ///
  /// This method:
  /// - Sets state to loading while fetching
  /// - Calls FetchProfileUseCase to retrieve the profile
  /// - Updates state to loaded with profile data on success
  /// - Updates state to error with user-friendly message on failure
  ///
  /// Common error scenarios:
  /// - Profile not found (user hasn't created profile yet)
  /// - Network errors
  /// - Database errors
  ///
  /// [userId] - The unique identifier of the user whose profile to fetch
  Future<void> fetchProfile(String userId) async {
    try {
      state = const ProfileState.loading();

      final profile = await _fetchProfileUseCase(
        FetchProfileRequest(userId: userId),
      );

      state = ProfileState.loaded(profile: profile);
    } on NotFoundException {
      state = ProfileState.error(
        message: 'Profile not found. Please create a profile first.',
      );
    } on DatabaseException {
      state = ProfileState.error(
        message: 'Unable to load profile. Please check your connection.',
      );
    } catch (e) {
      state = ProfileState.error(
        message: 'An unexpected error occurred while loading profile.',
      );
    }
  }

  /// Updates the current user's profile.
  ///
  /// This method:
  /// - Validates that at least one field is provided for update
  /// - Sets state to loading while updating
  /// - Calls UpdateProfileUseCase to update the profile
  /// - Updates state to loaded with updated profile on success
  /// - Updates state to error with user-friendly message on failure
  ///
  /// Common error scenarios:
  /// - Validation errors (invalid username format, bio too long)
  /// - Duplicate username (username already taken)
  /// - Authorization errors (user doesn't own the profile)
  /// - Network errors
  /// - Database errors
  ///
  /// Parameters:
  /// - [userId] - User ID of the authenticated user (must own the profile)
  /// - [username] - New username (optional, 3-32 chars, alphanumeric + underscore/dash)
  /// - [bio] - New bio (optional, max 280 chars)
  ///
  /// At least one of [username] or [bio] must be provided.
  Future<void> updateProfile({
    required String userId,
    String? username,
    String? bio,
  }) async {
    try {
      state = const ProfileState.loading();

      final updatedProfile = await _updateProfileUseCase(
        UpdateProfileRequest(
          userId: userId,
          username: username,
          bio: bio,
        ),
      );

      state = ProfileState.loaded(profile: updatedProfile);
    } on ValidationException catch (e) {
      // Restore previous state if available, otherwise go to error
      state = ProfileState.error(message: e.message);
    } on DuplicateUsernameException catch (e) {
      state = ProfileState.error(message: e.message);
    } on UnauthorizedException {
      state = ProfileState.error(
        message: 'You are not authorized to update this profile.',
      );
    } on NotFoundException {
      state = ProfileState.error(
        message: 'Profile not found. Please try again.',
      );
    } on DatabaseException {
      state = ProfileState.error(
        message: 'Unable to update profile. Please check your connection.',
      );
    } catch (e) {
      state = ProfileState.error(
        message: 'An unexpected error occurred while updating profile.',
      );
    }
  }

  /// Resets the profile state to initial.
  ///
  /// This is useful for cleanup when:
  /// - User signs out
  /// - Navigating away from profile screens
  /// - Starting a fresh profile operation
  void reset() {
    state = const ProfileState.initial();
  }
}
