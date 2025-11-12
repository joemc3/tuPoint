import 'package:app/domain/entities/like.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_likes_repository.dart';
import 'package:app/domain/use_cases/requests.dart';
import 'package:app/domain/use_cases/use_case_base.dart';

/// Use case for liking a point.
///
/// Records a like relationship between a user and a point.
/// A user can only like a point once (enforced by database unique constraint).
///
/// Throws [DuplicateLikeException] if the user has already liked this point.
class LikePointUseCase extends UseCase<Like, LikePointRequest> {
  final ILikesRepository _likesRepository;

  LikePointUseCase({required ILikesRepository likesRepository})
      : _likesRepository = likesRepository;

  @override
  Future<Like> call(LikePointRequest request) async {
    if (request.pointId.isEmpty) {
      throw ValidationException('Point ID cannot be empty');
    }

    if (request.userId.isEmpty) {
      throw ValidationException('User ID cannot be empty');
    }

    return _likesRepository.likePoint(
      pointId: request.pointId,
      userId: request.userId,
    );
  }
}
