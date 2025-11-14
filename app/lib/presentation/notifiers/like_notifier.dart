import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/like_state.dart';
import '../../domain/exceptions/repository_exceptions.dart';
import '../../domain/repositories/i_likes_repository.dart';
import '../../domain/use_cases/like_use_cases/get_like_count_use_case.dart';
import '../../domain/use_cases/like_use_cases/like_point_use_case.dart';
import '../../domain/use_cases/like_use_cases/unlike_point_use_case.dart';
import '../../domain/use_cases/requests.dart';

/// Notifier that manages like state and operations for multiple points.
///
/// This notifier handles:
/// - Like/unlike operations with optimistic UI updates
/// - Per-point like counts
/// - Per-point user like status (has user liked this point?)
/// - Per-point loading states during operations
/// - Per-point error handling with rollback on failure
/// - Initialization of like state for individual points
///
/// Design Principles:
/// 1. **Optimistic Updates**: UI updates immediately before server confirmation
/// 2. **Rollback on Error**: Failed operations restore previous state
/// 3. **Per-Point State**: Each point maintains independent state
/// 4. **Concurrent Operations**: Multiple points can be toggled simultaneously
/// 5. **Error Isolation**: Errors on one point don't affect others
///
/// Unlike ProfileNotifier or FeedNotifier which manage a single entity,
/// this notifier tracks state for multiple points simultaneously using maps.
///
/// Example Usage:
/// ```dart
/// // Toggle like for a point
/// final notifier = ref.read(likeNotifierProvider.notifier);
/// await notifier.toggleLike(pointId: '123', userId: 'abc');
///
/// // Initialize like state when displaying a point
/// await notifier.initializeLikeStateForPoint(
///   pointId: '123',
///   userId: 'abc',
/// );
///
/// // Watch state in UI
/// final likeState = ref.watch(likeStateProvider);
/// final isLiked = likeState.likedByUser['123'] ?? false;
/// final likeCount = likeState.likeCounts['123'] ?? 0;
/// final isLoading = likeState.loadingStates['123'] ?? false;
/// ```
class LikeNotifier extends StateNotifier<LikeState> {
  final ILikesRepository _likesRepository;
  final LikePointUseCase _likePointUseCase;
  final UnlikePointUseCase _unlikePointUseCase;
  final GetLikeCountUseCase _getLikeCountUseCase;

  LikeNotifier({
    required ILikesRepository likesRepository,
    required LikePointUseCase likePointUseCase,
    required UnlikePointUseCase unlikePointUseCase,
    required GetLikeCountUseCase getLikeCountUseCase,
  })  : _likesRepository = likesRepository,
        _likePointUseCase = likePointUseCase,
        _unlikePointUseCase = unlikePointUseCase,
        _getLikeCountUseCase = getLikeCountUseCase,
        super(const LikeState());

