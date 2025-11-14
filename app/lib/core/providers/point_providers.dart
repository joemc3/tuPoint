import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/feed_state.dart';
import '../../domain/entities/like_state.dart';
import '../../domain/entities/point.dart';
import '../../domain/entities/point_drop_state.dart';
import '../../domain/use_cases/like_use_cases/get_like_count_use_case.dart';
import '../../domain/use_cases/like_use_cases/like_point_use_case.dart';
import '../../domain/use_cases/like_use_cases/unlike_point_use_case.dart';
import '../../domain/use_cases/point_use_cases/drop_point_use_case.dart';
import '../../domain/use_cases/point_use_cases/fetch_nearby_points_use_case.dart';
import '../../presentation/notifiers/feed_notifier.dart';
import '../../presentation/notifiers/like_notifier.dart';
import '../../presentation/notifiers/point_drop_notifier.dart';
import 'location_providers.dart';
import 'repository_providers.dart';

// =============================================================================
// USE CASE PROVIDERS
// =============================================================================

/// Provides the DropPointUseCase instance.
///
/// This use case is responsible for creating new Points (location-based posts).
/// It validates content length (1-280 chars), Maidenhead format, and user ID
/// before creating the Point in the database.
///
/// Dependencies:
/// - [pointsRepositoryProvider]: Points repository for database operations
final dropPointUseCaseProvider = Provider<DropPointUseCase>((ref) {
  final pointsRepository = ref.watch(pointsRepositoryProvider);
  return DropPointUseCase(pointsRepository: pointsRepository);
});

/// Provides the FetchNearbyPointsUseCase instance.
///
/// This use case is responsible for fetching Points within a specified radius
/// of the user's location. It:
/// - Fetches all active points from the database
/// - Filters by radius using Haversine distance calculation (client-side)
/// - Optionally excludes user's own points
/// - Sorts by distance (nearest first)
///
/// Default radius is 5km (5000 meters) for MVP.
///
/// Dependencies:
/// - [pointsRepositoryProvider]: Points repository for database operations
final fetchNearbyPointsUseCaseProvider =
    Provider<FetchNearbyPointsUseCase>((ref) {
  final pointsRepository = ref.watch(pointsRepositoryProvider);
  return FetchNearbyPointsUseCase(pointsRepository: pointsRepository);
});

// =============================================================================
// POINT DROP NOTIFIER & PROVIDERS
// =============================================================================

/// Provides the PointDropNotifier state notifier.
///
/// This notifier manages the complete two-phase point creation flow:
/// 1. **Fetch Location**: Get GPS coordinates from LocationService
/// 2. **Create Point**: Store Point in database via DropPointUseCase
///
/// The notifier handles:
/// - Automatic Maidenhead grid locator conversion
/// - Location permission and service error handling
/// - Content validation (1-280 characters)
/// - Database operation error handling
/// - Two distinct loading states for better UX
///
/// The notifier starts in the [PointDropState.initial] state and transitions
/// through fetchingLocation, dropping, success, and error states as the
/// point creation operation progresses.
///
/// Dependencies:
/// - [locationServiceProvider]: Service for fetching GPS coordinates
/// - [dropPointUseCaseProvider]: Use case for creating Points in database
///
/// Example:
/// ```dart
/// // In a widget - trigger point creation
/// final notifier = ref.read(pointDropNotifierProvider.notifier);
/// await notifier.dropPoint(
///   userId: currentUserId,
///   content: textController.text,
/// );
///
/// // Watch state changes
/// final state = ref.watch(pointDropStateProvider);
/// state.when(
///   initial: () => PointCreationForm(),
///   fetchingLocation: () => LocationLoadingIndicator(),
///   dropping: () => DatabaseLoadingIndicator(),
///   success: (point) => SuccessMessage(point),
///   error: (message) => ErrorMessage(message),
/// );
/// ```
final pointDropNotifierProvider =
    StateNotifierProvider<PointDropNotifier, PointDropState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final dropPointUseCase = ref.watch(dropPointUseCaseProvider);

  return PointDropNotifier(
    locationService: locationService,
    dropPointUseCase: dropPointUseCase,
  );
});

