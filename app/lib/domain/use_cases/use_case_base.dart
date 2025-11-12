/// Base class for all use cases in the domain layer.
///
/// Use cases encapsulate business logic and orchestrate data flow
/// between repositories, utilities, and value objects.
///
/// Each use case should:
/// - Accept a strongly-typed request object as input
/// - Return a Future containing the result
/// - Perform validation before calling repositories
/// - Let repository exceptions bubble up (don't catch)
///
/// Example:
/// ```dart
/// class DropPointUseCase extends UseCase<Point, DropPointRequest> {
///   final IPointsRepository pointsRepository;
///
///   DropPointUseCase({required this.pointsRepository});
///
///   @override
///   Future<Point> call(DropPointRequest request) async {
///     // Validation
///     _validateContent(request.content);
///
///     // Call repository
///     return pointsRepository.createPoint(...);
///   }
/// }
/// ```
abstract class UseCase<Success, Request> {
  /// Executes the use case with the given request.
  ///
  /// [request] - Strongly-typed input parameters
  ///
  /// Returns a Future containing the result of type [Success].
  ///
  /// Throws domain exceptions for validation errors or repository failures.
  Future<Success> call(Request request);
}