  /// Toggles like/unlike for a point with optimistic UI updates.
  ///
  /// This method implements an optimistic update pattern:
  /// 1. Immediately update UI (toggle liked status, adjust count)
  /// 2. Call server API to persist the change
  /// 3. If server call fails, rollback to previous state
  ///
  /// The user sees instant feedback, and the UI only reverts if the
  /// operation fails. This creates a responsive experience even on
  /// slow connections.
  ///
  /// Parameters:
  /// - [pointId]: UUID of the point to like/unlike
  /// - [userId]: UUID of the current user (must match authenticated user)
  ///
  /// State Changes:
  /// - Sets loadingStates[pointId] = true during operation
  /// - Toggles likedByUser[pointId] immediately
  /// - Increments/decrements likeCounts[pointId] immediately
  /// - Clears errors[pointId] on start
  /// - Rolls back likedByUser and likeCounts on error
  /// - Sets errors[pointId] on failure
  ///
  /// Example:
  /// ```dart
  /// // In a widget with like button
  /// IconButton(
  ///   icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
  ///   onPressed: isLoading ? null : () async {
  ///     await ref.read(likeNotifierProvider.notifier).toggleLike(
  ///       pointId: point.id,
  ///       userId: currentUserId,
  ///     );
  ///   },
  /// );
  /// ```
  Future<void> toggleLike({
    required String pointId,
    required String userId,
  }) async {
    // Get current state for this point (defaults for uninitialized points)
    final currentlyLiked = state.likedByUser[pointId] ?? false;
    final currentCount = state.likeCounts[pointId] ?? 0;

    // Calculate optimistic values
    final newLikedStatus = !currentlyLiked;
    final newCount = currentlyLiked ? currentCount - 1 : currentCount + 1;

    try {
      // Optimistic update: Update UI immediately
      state = state.copyWith(
        likedByUser: {...state.likedByUser, pointId: newLikedStatus},
        likeCounts: {...state.likeCounts, pointId: newCount},
        loadingStates: {...state.loadingStates, pointId: true},
        errors: {...state.errors, pointId: null}, // Clear any previous error
      );

      // Call appropriate use case based on current state
      if (currentlyLiked) {
        // User is unliking
        await _unlikePointUseCase(
          UnlikePointRequest(pointId: pointId, userId: userId),
        );
      } else {
        // User is liking
        await _likePointUseCase(
          LikePointRequest(pointId: pointId, userId: userId),
        );
      }

      // Success: Keep optimistic state, just clear loading
      state = state.copyWith(
        loadingStates: {...state.loadingStates, pointId: false},
      );
    } on DuplicateLikeException {
      // Shouldn't happen with optimistic updates, but handle gracefully
      // Rollback to previous state
      state = state.copyWith(
        likedByUser: {...state.likedByUser, pointId: currentlyLiked},
        likeCounts: {...state.likeCounts, pointId: currentCount},
        loadingStates: {...state.loadingStates, pointId: false},
        errors: {
          ...state.errors,
          pointId: 'You have already liked this point.',
        },
      );
    } on NotFoundException {
      // Point may have been deleted
      state = state.copyWith(
        likedByUser: {...state.likedByUser, pointId: currentlyLiked},
        likeCounts: {...state.likeCounts, pointId: currentCount},
        loadingStates: {...state.loadingStates, pointId: false},
        errors: {
          ...state.errors,
          pointId: 'Unable to update like. Point may have been deleted.',
        },
      );
    } on UnauthorizedException {
      // User is not authorized (shouldn't happen in normal flow)
      state = state.copyWith(
        likedByUser: {...state.likedByUser, pointId: currentlyLiked},
        likeCounts: {...state.likeCounts, pointId: currentCount},
        loadingStates: {...state.loadingStates, pointId: false},
        errors: {
          ...state.errors,
          pointId: 'You are not authorized to perform this action.',
        },
      );
    } on DatabaseException {
      // Network or database error
      state = state.copyWith(
        likedByUser: {...state.likedByUser, pointId: currentlyLiked},
        likeCounts: {...state.likeCounts, pointId: currentCount},
        loadingStates: {...state.loadingStates, pointId: false},
        errors: {
          ...state.errors,
          pointId: 'Unable to update like. Please check your connection.',
        },
      );
    } catch (e) {
      // Unexpected error
      state = state.copyWith(
        likedByUser: {...state.likedByUser, pointId: currentlyLiked},
        likeCounts: {...state.likeCounts, pointId: currentCount},
        loadingStates: {...state.loadingStates, pointId: false},
        errors: {
          ...state.errors,
          pointId: 'An unexpected error occurred.',
        },
      );
    }
  }

  /// Fetches the like count for a specific point.
  ///
  /// This method queries the database for the total number of likes
  /// on a point and updates the likeCounts map.
  ///
  /// Use this to:
  /// - Initialize like count when displaying a point
  /// - Refresh like count after operations
  /// - Verify optimistic update was correct
  ///
  /// Parameters:
  /// - [pointId]: UUID of the point to fetch like count for
  ///
  /// State Changes:
  /// - Sets loadingStates[pointId] = true during fetch
  /// - Updates likeCounts[pointId] with result
  /// - Sets errors[pointId] on failure
  ///
  /// Example:
  /// ```dart
  /// // Fetch like count when displaying a point
  /// useEffect(() {
  ///   ref.read(likeNotifierProvider.notifier).fetchLikeCount(point.id);
  ///   return null;
  /// }, [point.id]);
  /// ```
  Future<void> fetchLikeCount(String pointId) async {
    try {
      // Set loading state
      state = state.copyWith(
        loadingStates: {...state.loadingStates, pointId: true},
        errors: {...state.errors, pointId: null},
      );

      // Fetch like count from database
      final count = await _getLikeCountUseCase(
        GetLikeCountRequest(pointId: pointId),
      );

      // Update state with result
      state = state.copyWith(
        likeCounts: {...state.likeCounts, pointId: count},
        loadingStates: {...state.loadingStates, pointId: false},
      );
    } on ValidationException catch (e) {
      state = state.copyWith(
        loadingStates: {...state.loadingStates, pointId: false},
        errors: {...state.errors, pointId: e.message},
      );
    } on DatabaseException {
      state = state.copyWith(
        loadingStates: {...state.loadingStates, pointId: false},
        errors: {
          ...state.errors,
          pointId: 'Unable to fetch like count. Please check your connection.',
        },
      );
    } catch (e) {
      state = state.copyWith(
        loadingStates: {...state.loadingStates, pointId: false},
        errors: {
          ...state.errors,
          pointId: 'An unexpected error occurred while fetching like count.',
        },
      );
    }
  }