/// Provides the current point drop state.
///
/// This is a convenience provider that exposes the current point drop state
/// from the [pointDropNotifierProvider]. Use this in widgets that only need
/// to read the point drop state without calling point creation methods.
///
/// States:
/// - [PointDropState.initial]: Ready to create a point
/// - [PointDropState.fetchingLocation]: Getting GPS coordinates
/// - [PointDropState.dropping]: Creating point in database
/// - [PointDropState.success]: Point successfully created
/// - [PointDropState.error]: Point creation failed
///
/// Example:
/// ```dart
/// final pointDropState = ref.watch(pointDropStateProvider);
/// pointDropState.when(
///   initial: () => Text('Drop a point at your current location'),
///   fetchingLocation: () => Column(
///     children: [
///       CircularProgressIndicator(),
///       Text('Getting your location...'),
///     ],
///   ),
///   dropping: () => Column(
///     children: [
///       CircularProgressIndicator(),
///       Text('Creating point...'),
///     ],
///   ),
///   success: (point) => SuccessCard(
///     title: 'Point Dropped!',
///     subtitle: 'Your point is now visible to nearby users',
///   ),
///   error: (message) => ErrorCard(
///     message: message,
///     onRetry: () => ref.read(pointDropNotifierProvider.notifier).reset(),
///   ),
/// );
/// ```
final pointDropStateProvider = Provider<PointDropState>((ref) {
  return ref.watch(pointDropNotifierProvider);
});

/// Provides whether a point creation operation is currently in progress.
///
/// This is a convenience provider that returns true if the point drop state
/// is either fetchingLocation or dropping, and false otherwise.
///
/// Use this provider to:
/// - Disable form submission buttons during creation
/// - Show global loading overlays
/// - Prevent navigation during operations
/// - Conditionally render UI based on loading state
///
/// Example:
/// ```dart
/// final isDroppingPoint = ref.watch(isDroppingPointProvider);
///
/// ElevatedButton(
///   onPressed: isDroppingPoint ? null : _handleDropPoint,
///   child: isDroppingPoint
///     ? SizedBox(
///         width: 20,
///         height: 20,
///         child: CircularProgressIndicator(strokeWidth: 2),
///       )
///     : Text('Drop Point'),
/// );
/// ```
///
/// Or for more granular control:
/// ```dart
/// final isDroppingPoint = ref.watch(isDroppingPointProvider);
///
/// if (isDroppingPoint) {
///   return LoadingOverlay(
///     child: PointCreationForm(),
///   );
/// }
/// return PointCreationForm();
/// ```
final isDroppingPointProvider = Provider<bool>((ref) {
  final pointDropState = ref.watch(pointDropStateProvider);

  return pointDropState.maybeWhen(
    fetchingLocation: () => true,
    dropping: () => true,
    orElse: () => false,
  );
});

// =============================================================================
// FEED NOTIFIER & PROVIDERS
// =============================================================================

/// Provides the FeedNotifier state notifier.
///
/// This notifier manages the nearby points feed with real-time location integration.
/// It handles:
/// - Fetching nearby Points within 5km radius (MVP default)
/// - Integration with LocationService for GPS coordinates
/// - Automatic 5km radius filtering via FetchNearbyPointsUseCase
/// - Excluding user's own points from feed
/// - Error handling for both location and database errors
/// - State management for loading and error states
///
/// The notifier starts in the [FeedState.initial] state and transitions
/// through loading, loaded, and error states as the feed loading operation
/// progresses.
///
/// Dependencies:
/// - [locationServiceProvider]: Service for fetching GPS coordinates
/// - [fetchNearbyPointsUseCaseProvider]: Use case for fetching and filtering Points
///
/// Example:
/// ```dart
/// // In a widget - trigger feed load
/// final notifier = ref.read(feedNotifierProvider.notifier);
/// final userId = ref.read(currentUserIdProvider);
/// await notifier.fetchNearbyPoints(userId: userId);
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
final feedNotifierProvider =
    StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final fetchNearbyPointsUseCase = ref.watch(fetchNearbyPointsUseCaseProvider);

  return FeedNotifier(
    locationService: locationService,
    fetchNearbyPointsUseCase: fetchNearbyPointsUseCase,
  );
});

/// Provides the current feed state.
///
/// This is a convenience provider that exposes the current feed state
/// from the [feedNotifierProvider]. Use this in widgets that only need
/// to read the feed state without calling feed loading methods.
///
/// States:
/// - [FeedState.initial]: No feed loaded yet
/// - [FeedState.loading]: Feed is being fetched
/// - [FeedState.loaded]: Feed successfully loaded with points and location
/// - [FeedState.error]: Feed loading failed
///
/// Example:
/// ```dart
/// final feedState = ref.watch(feedStateProvider);
/// feedState.when(
///   initial: () => Center(
///     child: Column(
///       children: [
///         Icon(Icons.explore),
///         Text('Pull down to load nearby points'),
///       ],
///     ),
///   ),
///   loading: () => Center(
///     child: Column(
///       children: [
///         CircularProgressIndicator(),
///         SizedBox(height: 16),
///         Text('Loading nearby points...'),
///       ],
///     ),
///   ),
///   loaded: (points, userLocation) {
///     if (points.isEmpty) {
///       return EmptyFeedView(
///         message: 'No points nearby. Be the first to drop one!',
///       );
///     }
///     return ListView.builder(
///       itemCount: points.length,
///       itemBuilder: (context, index) => PointCard(
///         point: points[index],
///         userLocation: userLocation,
///       ),
///     );
///   },
///   error: (message) => ErrorView(
///     message: message,
///     onRetry: () {
///       final userId = ref.read(currentUserIdProvider);
///       ref.read(feedNotifierProvider.notifier).fetchNearbyPoints(
///         userId: userId,
///       );
///     },
///   ),
/// );
/// ```
final feedStateProvider = Provider<FeedState>((ref) {
  return ref.watch(feedNotifierProvider);
});

