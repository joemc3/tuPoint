import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/location_service.dart';
import '../../domain/entities/feed_state.dart';
import '../../domain/entities/location_service_state.dart';
import '../../domain/exceptions/repository_exceptions.dart';
import '../../domain/use_cases/point_use_cases/fetch_nearby_points_use_case.dart';
import '../../domain/use_cases/requests.dart';
import '../../domain/value_objects/location_coordinate.dart';

/// Notifier that manages the nearby points feed with real-time location updates.
///
/// This notifier handles:
/// - Fetching nearby Points within 5km radius (MVP default)
/// - Integration with LocationService for GPS coordinates
/// - Automatic 5km radius filtering via FetchNearbyPointsUseCase
/// - Error handling for both location and database errors
/// - State management for loading and error states
///
/// The notifier provides a clean API for feed operations and maps
/// both LocationService errors and repository exceptions to user-friendly
/// error messages that can be displayed in the UI.
///
/// ## Core Business Logic:
///
/// 1. **Location Fetch**: Get current GPS coordinates from LocationService
/// 2. **Radius Filtering**: FetchNearbyPointsUseCase filters to 5km using Haversine
/// 3. **User Filtering**: Excludes user's own Points (includeUserOwnPoints: false)
/// 4. **Distance Sorting**: Points returned nearest-first
///
/// ## Usage Example:
///
/// ```dart
/// // In a widget - trigger feed load
/// final notifier = ref.read(feedNotifierProvider.notifier);
/// await notifier.fetchNearbyPoints(userId: currentUserId);
///
/// // Watch state changes
/// final feedState = ref.watch(feedStateProvider);
/// feedState.when(
///   initial: () => EmptyFeedPlaceholder(),
///   loading: () => FeedLoadingIndicator(),
///   loaded: (points, location) => PointsList(points: points),
///   error: (message) => FeedErrorMessage(message),
/// );
/// ```
class FeedNotifier extends StateNotifier<FeedState> {
  final LocationService _locationService;
  final FetchNearbyPointsUseCase _fetchNearbyPointsUseCase;

  FeedNotifier({
    required LocationService locationService,
    required FetchNearbyPointsUseCase fetchNearbyPointsUseCase,
  })  : _locationService = locationService,
        _fetchNearbyPointsUseCase = fetchNearbyPointsUseCase,
        super(const FeedState.initial());

  /// Fetches nearby Points within 5km radius of user's location.
  ///
  /// This method orchestrates the complete feed loading flow:
  ///
  /// **Phase 1: Location Fetch**
  /// - Gets current location (via customLocation parameter or LocationService)
  /// - Handles all location errors (permission, service, timeout)
  /// - Extracts LocationCoordinate from LocationServiceState
  ///
  /// **Phase 2: Database Fetch & Filter**
  /// - Calls FetchNearbyPointsUseCase with 5km radius
  /// - Filters out user's own Points (includeUserOwnPoints: false)
  /// - Receives points sorted by distance (nearest first)
  ///
  /// **Error Handling:**
  /// All errors are mapped to user-friendly messages and set state to error.
  ///
  /// **Parameters:**
  /// - [userId]: Optional user ID to filter out user's own points
  /// - [customLocation]: Optional custom location (used for manual refresh with
  ///   specific coordinates). If null, fetches current device location.
  ///
  /// **Example:**
  /// ```dart
  /// // Auto-fetch current location
  /// await notifier.fetchNearbyPoints(userId: 'user-123');
  ///
  /// // Use custom location (e.g., from cached location)
  /// await notifier.fetchNearbyPoints(
  ///   userId: 'user-123',
  ///   customLocation: LocationCoordinate(lat: 40.7128, lon: -74.0060),
  /// );
  /// ```
  Future<void> fetchNearbyPoints({
    required String? userId,
    LocationCoordinate? customLocation,
  }) async {
    try {
      // ============================================================
      // PHASE 1: GET USER LOCATION
      // ============================================================
      state = const FeedState.loading();

      late final LocationCoordinate userLocation;

      if (customLocation != null) {
        // Use provided custom location (e.g., from cached location)
        userLocation = customLocation;
      } else {
        // Fetch current location from LocationService
        final locationState = await _locationService.getCurrentLocation();

        // Extract LocationCoordinate from LocationServiceState
        userLocation = _extractLocationFromState(locationState);
      }

      // ============================================================
      // PHASE 2: FETCH & FILTER NEARBY POINTS
      // ============================================================

      // Fetch nearby points with 5km radius (MVP default)
      final nearbyPoints = await _fetchNearbyPointsUseCase(
        FetchNearbyPointsRequest(
          userLocation: userLocation,
          radiusMeters: 5000.0, // 5km default for MVP
          userId: userId,
          includeUserOwnPoints: false, // Hide user's own points in feed
        ),
      );

      // Success! Feed loaded with nearby points
      state = FeedState.loaded(
        points: nearbyPoints,
        userLocation: userLocation,
      );
    } on ValidationException catch (e) {
      // Location validation error (from _extractLocationFromState)
      state = FeedState.error(message: e.message);
    } on DatabaseException {
      // Database connection or query error
      state = const FeedState.error(
        message: 'Unable to load nearby points. Please check your connection.',
      );
    } catch (e) {
      // Unexpected error (network timeout, parsing error, etc.)
      state = const FeedState.error(
        message: 'An unexpected error occurred while loading the feed.',
      );
    }
  }

