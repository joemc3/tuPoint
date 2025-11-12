import 'package:app/domain/entities/profile.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_profile_repository.dart';
import 'package:app/domain/use_cases/requests.dart';
import 'package:app/domain/use_cases/use_case_base.dart';

/// Use case for creating a new user profile.
///
/// This is called once per user during onboarding after authentication.
/// Validates username format and bio length before creating the profile.
///
/// Business Rules:
/// - Username must be 3-32 characters
/// - Username can only contain letters, numbers, underscore, and dash
/// - Username is stored as lowercase for consistency
/// - Bio is optional but max 280 characters
/// - User ID must match authenticated user
class CreateProfileUseCase extends UseCase<Profile, CreateProfileRequest> {
  final IProfileRepository _profileRepository;

  CreateProfileUseCase({required IProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  @override
  Future<Profile> call(CreateProfileRequest request) async {
    _validateRequest(request);

    return _profileRepository.createProfile(
      id: request.userId,
      username: request.username.trim().toLowerCase(),
      bio: request.bio?.trim(),
    );
  }

  void _validateRequest(CreateProfileRequest request) {
    // Validate userId
    if (request.userId.isEmpty) {
      throw ValidationException('User ID cannot be empty');
    }

    // Validate username
    final username = request.username.trim();
    if (username.isEmpty) {
      throw ValidationException('Username cannot be empty');
    }

    if (username.length < 3 || username.length > 32) {
      throw ValidationException(
        'Username must be 3-32 characters (got ${username.length})',
      );
    }

    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username)) {
      throw ValidationException(
        'Username can only contain letters, numbers, underscore, and dash',
      );
    }

    if (username.startsWith('_') ||
        username.startsWith('-') ||
        username.endsWith('_') ||
        username.endsWith('-')) {
      throw ValidationException(
        'Username cannot start or end with underscore or dash',
      );
    }

    // Validate bio
    if (request.bio != null) {
      final bio = request.bio!.trim();
      if (bio.length > 280) {
        throw ValidationException(
          'Bio exceeds 280 characters (${bio.length}/280)',
        );
      }
    }
  }
}