/// Provides the list of nearby points from the loaded feed state.
///
/// This convenience provider extracts the points list from the loaded state,
/// returning an empty list if the feed is not in the loaded state.
///
/// Use this when you only need the points list without handling all feed states,
/// such as for calculating statistics or filtering.
///
/// Returns:
/// - List of Points if feed is in loaded state
/// - Empty list otherwise (initial, loading, error states)
///
/// Example:
/// ```dart
/// // Get points count
/// final nearbyPoints = ref.watch(nearbyPointsProvider);
/// final count = nearbyPoints.length;
/// Text('$count points nearby');
///
/// // Filter points by criteria
/// final nearbyPoints = ref.watch(nearbyPointsProvider);
/// final recentPoints = nearbyPoints
///     .where((p) => p.createdAt.isAfter(DateTime.now().subtract(Duration(hours: 1))))
///     .toList();
/// ```
final nearbyPointsProvider = Provider<List<Point>>((ref) {
  final feedState = ref.watch(feedStateProvider);

  return feedState.maybeWhen(
    loaded: (points, _) => points,
    orElse: () => [],
  );
});

/// Provides whether the feed is currently loading.
///
/// This is a convenience provider that returns true if the feed state
/// is loading, and false otherwise.
///
/// Use this provider to:
/// - Show loading indicators in the UI
/// - Disable refresh buttons during loading
/// - Show skeleton screens
/// - Conditionally render UI based on loading state
///
/// Example:
/// ```dart
/// final isLoadingFeed = ref.watch(isLoadingFeedProvider);
///
/// // Disable pull-to-refresh during load
/// RefreshIndicator(
///   onRefresh: isLoadingFeed ? null : _handleRefresh,
///   child: FeedList(),
/// );
///
/// // Show loading overlay
/// if (isLoadingFeed) {
///   return Stack(
///     children: [
///       FeedList(),
///       LoadingOverlay(),
///     ],
///   );
/// }
///
/// // Disable refresh button
/// IconButton(
///   onPressed: isLoadingFeed ? null : _handleRefresh,
///   icon: Icon(Icons.refresh),
/// );
/// ```
final isLoadingFeedProvider = Provider<bool>((ref) {
  final feedState = ref.watch(feedStateProvider);

  return feedState.maybeWhen(
    loading: () => true,
    orElse: () => false,
  );
});

// =============================================================================
// LIKE USE CASE PROVIDERS
// =============================================================================

/// Provides the LikePointUseCase instance.
///
/// This use case is responsible for creating like records when a user
/// likes a point. It validates that the user hasn't already liked the
/// point and enforces RLS policies.
///
/// Dependencies:
/// - [likesRepositoryProvider]: Likes repository for database operations
final likePointUseCaseProvider = Provider<LikePointUseCase>((ref) {
  final likesRepository = ref.watch(likesRepositoryProvider);
  return LikePointUseCase(likesRepository: likesRepository);
});

/// Provides the UnlikePointUseCase instance.
///
/// This use case is responsible for removing like records when a user
/// unlikes a point. It validates that the like exists and that the user
/// owns it.
///
/// Dependencies:
/// - [likesRepositoryProvider]: Likes repository for database operations
final unlikePointUseCaseProvider = Provider<UnlikePointUseCase>((ref) {
  final likesRepository = ref.watch(likesRepositoryProvider);
  return UnlikePointUseCase(likesRepository: likesRepository);
});

/// Provides the GetLikeCountUseCase instance.
///
/// This use case is responsible for fetching the total number of likes
/// for a specific point. Used to display like counts in the UI.
///
/// Dependencies:
/// - [likesRepositoryProvider]: Likes repository for database operations
final getLikeCountUseCaseProvider = Provider<GetLikeCountUseCase>((ref) {
  final likesRepository = ref.watch(likesRepositoryProvider);
  return GetLikeCountUseCase(likesRepository: likesRepository);
});

// =============================================================================
// LIKE NOTIFIER & PROVIDERS
// =============================================================================

