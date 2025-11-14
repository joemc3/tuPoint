# Like State Management - Usage Guide

## Overview

The like state management system provides optimistic UI updates for like/unlike operations with automatic rollback on error. It tracks state for multiple points simultaneously, enabling independent like operations across the feed.

## Architecture

### Components

1. **LikeState** (`domain/entities/like_state.dart`)
   - Freezed data class (not a union type)
   - Tracks state per point using maps
   - Fields: `likedByUser`, `likeCounts`, `loadingStates`, `errors`

2. **LikeNotifier** (`presentation/notifiers/like_notifier.dart`)
   - StateNotifier managing like operations
   - Implements optimistic updates with rollback
   - Handles per-point loading and error states

3. **Like Providers** (`core/providers/point_providers.dart`)
   - 7 new providers for like functionality
   - Use case providers, notifier provider, convenience providers
   - Family providers for per-point access

## Key Features

### Optimistic UI Updates

The like system updates the UI immediately before confirming with the server:

```dart
// User clicks like button
// 1. UI updates instantly (heart fills, count increments)
// 2. Server request sent in background
// 3a. If success: Keep optimistic state
// 3b. If failure: Rollback to previous state + show error
```

This provides instant feedback even on slow connections.

### Per-Point State Tracking

Each point maintains independent state:

```dart
LikeState {
  likedByUser: {
    'point-123': true,  // User liked this
    'point-456': false, // User hasn't liked this
  },
  likeCounts: {
    'point-123': 42,  // 42 likes
    'point-456': 7,   // 7 likes
  },
  loadingStates: {
    'point-123': false, // Not loading
    'point-456': true,  // Toggle in progress
  },
  errors: {
    'point-123': null,  // No error
    'point-456': 'Network error', // Error message
  },
}
```

## Usage Examples

### 1. Initialize Like State for a Point

Call this when displaying a point to fetch both like count and user's liked status:

```dart
class PointCard extends ConsumerStatefulWidget {
  final Point point;

  const PointCard({required this.point});

  @override
  ConsumerState<PointCard> createState() => _PointCardState();
}

class _PointCardState extends ConsumerState<PointCard> {
  @override
  void initState() {
    super.initState();

    // Initialize like state after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        ref.read(likeNotifierProvider.notifier).initializeLikeStateForPoint(
          pointId: widget.point.id,
          userId: userId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // See example 2 for UI implementation
  }
}
```

### 2. Build Like Button UI

Watch the like state and render appropriate UI:

```dart
class LikeButton extends ConsumerWidget {
  final String pointId;

  const LikeButton({required this.pointId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch like status for this specific point
    final isLiked = ref.watch(pointLikeStatusProvider(pointId));
    final likeCount = ref.watch(pointLikeCountProvider(pointId));
    final likeState = ref.watch(likeStateProvider);

    // Check loading state for this point
    final isLoading = likeState.loadingStates[pointId] ?? false;
    final error = likeState.errors[pointId];

    return Column(
      children: [
        // Like button
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey,
          ),
          onPressed: isLoading ? null : () async {
            final userId = ref.read(currentUserIdProvider);
            if (userId == null) return;

            await ref.read(likeNotifierProvider.notifier).toggleLike(
              pointId: pointId,
              userId: userId,
            );
          },
        ),

        // Like count
        Text(
          likeCount == 1 ? '1 like' : '$likeCount likes',
          style: Theme.of(context).textTheme.bodySmall,
        ),

        // Error message (if any)
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              error,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        // Loading indicator
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}
```

### 3. Toggle Like with Optimistic Update

The toggleLike method handles everything automatically:

```dart
// In a widget
onPressed: () async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) {
    // Show login prompt
    return;
  }

  // This will:
  // 1. Update UI immediately
  // 2. Call server in background
  // 3. Rollback if server fails
  await ref.read(likeNotifierProvider.notifier).toggleLike(
    pointId: point.id,
    userId: userId,
  );

  // No need to check for errors here - they're stored in state
  // and can be displayed in the UI
}
```

### 4. Alternative: Watch Full Like State

