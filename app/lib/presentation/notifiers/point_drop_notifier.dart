import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/location_service.dart';
import '../../domain/entities/location_service_state.dart';
import '../../domain/entities/point_drop_state.dart';
import '../../domain/exceptions/repository_exceptions.dart';
import '../../domain/use_cases/point_use_cases/drop_point_use_case.dart';
import '../../domain/use_cases/requests.dart';
import '../../domain/utils/maidenhead_converter.dart';
import '../../domain/value_objects/location_coordinate.dart';

/// Notifier that manages point creation state and operations.
///
/// This notifier handles the complete two-phase point creation flow:
/// 1. Fetch GPS location from LocationService
/// 2. Create Point in database via DropPointUseCase
///
/// The notifier provides:
/// - Automatic location fetching during point creation
/// - Maidenhead grid locator conversion from GPS coordinates
/// - Comprehensive error handling with user-friendly messages
/// - State management for both loading phases and error states
///
/// ## Usage Example:
///
/// ```dart
/// // In a widget
/// final notifier = ref.read(pointDropNotifierProvider.notifier);
/// await notifier.dropPoint(
///   userId: currentUserId,
///   content: 'Hello from tuPoint!',
/// );
///
/// // Watch the state
/// final state = ref.watch(pointDropStateProvider);
/// state.when(
///   initial: () => Text('Ready to drop'),
///   fetchingLocation: () => Text('Getting location...'),
///   dropping: () => Text('Creating point...'),
///   success: (point) => Text('Point created!'),
///   error: (message) => Text('Error: $message'),
/// );
/// ```
class PointDropNotifier extends StateNotifier<PointDropState> {
  final LocationService _locationService;
  final DropPointUseCase _dropPointUseCase;

  PointDropNotifier({
    required LocationService locationService,
    required DropPointUseCase dropPointUseCase,
  })  : _locationService = locationService,
        _dropPointUseCase = dropPointUseCase,
        super(const PointDropState.initial());

  /// Creates a new Point at the user's current location.
  ///
  /// This method orchestrates the complete two-phase point creation flow:
  ///
  /// **Phase 1: Location Fetch**
  /// - Sets state to `fetchingLocation()`
  /// - Calls LocationService to get current GPS coordinates
  /// - Handles all location errors (permission, service, timeout)
  /// - Converts coordinates to Maidenhead 6-char grid locator
  ///
  /// **Phase 2: Database Creation**
  /// - Sets state to `dropping()`
  /// - Calls DropPointUseCase with content, location, and Maidenhead
  /// - Handles validation and database errors
  /// - Sets state to `success(point)` on completion
  ///
  /// **Error Handling:**
  /// All errors are mapped to user-friendly messages and set state to `error()`.
  ///
  /// **Parameters:**
  /// - [userId]: ID of the authenticated user creating the Point
  /// - [content]: Text content for the Point (1-280 characters)
  ///
  /// **Throws:**
  /// This method does not throw exceptions - all errors are captured
  /// in the error state with user-friendly messages.
  ///
  /// **Example:**
  /// ```dart
  /// await ref.read(pointDropNotifierProvider.notifier).dropPoint(
  ///   userId: 'user-123',
  ///   content: 'Coffee shop is packed today!',
  /// );
  /// ```
  Future<void> dropPoint({
    required String userId,
    required String content,
  }) async {
    try {
      // ============================================================
      // PHASE 1: FETCH LOCATION
      // ============================================================
      state = const PointDropState.fetchingLocation();

      // Validate content before fetching location to fail fast
      _validateContent(content);

      // Get current location from LocationService
      final locationState = await _locationService.getCurrentLocation();

      // Extract LocationCoordinate from LocationServiceState
      final location = _extractLocationFromState(locationState);

      // Convert GPS coordinates to Maidenhead 6-char grid locator
      final maidenhead = MaidenheadConverter.toMaidenhead6Char(location);

      // ============================================================
      // PHASE 2: CREATE POINT IN DATABASE
      // ============================================================
      state = const PointDropState.dropping();

      // Create Point via use case
      final point = await _dropPointUseCase(
        DropPointRequest(
          userId: userId,
          content: content.trim(),
          location: location,
          maidenhead6char: maidenhead,
        ),
      );

      // Success! Point created successfully
      state = PointDropState.success(point: point);
    } on ValidationException catch (e) {
      // Content validation failed (empty, too long, etc.)
      state = PointDropState.error(message: e.message);
    } on UnauthorizedException {
      // User not authorized to create point (unlikely, but possible)
      state = const PointDropState.error(
        message: 'You are not authorized to create this point.',
      );
    } on DatabaseException {
      // Database connection or query error
      state = const PointDropState.error(
        message: 'Unable to create point. Please check your connection.',
      );
    } catch (e) {
      // Unexpected error (network timeout, parsing error, etc.)
      state = const PointDropState.error(
        message: 'An unexpected error occurred while creating point.',
      );
    }
  }

  /// Validates content before attempting point creation.
  ///
  /// Validation rules:
  /// - Content cannot be empty (after trimming)
  /// - Content cannot exceed 280 characters
  ///
  /// Throws [ValidationException] with user-friendly message if invalid.
  void _validateContent(String content) {
    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      throw ValidationException('Point content cannot be empty');
    }

    if (trimmedContent.length > 280) {
      throw ValidationException(
        'Point content exceeds 280 characters (${trimmedContent.length}/280)',
      );
    }
  }

  /// Extracts LocationCoordinate from LocationServiceState.
  ///
  /// Handles all possible LocationServiceState variants and converts
  /// them to either a successful LocationCoordinate extraction or
  /// throws a ValidationException with a user-friendly error message.
  ///
  /// This method centralizes all location state error handling to ensure
  /// consistent error messages throughout the point creation flow.
  ///
  /// Throws [ValidationException] with user-friendly message for all
  /// error states (permission denied, service disabled, error, loading).
  LocationCoordinate _extractLocationFromState(
      LocationServiceState locationState) {
    return locationState.when(
      // Success case: extract the location
      available: (location) => location,

      // Permission denied (temporary or permanent)
      permissionDenied: (message, isPermanent) {
        if (isPermanent) {
          throw ValidationException(
            'Location permission permanently denied. Please enable location access in Settings.',
          );
        } else {
          throw ValidationException(
            'Location permission denied. Please enable location access.',
          );
        }
      },

      // Location services disabled system-wide
      serviceDisabled: (message) {
        throw ValidationException(
          'Location services disabled. Please enable GPS in device settings.',
        );
      },

      // Generic location error (timeout, no signal, hardware issue)
      error: (message) {
        throw ValidationException(
          'Unable to get your location. $message',
        );
      },

      // Loading state - this should not happen since getCurrentLocation()
      // returns a resolved state, but handle defensively
      loading: () {
        throw ValidationException(
          'Location is still loading. Please try again.',
        );
      },
    );
  }

  /// Resets the point drop state to initial.
  ///
  /// This is useful for cleanup when:
  /// - User wants to create another point after success/error
  /// - User navigates away from point creation screen
  /// - Form needs to be cleared
  ///
  /// Example:
  /// ```dart
  /// // After successful point creation, navigate and reset
  /// ref.read(pointDropNotifierProvider.notifier).reset();
  /// Navigator.pop(context);
  /// ```
  void reset() {
    state = const PointDropState.initial();
  }
}
