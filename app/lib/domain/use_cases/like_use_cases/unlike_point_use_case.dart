import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_likes_repository.dart';
import 'package:app/domain/use_cases/requests.dart';
import 'package:app/domain/use_cases/use_case_base.dart';

/// Use case for unliking a point.
///
/// Removes a like relationship between a user and a point.
///
/// Throws [NotFoundException] if the like doesn't exist
/// (user never liked this point).
class UnlikePointUseCase extends UseCase<void, UnlikePointRequest> {
  final ILikesRepository _likesRepository;

  UnlikePointUseCase({required ILikesRepository likesRepository})
      : _likesRepository = likesRepository;

  @override
  Future<void> call(UnlikePointRequest request) async {
    if (request.pointId.isEmpty) {
      throw ValidationException('Point ID cannot be empty');
    }

    if (request.userId.isEmpty) {
      throw ValidationException('User ID cannot be empty');
    }

    return _likesRepository.unlikePoint(
      pointId: request.pointId,
      userId: request.userId,
    );
  }
}
