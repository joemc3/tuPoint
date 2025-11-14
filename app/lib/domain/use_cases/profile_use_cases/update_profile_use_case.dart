import 'package:app/domain/entities/profile.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_profile_repository.dart';
import 'package:app/domain/use_cases/requests.dart';
import 'package:app/domain/use_cases/use_case_base.dart';

/// Use case for updating an existing user profile.
///
/// Allows users to update their username and/or bio.
/// Validates input format before updating the profile in the repository.
///
/// Business Rules:
/// - User can only update their own profile (enforced by RLS)
/// - Username must be 3-32 characters if provided
/// - Username can only contain letters, numbers, underscore, and dash
/// - Username is stored as lowercase for consistency
/// - Username cannot start or end with underscore or dash
/// - Bio is optional but max 280 characters if provided
/// - At least one field (username or bio) should be provided for update
class UpdateProfileUseCase extends UseCase<Profile, UpdateProfileRequest> {
  final IProfileRepository _profileRepository;

  UpdateProfileUseCase({required IProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  @override
  Future<Profile> call(UpdateProfileRequest request) async {
    _validateRequest(request);

    // Normalize username if provided
    final normalizedUsername = request.username?.trim().toLowerCase();

    return _profileRepository.updateProfile(
      userId: request.userId,
      username: normalizedUsername,
      bio: request.bio?.trim(),
    );
  }

  void _validateRequest(UpdateProfileRequest request) {
    // Validate userId
    if (request.userId.isEmpty) {
      throw ValidationException('User ID cannot be empty');
    }

    // At least one field should be provided
    if (request.username == null && request.bio == null) {
      throw ValidationException(
        'At least one field (username or bio) must be provided for update',
      );
    }

    // Validate username if provided
    if (request.username != null) {
      final username = request.username!.trim();

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
    }

    // Validate bio if provided
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
