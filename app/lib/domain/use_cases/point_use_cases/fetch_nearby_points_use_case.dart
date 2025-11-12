import 'package:app/domain/entities/point.dart';
import 'package:app/domain/repositories/i_points_repository.dart';
import 'package:app/domain/use_cases/requests.dart';
import 'package:app/domain/use_cases/use_case_base.dart';
import 'package:app/domain/utils/haversine_calculator.dart';

/// Use case for fetching nearby points within a specified radius.
///
/// This is a core MVP feature - shows users Points within 5km of their location.
/// Content "disappears when you leave the area" is implemented through this
/// client-side distance filtering.
///
/// Business Logic:
/// 1. Fetch all active points from repository (server-side)
/// 2. Filter by radius using Haversine calculator (client-side)
/// 3. Optionally remove user's own points
/// 4. Sort by distance (nearest first)
///
/// Performance:
/// - Haversine calculation: ~1-2 microseconds per point
/// - 100 points = ~1ms total (acceptable for MVP)
/// - No pagination in MVP
class FetchNearbyPointsUseCase
    extends UseCase<List<Point>, FetchNearbyPointsRequest> {
  final IPointsRepository _pointsRepository;

  FetchNearbyPointsUseCase({required IPointsRepository pointsRepository})
      : _pointsRepository = pointsRepository;

  @override
  Future<List<Point>> call(FetchNearbyPointsRequest request) async {
    // 1. Fetch all active points (unfiltered)
    final allPoints = await _pointsRepository.fetchAllActivePoints();

    // 2. Calculate distances and filter by radius
    final pointsWithDistances = <Point, double>{};

    for (final point in allPoints) {
      final distance = HaversineCalculator.calculateDistance(
        request.userLocation,
        point.location,
      );

      if (distance <= request.radiusMeters) {
        pointsWithDistances[point] = distance;
      }
    }

    // 3. Optionally remove user's own points
    if (!request.includeUserOwnPoints && request.userId != null) {
      pointsWithDistances
          .removeWhere((point, _) => point.userId == request.userId);
    }

    // 4. Sort by distance (nearest first)
    final nearbyPoints = pointsWithDistances.keys.toList()
      ..sort((a, b) {
        return pointsWithDistances[a]!.compareTo(pointsWithDistances[b]!);
      });

    return nearbyPoints;
  }
}
