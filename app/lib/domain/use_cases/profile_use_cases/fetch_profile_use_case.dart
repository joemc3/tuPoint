import 'package:app/domain/entities/profile.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_profile_repository.dart';
import 'package:app/domain/use_cases/requests.dart';
import 'package:app/domain/use_cases/use_case_base.dart';

/// Use case for fetching a user's profile by ID.
///
/// Used to:
/// - Check if a new user has created a profile (returns NotFoundException if not)
/// - Display user profile information
/// - Validate user exists before performing actions
///
/// Throws [NotFoundException] if the profile doesn't exist, which can be
/// handled gracefully in the UI to show profile creation screen.
class FetchProfileUseCase extends UseCase<Profile, FetchProfileRequest> {
  final IProfileRepository _profileRepository;

  FetchProfileUseCase({required IProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  @override
  Future<Profile> call(FetchProfileRequest request) async {
    if (request.userId.isEmpty) {
      throw ValidationException('User ID cannot be empty');
    }

    return _profileRepository.fetchProfileById(request.userId);
  }
}
