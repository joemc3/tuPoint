import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_likes_repository.dart';
import 'package:app/domain/use_cases/requests.dart';
import 'package:app/domain/use_cases/use_case_base.dart';

/// Use case for getting the like count for a point.
///
/// Returns the number of likes a point has received.
/// Used to display "X likes" on point cards in the feed.
class GetLikeCountUseCase extends UseCase<int, GetLikeCountRequest> {
  final ILikesRepository _likesRepository;

  GetLikeCountUseCase({required ILikesRepository likesRepository})
      : _likesRepository = likesRepository;

  @override
  Future<int> call(GetLikeCountRequest request) async {
    if (request.pointId.isEmpty) {
      throw ValidationException('Point ID cannot be empty');
    }

    return _likesRepository.getLikeCountForPoint(request.pointId);
  }
}