  /// Checks if the current user has liked a specific point.
  ///
  /// This method queries the database to determine whether the user
  /// has an active like record for the point, and updates the
  /// likedByUser map.
  ///
  /// Use this to:
  /// - Initialize like status when displaying a point
  /// - Verify optimistic update was correct
  /// - Sync UI after background operations
  ///
  /// Parameters:
  /// - [pointId]: UUID of the point to check
  /// - [userId]: UUID of the user to check
  ///
  /// State Changes:
  /// - Sets loadingStates[pointId] = true during check
  /// - Updates likedByUser[pointId] with result
  /// - Sets errors[pointId] on failure
  ///
  /// Example:
  /// ```dart
  /// // Check like status when displaying a point
  /// useEffect(() {
  ///   ref.read(likeNotifierProvider.notifier).checkUserLikedPoint(
  ///     pointId: point.id,
  ///     userId: currentUserId,
  ///   );
  ///   return null;
  /// }, [point.id]);
  /// ```
  Future<void> checkUserLikedPoint({
    required String pointId,
    required String userId,
  }) async {
    try {
      // Set loading state
      state = state.copyWith(
        loadingStates: {...state.loadingStates, pointId: true},
        errors: {...state.errors, pointId: null},
      );

      // Check if user has liked the point
      final hasLiked = await _likesRepository.hasUserLikedPoint(
        pointId: pointId,
        userId: userId,
      );

      // Update state with result
      state = state.copyWith(
        likedByUser: {...state.likedByUser, pointId: hasLiked},
        loadingStates: {...state.loadingStates, pointId: false},
      );
    } on DatabaseException {
      state = state.copyWith(
        loadingStates: {...state.loadingStates, pointId: false},
        errors: {
          ...state.errors,
          pointId: 'Unable to check like status. Please check your connection.',
        },
      );
    } catch (e) {
      state = state.copyWith(
        loadingStates: {...state.loadingStates, pointId: false},
        errors: {
          ...state.errors,
          pointId: 'An unexpected error occurred while checking like status.',
        },
      );
    }
  }

  /// Initializes like state for a point (fetches count + liked status).
  ///
  /// This is a convenience method that calls both fetchLikeCount and
  /// checkUserLikedPoint in parallel. Use this when displaying a point
  /// to initialize all like-related state at once.
  ///
  /// This is more efficient than calling the methods separately because
  /// they run concurrently via Future.wait.
  ///
  /// Parameters:
  /// - [pointId]: UUID of the point to initialize
  /// - [userId]: UUID of the current user
  ///
  /// State Changes:
  /// - Updates both likeCounts[pointId] and likedByUser[pointId]
  /// - Sets errors[pointId] if either operation fails
  ///
  /// Example:
  /// ```dart
  /// // Initialize like state when a point card is built
  /// class PointCard extends ConsumerStatefulWidget {
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     WidgetsBinding.instance.addPostFrameCallback((_) {
  ///       ref.read(likeNotifierProvider.notifier).initializeLikeStateForPoint(
  ///         pointId: widget.point.id,
  ///         userId: ref.read(currentUserIdProvider)!,
  ///       );
  ///     });
  ///   }
  /// }
  /// ```
  Future<void> initializeLikeStateForPoint({
    required String pointId,
    required String userId,
  }) async {
    // Fetch both like count and user's liked status in parallel
    await Future.wait([
      fetchLikeCount(pointId),
      checkUserLikedPoint(pointId: pointId, userId: userId),
    ]);
  }

  /// Resets all like state to empty.
  ///
  /// This clears all maps and returns to initial state. Use this when:
  /// - User signs out
  /// - Navigating away from feed
  /// - Clearing cached data
  ///
  /// Example:
  /// ```dart
  /// // Reset on sign out
  /// ref.read(likeNotifierProvider.notifier).reset();
  /// ```
  void reset() {
    state = const LikeState();
  }
}