/// Provides the LikeNotifier state notifier.
///
/// This notifier manages like state and operations for multiple points.
/// It handles:
/// - Like/unlike operations with optimistic UI updates
/// - Per-point like counts
/// - Per-point user like status (has user liked this point?)
/// - Per-point loading states during operations
/// - Per-point error handling with rollback on failure
/// - Initialization of like state for individual points
///
/// The notifier implements an optimistic update pattern where the UI
/// updates immediately before server confirmation, providing instant
/// feedback. If the server operation fails, the state is rolled back
/// to the previous value.
///
/// Dependencies:
/// - [likesRepositoryProvider]: Repository for like database operations
/// - [likePointUseCaseProvider]: Use case for creating likes
/// - [unlikePointUseCaseProvider]: Use case for removing likes
/// - [getLikeCountUseCaseProvider]: Use case for fetching like counts
///
/// Example:
/// ```dart
/// // Toggle like for a point
/// final notifier = ref.read(likeNotifierProvider.notifier);
/// await notifier.toggleLike(pointId: point.id, userId: currentUserId);
///
/// // Initialize like state when displaying a point
/// await notifier.initializeLikeStateForPoint(
///   pointId: point.id,
///   userId: currentUserId,
/// );
///
/// // Watch state changes
/// final likeState = ref.watch(likeStateProvider);
/// final isLiked = likeState.likedByUser[point.id] ?? false;
/// final likeCount = likeState.likeCounts[point.id] ?? 0;
/// ```
final likeNotifierProvider =
    StateNotifierProvider<LikeNotifier, LikeState>((ref) {
  final likesRepository = ref.watch(likesRepositoryProvider);
  final likePointUseCase = ref.watch(likePointUseCaseProvider);
  final unlikePointUseCase = ref.watch(unlikePointUseCaseProvider);
  final getLikeCountUseCase = ref.watch(getLikeCountUseCaseProvider);

  return LikeNotifier(
    likesRepository: likesRepository,
    likePointUseCase: likePointUseCase,
    unlikePointUseCase: unlikePointUseCase,
    getLikeCountUseCase: getLikeCountUseCase,
  );
});

/// Provides the current like state.
///
/// This is a convenience provider that exposes the current like state
/// from the [likeNotifierProvider]. Use this in widgets that only need
/// to read like state without calling like operations.
///
/// The state contains maps for:
/// - likedByUser: Whether current user has liked each point
/// - likeCounts: Total like count for each point
/// - loadingStates: Whether toggle operation is in progress for each point
/// - errors: Error messages for failed operations on each point
///
/// Example:
/// ```dart
/// final likeState = ref.watch(likeStateProvider);
/// final isLiked = likeState.likedByUser[pointId] ?? false;
/// final likeCount = likeState.likeCounts[pointId] ?? 0;
/// final isLoading = likeState.loadingStates[pointId] ?? false;
/// final error = likeState.errors[pointId];
/// ```
final likeStateProvider = Provider<LikeState>((ref) {
  return ref.watch(likeNotifierProvider);
});

/// Provides the like status for a specific point.
///
/// This is a family provider that takes a point ID and returns whether
/// the current user has liked that point.
///
/// Returns:
/// - `true` if user has liked the point
/// - `false` if user has not liked the point or status not yet fetched
///
/// Use this provider to:
/// - Render like button state (filled vs outlined heart)
/// - Show "You liked this" indicators
/// - Filter feed by liked points
///
/// Example:
/// ```dart
/// // In a PointCard widget
/// final isLiked = ref.watch(pointLikeStatusProvider(point.id));
///
/// Icon(
///   isLiked ? Icons.favorite : Icons.favorite_border,
///   color: isLiked ? Colors.red : Colors.grey,
/// );
/// ```
final pointLikeStatusProvider = Provider.family<bool, String>((ref, pointId) {
  final likeState = ref.watch(likeStateProvider);
  return likeState.likedByUser[pointId] ?? false;
});

/// Provides the like count for a specific point.
///
/// This is a family provider that takes a point ID and returns the
/// total number of likes for that point.
///
/// Returns:
/// - Number of likes (0 or greater)
/// - `0` if like count not yet fetched
///
/// Use this provider to:
/// - Display like counts in point cards
/// - Show "X likes" text
/// - Determine popularity of points
///
/// Example:
/// ```dart
/// // In a PointCard widget
/// final likeCount = ref.watch(pointLikeCountProvider(point.id));
///
/// Text(
///   likeCount == 1 ? '1 like' : '$likeCount likes',
///   style: Theme.of(context).textTheme.bodySmall,
/// );
/// ```
final pointLikeCountProvider = Provider.family<int, String>((ref, pointId) {
  final likeState = ref.watch(likeStateProvider);
  return likeState.likeCounts[pointId] ?? 0;
});