For more control, watch the full like state:

```dart
class PointCard extends ConsumerWidget {
  final Point point;

  const PointCard({required this.point});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeState = ref.watch(likeStateProvider);

    final isLiked = likeState.likedByUser[point.id] ?? false;
    final likeCount = likeState.likeCounts[point.id] ?? 0;
    final isLoading = likeState.loadingStates[point.id] ?? false;
    final error = likeState.errors[point.id];

    return Card(
      child: Column(
        children: [
          Text(point.content),

          Row(
            children: [
              IconButton(
                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                onPressed: isLoading ? null : () {
                  final userId = ref.read(currentUserIdProvider);
                  if (userId != null) {
                    ref.read(likeNotifierProvider.notifier).toggleLike(
                      pointId: point.id,
                      userId: userId,
                    );
                  }
                },
              ),
              Text('$likeCount'),
            ],
          ),

          if (error != null) Text(error, style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
```

### 5. Refresh Like Count

To refresh the like count from the server (e.g., after background sync):

```dart
// Refresh like count for a single point
await ref.read(likeNotifierProvider.notifier).fetchLikeCount(pointId);

// Or refresh full like state (count + status)
final userId = ref.read(currentUserIdProvider);
if (userId != null) {
  await ref.read(likeNotifierProvider.notifier).initializeLikeStateForPoint(
    pointId: pointId,
    userId: userId,
  );
}
```

### 6. Reset Like State

Clear all like state when signing out or navigating away:

```dart
// On sign out
ref.read(likeNotifierProvider.notifier).reset();

// This clears all maps and returns to initial state
```

## State Flow Diagrams

### Successful Like Toggle

```
User Clicks Like Button
    ↓
[Optimistic Update]
  - likedByUser[pointId] = true
  - likeCounts[pointId] += 1
  - loadingStates[pointId] = true
  - errors[pointId] = null
    ↓
[Call Server API]
  LikePointUseCase.call()
    ↓
[Server Success]
  - loadingStates[pointId] = false
  - Keep optimistic state
    ↓
[UI Shows] ❤️ (filled heart) + incremented count
```

### Failed Like Toggle (with Rollback)

```
User Clicks Like Button
    ↓
[Optimistic Update]
  - likedByUser[pointId] = true
  - likeCounts[pointId] += 1
  - loadingStates[pointId] = true
    ↓
[Call Server API]
  LikePointUseCase.call()
    ↓
[Server Error] (NetworkException)
    ↓
[Rollback]
  - likedByUser[pointId] = false (restored)
  - likeCounts[pointId] -= 1 (restored)
  - loadingStates[pointId] = false
  - errors[pointId] = "Unable to update like..."
    ↓
[UI Shows] 🤍 (outline heart) + original count + error message
```

## Provider Reference

### Use Case Providers

```dart
// Get use case instances
final likeUseCase = ref.read(likePointUseCaseProvider);
final unlikeUseCase = ref.read(unlikePointUseCaseProvider);
final countUseCase = ref.read(getLikeCountUseCaseProvider);
```

### Notifier Provider

```dart
// Get notifier for calling methods
final notifier = ref.read(likeNotifierProvider.notifier);
await notifier.toggleLike(pointId: '123', userId: 'abc');

// Watch notifier state directly
final likeState = ref.watch(likeNotifierProvider);
```

### Convenience Providers

```dart
// Watch full state (all points)
final likeState = ref.watch(likeStateProvider);

// Watch like status for specific point (family provider)
final isLiked = ref.watch(pointLikeStatusProvider('point-123'));

// Watch like count for specific point (family provider)
final count = ref.watch(pointLikeCountProvider('point-123'));
```

## Error Handling

The notifier maps exceptions to user-friendly error messages:

| Exception | User-Facing Message |
|-----------|---------------------|
| `DuplicateLikeException` | "You have already liked this point." |
| `NotFoundException` | "Unable to update like. Point may have been deleted." |
| `UnauthorizedException` | "You are not authorized to perform this action." |
| `DatabaseException` | "Unable to update like. Please check your connection." |
| Generic `Exception` | "An unexpected error occurred." |

