import 'package:app/domain/entities/point.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_points_repository.dart';
import 'package:app/domain/use_cases/requests.dart';
import 'package:app/domain/use_cases/use_case_base.dart';

/// Use case for fetching all active points created by a specific user.
///
/// Used for:
/// - User's own profile view (my points)
/// - Other users' profile views (their points)
///
/// Returns only active (non-deleted) points, sorted by creation date.
class FetchUserPointsUseCase
    extends UseCase<List<Point>, FetchUserPointsRequest> {
  final IPointsRepository _pointsRepository;

  FetchUserPointsUseCase({required IPointsRepository pointsRepository})
      : _pointsRepository = pointsRepository;

  @override
  Future<List<Point>> call(FetchUserPointsRequest request) async {
    if (request.userId.isEmpty) {
      throw ValidationException('User ID cannot be empty');
    }

    final points = await _pointsRepository.fetchPointsByUserId(request.userId);

    // Sort by creation date (newest first)
    points.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return points;
  }
}
