import 'package:app/domain/entities/point.dart';
import 'package:app/domain/exceptions/repository_exceptions.dart';
import 'package:app/domain/repositories/i_points_repository.dart';
import 'package:app/domain/use_cases/requests.dart';
import 'package:app/domain/use_cases/use_case_base.dart';

/// Use case for creating a new Point (dropping content at a location).
///
/// This is the core MVP action - users create location-based posts.
/// Content disappears when users leave the area (handled by proximity filtering).
///
/// Business Rules:
/// - Content must be 1-280 characters
/// - Location must be valid WGS84 coordinates
/// - Maidenhead grid locator must be 6 characters
/// - User ID must match authenticated user
/// - Content is trimmed before storage
class DropPointUseCase extends UseCase<Point, DropPointRequest> {
  final IPointsRepository _pointsRepository;

  DropPointUseCase({required IPointsRepository pointsRepository})
      : _pointsRepository = pointsRepository;

  @override
  Future<Point> call(DropPointRequest request) async {
    _validateRequest(request);

    return _pointsRepository.createPoint(
      userId: request.userId,
      content: request.content.trim(),
      location: request.location,
      maidenhead6char: request.maidenhead6char.toUpperCase(),
    );
  }

  void _validateRequest(DropPointRequest request) {
    // Validate userId
    if (request.userId.isEmpty) {
      throw ValidationException('User ID cannot be empty');
    }

    // Validate content
    final content = request.content.trim();
    if (content.isEmpty) {
      throw ValidationException('Point content cannot be empty');
    }

    if (content.length > 280) {
      throw ValidationException(
        'Point content exceeds 280 characters (${content.length}/280)',
      );
    }

    // Validate Maidenhead locator format (6 characters)
    if (request.maidenhead6char.length != 6) {
      throw ValidationException(
        'Maidenhead locator must be exactly 6 characters',
      );
    }

    // Basic format validation: 2 letters, 2 digits, 2 letters (case-insensitive)
    if (!RegExp(r'^[A-Ra-r]{2}[0-9]{2}[A-Xa-x]{2}$')
        .hasMatch(request.maidenhead6char)) {
      throw ValidationException(
        'Invalid Maidenhead locator format (expected: AA00aa)',
      );
    }

    // LocationCoordinate validation is handled by the value object itself
    // No need to validate lat/lon here
  }
}