Errors are stored per-point in `errors[pointId]` and can be displayed in the UI.

## Testing Integration

### Mock Providers in Tests

```dart
testWidgets('Like button toggles correctly', (tester) async {
  // Create mock repository
  final mockRepository = MockLikesRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        likesRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MyApp(),
    ),
  );

  // Test like button behavior
});
```

### Test Optimistic Updates

```dart
test('toggleLike updates UI optimistically', () async {
  final container = ProviderContainer(
    overrides: [/* mock providers */],
  );

  final notifier = container.read(likeNotifierProvider.notifier);

  // Initial state
  expect(container.read(pointLikeStatusProvider('point-123')), false);
  expect(container.read(pointLikeCountProvider('point-123')), 0);

  // Trigger toggle
  notifier.toggleLike(pointId: 'point-123', userId: 'user-abc');

  // State should update immediately (optimistic)
  expect(container.read(pointLikeStatusProvider('point-123')), true);
  expect(container.read(pointLikeCountProvider('point-123')), 1);

  // Wait for server response
  await Future.delayed(Duration.zero);

  // If server succeeds, state remains
  expect(container.read(pointLikeStatusProvider('point-123')), true);
});
```

## Integration Checklist

When integrating like functionality into UI:

- [ ] Initialize like state in `initState` or with `addPostFrameCallback`
- [ ] Watch `pointLikeStatusProvider(pointId)` for like button state
- [ ] Watch `pointLikeCountProvider(pointId)` for like count display
- [ ] Check `loadingStates[pointId]` to disable button during toggle
- [ ] Display `errors[pointId]` if present (error message)
- [ ] Call `toggleLike` on button press with error handling
- [ ] Reset like state on sign out via `reset()`
- [ ] Handle unauthenticated state (show login prompt)

## Performance Considerations

1. **Per-Point Initialization**: Only initialize like state for visible points
2. **Lazy Loading**: Use ListView.builder to render only visible cards
3. **Debouncing**: Disable button during toggle to prevent duplicate requests
4. **Error Recovery**: Errors are per-point, don't block other operations
5. **Memory**: State grows with visible points, reset on sign out

## Common Patterns

### Pattern 1: Feed Integration

```dart
// In feed screen
ListView.builder(
  itemCount: points.length,
  itemBuilder: (context, index) {
    return PointCard(point: points[index]);
  },
)

// In PointCard
class PointCard extends ConsumerStatefulWidget {
  @override
  void initState() {
    super.initState();
    // Initialize like state for this point
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(likeNotifierProvider.notifier).initializeLikeStateForPoint(
        pointId: widget.point.id,
        userId: ref.read(currentUserIdProvider)!,
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          Text(widget.point.content),
          LikeButton(pointId: widget.point.id),
        ],
      ),
    );
  }
}
```

### Pattern 2: Reusable Like Button Component

```dart
// Create reusable LikeButton widget
class LikeButton extends ConsumerWidget {
  final String pointId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(pointLikeStatusProvider(pointId));
    final likeCount = ref.watch(pointLikeCountProvider(pointId));
    final likeState = ref.watch(likeStateProvider);
    final isLoading = likeState.loadingStates[pointId] ?? false;

    return Row(
      children: [
        IconButton(
          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
          onPressed: isLoading ? null : () => _handleToggle(ref),
        ),
        Text('$likeCount'),
      ],
    );
  }

  void _handleToggle(WidgetRef ref) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      // Show login dialog
      return;
    }

    await ref.read(likeNotifierProvider.notifier).toggleLike(
      pointId: pointId,
      userId: userId,
    );
  }
}
```

## Additional Resources

- **LikeState Model**: `/app/lib/domain/entities/like_state.dart`
- **LikeNotifier**: `/app/lib/presentation/notifiers/like_notifier.dart`
- **Like Providers**: `/app/lib/core/providers/point_providers.dart` (lines 392-572)
- **Like Use Cases**: `/app/lib/domain/use_cases/like_use_cases/`
- **Repository Interface**: `/app/lib/domain/repositories/i_likes_repository.dart`