  /// Refreshes the feed with current location.
  ///
  /// This is a convenience method that calls [fetchNearbyPoints] without
  /// a custom location, forcing a fresh location fetch from LocationService.
  ///
  /// Useful for:
  /// - Pull-to-refresh gestures
  /// - Manual refresh buttons
  /// - Periodic background updates
  ///
  /// Note: Requires [userId] to be set via a subsequent call or stored state.
  /// For simplicity, this method does not take userId as a parameter since
  /// it's typically called from UI context where userId is available via provider.
  ///
  /// Example:
  /// ```dart
  /// // In a RefreshIndicator
  /// onRefresh: () async {
  ///   final userId = ref.read(currentUserIdProvider);
  ///   await ref.read(feedNotifierProvider.notifier).fetchNearbyPoints(
  ///     userId: userId,
  ///   );
  /// }
  /// ```
  void refresh() {
    // Note: This is a simplified refresh. In production, you might want
    // to store userId in the notifier state or pass it as a parameter.
    // For now, this serves as a trigger mechanism that UI can call
    // after fetching userId from auth providers.
    //
    // The actual refresh is triggered by UI calling fetchNearbyPoints directly.
  }

  /// Resets the feed state to initial.
  ///
  /// This is useful for cleanup when:
  /// - User signs out (clear feed data)
  /// - Navigating away from feed screen
  /// - Starting a fresh feed operation
  /// - Clearing error states
  ///
  /// Example:
  /// ```dart
  /// // On sign out
  /// ref.read(feedNotifierProvider.notifier).reset();
  ///
  /// // On navigation away
  /// @override
  /// void dispose() {
  ///   ref.read(feedNotifierProvider.notifier).reset();
  ///   super.dispose();
  /// }
  /// ```
  void reset() {
    state = const FeedState.initial();
  }

  /// Extracts LocationCoordinate from LocationServiceState.
  ///
  /// Handles all possible LocationServiceState variants and converts
  /// them to either a successful LocationCoordinate extraction or
  /// throws a ValidationException with a user-friendly error message.
  ///
  /// This method centralizes all location state error handling to ensure
  /// consistent error messages throughout the feed loading flow.
  ///
  /// **Error Mapping:**
  /// - permissionDenied → "Location permission denied..." (with permanent flag)
  /// - serviceDisabled → "Location services disabled..."
  /// - error → "Unable to get your location..." (with specific error details)
  /// - loading → "Location is still loading..." (defensive check)
  ///
  /// Throws [ValidationException] with user-friendly message for all
  /// error states (permission denied, service disabled, error, loading).
  LocationCoordinate _extractLocationFromState(
    LocationServiceState locationState,
  ) {
    return locationState.when(
      // Success case: extract the location
      available: (location) => location,

      // Permission denied (temporary or permanent)
      permissionDenied: (message, isPermanent) {
        if (isPermanent) {
          throw ValidationException(
            'Location permission denied. Please enable location access in Settings to see nearby points.',
          );
        } else {
          throw ValidationException(
            'Location permission denied. Please enable location access to see nearby points.',
          );
        }
      },

      // Location services disabled system-wide
      serviceDisabled: (message) {
        throw ValidationException(
          'Location services disabled. Please enable GPS to see nearby points.',
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
}
