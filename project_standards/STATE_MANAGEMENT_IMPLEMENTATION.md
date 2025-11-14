# State Management Implementation Guide

**tuPoint (tP.2) - Phase 5 Complete**

This document provides comprehensive documentation of the implemented state management architecture for tuPoint. It serves as the authoritative reference for understanding, maintaining, and extending the application's state management layer.

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture Principles](#architecture-principles)
3. [State Models](#state-models)
4. [State Notifiers](#state-notifiers)
5. [Riverpod Providers](#riverpod-providers)
6. [Data Flow Patterns](#data-flow-patterns)
7. [Error Handling Strategy](#error-handling-strategy)
8. [Usage Examples](#usage-examples)
9. [Testing Strategy](#testing-strategy)
10. [Integration Checklist](#integration-checklist)

---

## Overview

### Implementation Status

**Phase 5 State Management: ✅ COMPLETE**

The tuPoint application implements a comprehensive state management system using Riverpod and the StateNotifier pattern. All core features have state management implemented:

- ✅ **Authentication** (Phase 5.2)
- ✅ **Location Services** (Phase 5.3)
- ✅ **Profile Management** (Phase 5.4)
- ✅ **Point Creation** (Phase 5.4)
- ✅ **Feed Display** (Phase 5.4)
- ✅ **Like/Unlike** (Phase 5.4)

### Statistics

- **State Models**: 7 Freezed models (AuthState, ProfileState, PointDropState, FeedState, LikeState, LocationPermissionState, LocationServiceState)
- **Notifiers**: 5 StateNotifiers (AuthNotifier, ProfileNotifier, PointDropNotifier, FeedNotifier, LikeNotifier)
- **Providers**: 27 total providers across 3 provider files
- **Use Cases**: 11 use cases integrated with state layer
- **Lines of Code**: ~2,500 lines (notifiers + providers + state models)

### File Structure

```
app/lib/
├── core/
│   ├── providers/
│   │   ├── repository_providers.dart       # 4 providers (Supabase + repos)
│   │   ├── auth_providers.dart             # 6 providers (auth state)
│   │   ├── location_providers.dart         # 6 providers (location state)
│   │   ├── profile_providers.dart          # 4 providers (profile state)
│   │   └── point_providers.dart            # 16 providers (points + feed + likes)
│   └── services/
│       └── location_service.dart           # GPS and permission service
├── domain/
│   └── entities/
│       ├── auth_state.dart                 # Authentication state model
│       ├── profile_state.dart              # Profile state model
│       ├── point_drop_state.dart           # Point creation state model
│       ├── feed_state.dart                 # Feed state model
│       ├── like_state.dart                 # Like state model
│       ├── location_permission_state.dart  # Location permission state
│       └── location_service_state.dart     # Location service state
└── presentation/
    └── notifiers/
        ├── auth_notifier.dart              # Authentication notifier
        ├── profile_notifier.dart           # Profile notifier
        ├── point_drop_notifier.dart        # Point creation notifier
        ├── feed_notifier.dart              # Feed notifier
        └── like_notifier.dart              # Like notifier
```

---

## Architecture Principles

### 1. Clean Architecture Compliance

All state management follows Clean Architecture principles:

```
Presentation Layer (UI) → StateNotifiers → Use Cases → Repositories → Data Sources
         ↑                                      ↓
         └─────────── Riverpod Providers ──────┘
```

**Key Rules**:
- **Presentation layer** has zero business logic (only UI and state consumption)
- **Notifiers** orchestrate use cases but don't contain domain logic
- **Use cases** contain all business rules and validation
- **Repositories** handle data access via abstract interfaces
- **State flows one direction**: Data → Notifiers → Providers → UI

### 2. State Model Design

All state models use **Freezed** for:
- Immutability (thread-safe state)
- Union types for exhaustive pattern matching
- Copy semantics for state updates
- JSON serialization (where needed)

**Two State Model Patterns**:

| Pattern | When to Use | Example |
|---------|-------------|---------|
| **Union Type** | Single operation with distinct states | `ProfileState`, `AuthState`, `FeedState` |
| **Data Class** | Multiple concurrent operations | `LikeState` (tracks many points simultaneously) |

### 3. Provider Composition

Providers follow a layered composition pattern:

```dart
// Layer 1: Repository providers (infrastructure)
final profileRepositoryProvider = Provider((ref) => SupabaseProfileRepository(...));

// Layer 2: Use case providers (business logic)
final fetchProfileUseCaseProvider = Provider((ref) =>
  FetchProfileUseCase(profileRepository: ref.watch(profileRepositoryProvider))
);

// Layer 3: Notifier providers (state management)
final profileNotifierProvider = StateNotifierProvider((ref) =>
  ProfileNotifier(fetchProfileUseCase: ref.watch(fetchProfileUseCaseProvider))
);

// Layer 4: Convenience providers (UI consumption)
final profileStateProvider = Provider((ref) => ref.watch(profileNotifierProvider));
```

### 4. Error Handling Philosophy

**Defensive Programming**:
- Validate inputs in use cases before calling repositories
- Map all repository exceptions to user-friendly messages in notifiers
- Never expose internal error details to UI
- Always provide actionable error messages

**Example**:
```dart
// ❌ Bad: Technical error exposed
state = ProfileState.error(message: 'PostgrestException: 23505');

// ✅ Good: User-friendly message
state = ProfileState.error(message: 'This username is already taken. Please choose another.');
```

---

## State Models

### 1. AuthState

**File**: `app/lib/domain/entities/auth_state.dart`

**Purpose**: Represents authentication status throughout the app.

**States**:
```dart
sealed class AuthState {
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.authenticated({
    required String userId,
    @Default(true) bool hasProfile,
  }) = _Authenticated;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.error({required String message}) = _Error;
}
```

**Key Features**:
- `hasProfile` flag determines if profile creation is needed
- Persists across app restarts via Supabase session
- Listened to by `authStateSubscription` for real-time updates

**Usage**:
```dart
final authState = ref.watch(authStateProvider);
authState.when(
  authenticated: (userId, hasProfile) => hasProfile ? HomeScreen() : ProfileCreationScreen(),
  unauthenticated: () => LoginScreen(),
  loading: () => SplashScreen(),
  error: (message) => ErrorScreen(message),
);
```

---

### 2. ProfileState

**File**: `app/lib/domain/entities/profile_state.dart`

**Purpose**: Manages profile fetch and update operations.

**States**:
```dart
sealed class ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;
  const factory ProfileState.loaded({required Profile profile}) = _Loaded;
  const factory ProfileState.error({required String message}) = _Error;
}
```

**State Transitions**:
```
initial → loading → loaded
            ↓
          error
```

**Usage**:
```dart
final profileState = ref.watch(profileStateProvider);
profileState.when(
  initial: () => Text('No profile loaded'),
  loading: () => CircularProgressIndicator(),
  loaded: (profile) => ProfileCard(profile: profile),
  error: (message) => ErrorMessage(message),
);
```

---

### 3. PointDropState

**File**: `app/lib/domain/entities/point_drop_state.dart`

**Purpose**: Manages two-phase point creation (GPS fetch → database create).

**States**:
```dart
sealed class PointDropState {
  const factory PointDropState.initial() = _Initial;
  const factory PointDropState.fetchingLocation() = _FetchingLocation;
  const factory PointDropState.dropping() = _Dropping;
  const factory PointDropState.success({required Point point}) = _Success;
  const factory PointDropState.error({required String message}) = _Error;
}
```

**State Transitions**:
```
initial → fetchingLocation → dropping → success
              ↓                  ↓
            error             error
```

**Why Two Loading States?**
- `fetchingLocation`: GPS can be slow (5-15 seconds in poor conditions)
- `dropping`: Database operation is usually fast (<1 second)
- Allows UI to show different messages: "Getting your location..." vs "Creating point..."

**Usage**:
```dart
pointDropState.when(
  initial: () => PointCreationForm(),
  fetchingLocation: () => LoadingIndicator(message: 'Getting your location...'),
  dropping: () => LoadingIndicator(message: 'Creating point...'),
  success: (point) => SuccessScreen(point),
  error: (message) => ErrorMessage(message),
);
```

---

### 4. FeedState

**File**: `app/lib/domain/entities/feed_state.dart`

**Purpose**: Manages nearby points feed with user location context.

**States**:
```dart
sealed class FeedState {
  const factory FeedState.initial() = _Initial;
  const factory FeedState.loading() = _Loading;
  const factory FeedState.loaded({
    required List<Point> points,
    required LocationCoordinate userLocation,
  }) = _Loaded;
  const factory FeedState.error({required String message}) = _Error;
}
```

**Key Design Decision**: `userLocation` is included in `loaded` state so the UI can:
- Calculate and display distance to each point
- Show user's current location on a map
- Re-filter on location changes without re-fetching

**Usage**:
```dart
feedState.when(
  initial: () => EmptyFeedPlaceholder(),
  loading: () => FeedLoadingIndicator(),
  loaded: (points, userLocation) => PointsList(
    points: points,
    userLocation: userLocation,
  ),
  error: (message) => FeedErrorMessage(message),
);
```

---

### 5. LikeState

**File**: `app/lib/domain/entities/like_state.dart`

**Purpose**: Tracks like state for multiple points simultaneously.

**Structure** (Data Class, NOT Union):
```dart
@freezed
class LikeState with _$LikeState {
  const factory LikeState({
    @Default({}) Map<String, bool> likedByUser,      // pointId → isLiked
    @Default({}) Map<String, int> likeCounts,        // pointId → count
    @Default({}) Map<String, bool> loadingStates,    // pointId → isLoading
    @Default({}) Map<String, String?> errors,        // pointId → errorMsg
  }) = _LikeState;
}
```

**Why a Data Class Instead of Union?**
- Need to track state for **many points** at once (feed has multiple points)
- Each point has independent like status, count, loading, and error state
- Union types work for single operations; maps work for concurrent operations

**Per-Point State Access**:
```dart
final likeState = ref.watch(likeStateProvider);

// For a specific point
final isLiked = likeState.likedByUser[pointId] ?? false;
final likeCount = likeState.likeCounts[pointId] ?? 0;
final isLoading = likeState.loadingStates[pointId] ?? false;
final error = likeState.errors[pointId];
```

**Or use family providers** (recommended):
```dart
final isLiked = ref.watch(pointLikeStatusProvider(pointId));
final likeCount = ref.watch(pointLikeCountProvider(pointId));
```

---

### 6. LocationPermissionState

**File**: `app/lib/domain/entities/location_permission_state.dart`

**Purpose**: Represents current location permission status.

**States**:
```dart
sealed class LocationPermissionState {
  const factory LocationPermissionState.notAsked() = _NotAsked;
  const factory LocationPermissionState.granted() = _Granted;
  const factory LocationPermissionState.denied() = _Denied;
  const factory LocationPermissionState.deniedForever() = _DeniedForever;
  const factory LocationPermissionState.serviceDisabled() = _ServiceDisabled;
}
```

**State Machine**:
```
notAsked → denied → deniedForever
    ↓        ↓
  granted  granted

serviceDisabled (can occur from any state)
```

---

### 7. LocationServiceState

**File**: `app/lib/domain/entities/location_service_state.dart`

**Purpose**: Represents result of location fetch operations.

**States**:
```dart
sealed class LocationServiceState {
  const factory LocationServiceState.loading() = _Loading;
  const factory LocationServiceState.available({
    required LocationCoordinate location,
  }) = _Available;
  const factory LocationServiceState.permissionDenied({
    required String message,
    required bool isPermanent,
  }) = _PermissionDenied;
  const factory LocationServiceState.serviceDisabled({
    required String message,
  }) = _ServiceDisabled;
  const factory LocationServiceState.error({
    required String message,
  }) = _Error;
}
```

**Usage in Notifiers**:
```dart
final locationState = await locationService.getCurrentLocation();

locationState.when(
  available: (location) => // Use location
  permissionDenied: (msg, isPermanent) => // Show permission error
  serviceDisabled: (msg) => // Prompt to enable GPS
  error: (msg) => // Show generic error
  loading: () => // Should not happen with getCurrentLocation()
);
```

---

## State Notifiers

### 1. AuthNotifier

**File**: `app/lib/presentation/notifiers/auth_notifier.dart`

**Responsibilities**:
- Email/password sign in and sign up
- OAuth sign in (Google, Apple)
- Automatic profile creation during signup
- Session persistence via Supabase auth state listener
- Profile existence checking

**Key Methods**:

```dart
class AuthNotifier extends StateNotifier<AuthState> {
  Future<void> signInWithEmail(String email, String password)
  Future<void> signInWithGoogle()
  Future<void> signInWithApple()
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    String? bio,
  })
  Future<void> signOut()
  Future<void> checkAuthStatus()
}
```

**Signup Flow** (Two-Phase):
1. Create Supabase auth account
2. Create profile record using `CreateProfileUseCase`
3. If profile creation fails, user remains authenticated but `hasProfile = false`

**Error Mapping**:
- Maps Supabase `AuthException` to user-friendly messages
- Handles `DuplicateUsernameException` from profile creation
- Network errors, invalid credentials, etc.

**Subscription Management**:
```dart
// Listens to Supabase auth state changes
_authStateSubscription = _supabaseClient.auth.onAuthStateChange.listen((data) {
  // Updates app state when session changes
});

// Clean up on dispose
@override
void dispose() {
  _authStateSubscription?.cancel();
  super.dispose();
}
```

---

### 2. ProfileNotifier

**File**: `app/lib/presentation/notifiers/profile_notifier.dart`

**Responsibilities**:
- Fetch user profiles by ID
- Update profile information (username, bio)
- Error handling with user-friendly messages

**Key Methods**:

```dart
class ProfileNotifier extends StateNotifier<ProfileState> {
  Future<void> fetchProfile(String userId)
  Future<void> updateProfile({
    required String userId,
    String? username,
    String? bio,
  })
  void reset()
}
```

**Update Flow**:
1. Set state to `loading()`
2. Call `UpdateProfileUseCase` (validates inputs)
3. On success: set state to `loaded(updatedProfile)`
4. On error: set state to `error(userFriendlyMessage)`

**Error Mapping**:
- `NotFoundException` → "Profile not found. Please create a profile first."
- `DuplicateUsernameException` → Uses exception message (includes username)
- `ValidationException` → Uses exception message (includes validation details)
- `UnauthorizedException` → "You are not authorized to update this profile."
- `DatabaseException` → "Unable to update profile. Please check your connection."

---

### 3. PointDropNotifier

**File**: `app/lib/presentation/notifiers/point_drop_notifier.dart`

**Responsibilities**:
- Fetch GPS coordinates via LocationService
- Convert coordinates to Maidenhead grid locator
- Create point in database via DropPointUseCase
- Two-phase loading states

**Key Methods**:

```dart
class PointDropNotifier extends StateNotifier<PointDropState> {
  Future<void> dropPoint({
    required String userId,
    required String content,
  })
  void reset()
}
```

**Drop Point Flow** (Two-Phase):
```
1. Validate content (1-280 chars)
   ↓
2. Set state to fetchingLocation()
   ↓
3. Call locationService.getCurrentLocation()
   ↓
4. Extract LocationCoordinate from LocationServiceState
   ↓
5. Convert to Maidenhead 6-char using MaidenheadConverter
   ↓
6. Set state to dropping()
   ↓
7. Call DropPointUseCase(userId, content, location, maidenhead)
   ↓
8. Set state to success(point) or error(message)
```

**Error Handling**:
- **Location errors**: Permission denied, GPS disabled, timeout
- **Validation errors**: Content too long/short, invalid user ID
- **Database errors**: Connection issues, authorization failures

**Why Content Validation First?**
- Fail fast: Don't fetch GPS if content is invalid
- Better UX: User sees validation errors immediately
- Saves battery: GPS is expensive

---

### 4. FeedNotifier

**File**: `app/lib/presentation/notifiers/feed_notifier.dart`

**Responsibilities**:
- Fetch user's current location
- Fetch all active points from database
- Filter points within 5km radius using Haversine formula
- Sort by distance (nearest first)
- Exclude user's own points from feed

**Key Methods**:

```dart
class FeedNotifier extends StateNotifier<FeedState> {
  Future<void> fetchNearbyPoints({
    required String? userId,
    LocationCoordinate? customLocation,
  })
  void reset()
}
```

**Fetch Flow**:
```
1. Set state to loading()
   ↓
2. Get location (customLocation or getCurrentLocation())
   ↓
3. Call FetchNearbyPointsUseCase with:
   - userLocation: extracted coordinate
   - radiusMeters: 5000 (5km)
   - userId: current user ID
   - includeUserOwnPoints: false
   ↓
4. Receive points filtered and sorted by distance
   ↓
5. Set state to loaded(points, userLocation)
```

**Client-Side Filtering**:
- All active points fetched from database (simple SELECT query)
- Haversine distance calculated for each point (client-side)
- Points beyond 5km excluded
- User's own points excluded
- Results sorted by distance (nearest first)

**Why Client-Side Filtering?**
- Keeps server simple (no PostGIS queries needed)
- Haversine calculation is fast (<1ms for 100 points)
- Allows easy testing of filtering logic
- Reduces server load

**Real-Time Updates** (Future Enhancement):
```dart
// Can be triggered by locationStreamProvider
ref.listen(locationStreamProvider, (previous, next) {
  next.whenData((locationState) {
    locationState.maybeWhen(
      available: (location) {
        // Refresh feed if location changed significantly
        ref.read(feedNotifierProvider.notifier).fetchNearbyPoints(
          userId: currentUserId,
          customLocation: location,
        );
      },
      orElse: () {},
    );
  });
});
```

---

### 5. LikeNotifier

**File**: `app/lib/presentation/notifiers/like_notifier.dart`

**Responsibilities**:
- Toggle like/unlike with optimistic UI updates
- Track like state for multiple points simultaneously
- Fetch like counts per point
- Check if user has liked specific points
- Rollback on errors

**Key Methods**:

```dart
class LikeNotifier extends StateNotifier<LikeState> {
  Future<void> toggleLike({
    required String pointId,
    required String userId,
  })
  Future<void> fetchLikeCount(String pointId)
  Future<void> checkUserLikedPoint({
    required String pointId,
    required String userId,
  })
  Future<void> initializeLikeStateForPoint({
    required String pointId,
    required String userId,
  })
  void reset()
}
```

**Optimistic Update Pattern** (toggleLike):
```
1. Get current state: isLiked, likeCount
   ↓
2. OPTIMISTIC UPDATE (instant UI feedback):
   - likedByUser[pointId] = !isLiked
   - likeCounts[pointId] = likeCount + (isLiked ? -1 : 1)
   - loadingStates[pointId] = true
   ↓
3. Call appropriate use case:
   - If was liked: UnlikePointUseCase
   - If not liked: LikePointUseCase
   ↓
4a. SUCCESS:
    - Keep optimistic state
    - loadingStates[pointId] = false
   ↓
4b. FAILURE:
    - ROLLBACK: Restore previous isLiked and likeCount
    - errors[pointId] = user-friendly message
    - loadingStates[pointId] = false
```

**Why Optimistic Updates?**
- Instant UI feedback (no perceived lag)
- Better user experience (feels snappy)
- Network latency hidden from user
- Rollback ensures consistency on errors

**Per-Point Independence**:
- Each point tracks its own state in maps
- Toggling point A doesn't affect point B
- Multiple points can be toggled concurrently
- Errors on point A don't affect point B

**Initialize Pattern** (for feed display):
```dart
// When displaying a point card, initialize its like state
@override
void initState() {
  super.initState();
  final userId = ref.read(currentUserIdProvider);
  if (userId != null) {
    ref.read(likeNotifierProvider.notifier).initializeLikeStateForPoint(
      pointId: widget.point.id,
      userId: userId,
    );
  }
}
```

---

## Riverpod Providers

### Provider Organization

Providers are organized into 5 files by domain:

| File | Providers | Purpose |
|------|-----------|---------|
| `repository_providers.dart` | 4 | Infrastructure (Supabase, repositories) |
| `auth_providers.dart` | 6 | Authentication state |
| `location_providers.dart` | 6 | Location services |
| `profile_providers.dart` | 4 | Profile state |
| `point_providers.dart` | 16 | Points, feed, likes |

### 1. Repository Providers

**File**: `app/lib/core/providers/repository_providers.dart`

```dart
// Supabase client singleton
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Profile repository
final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return SupabaseProfileRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

// Points repository
final pointsRepositoryProvider = Provider<IPointsRepository>((ref) {
  return SupabasePointsRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

// Likes repository
final likesRepositoryProvider = Provider<ILikesRepository>((ref) {
  return SupabaseLikesRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});
```

**Usage**: These are foundational providers used by all use cases and notifiers.

---

### 2. Auth Providers

**File**: `app/lib/core/providers/auth_providers.dart`

```dart
// Use case providers
final createProfileUseCaseProvider = Provider<CreateProfileUseCase>((ref) {
  return CreateProfileUseCase(
    profileRepository: ref.watch(profileRepositoryProvider),
  );
});

final fetchProfileUseCaseProvider = Provider<FetchProfileUseCase>((ref) {
  return FetchProfileUseCase(
    profileRepository: ref.watch(profileRepositoryProvider),
  );
});

// Main auth notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    supabaseClient: ref.watch(supabaseClientProvider),
    createProfileUseCase: ref.watch(createProfileUseCaseProvider),
    fetchProfileUseCase: ref.watch(fetchProfileUseCaseProvider),
  );
});

// Convenience providers
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});

final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    authenticated: (userId, hasProfile) => userId,
    orElse: () => null,
  );
});

final hasProfileProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    authenticated: (userId, hasProfile) => hasProfile,
    orElse: () => false,
  );
});
```

---

### 3. Location Providers

**File**: `app/lib/core/providers/location_providers.dart`

```dart
// Location service singleton
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Permission state
final locationPermissionProvider = FutureProvider<LocationPermissionState>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.checkPermission();
});

// Current location (one-time fetch)
final currentLocationProvider = FutureProvider<LocationServiceState>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentLocation();
});

// Location stream (real-time updates)
final locationStreamProvider = StreamProvider<LocationServiceState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getLocationStream();
});

// Convenience providers
final hasLocationPermissionProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(locationPermissionProvider);
  return permissionState.maybeWhen(
    data: (state) => state.maybeWhen(
      granted: () => true,
      orElse: () => false,
    ),
    orElse: () => false,
  );
});

final locationServicesEnabledProvider = Provider<bool>((ref) {
  final permissionState = ref.watch(locationPermissionProvider);
  return permissionState.maybeWhen(
    data: (state) => state.maybeWhen(
      serviceDisabled: () => false,
      orElse: () => true,
    ),
    orElse: () => true,
  );
});
```

---

### 4. Profile Providers

**File**: `app/lib/core/providers/profile_providers.dart`

```dart
// Use case provider
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(
    profileRepository: ref.watch(profileRepositoryProvider),
  );
});

// Profile notifier
final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    fetchProfileUseCase: ref.watch(fetchProfileUseCaseProvider),
    updateProfileUseCase: ref.watch(updateProfileUseCaseProvider),
  );
});

// Convenience providers
final profileStateProvider = Provider<ProfileState>((ref) {
  return ref.watch(profileNotifierProvider);
});

final currentProfileProvider = Provider<Profile?>((ref) {
  final profileState = ref.watch(profileStateProvider);
  return profileState.maybeWhen(
    loaded: (profile) => profile,
    orElse: () => null,
  );
});
```

---

### 5. Point Providers (includes Feed and Likes)

**File**: `app/lib/core/providers/point_providers.dart`

**Use Case Providers**:
```dart
// Point creation
final dropPointUseCaseProvider = Provider<DropPointUseCase>((ref) {
  return DropPointUseCase(
    pointsRepository: ref.watch(pointsRepositoryProvider),
  );
});

// Feed
final fetchNearbyPointsUseCaseProvider = Provider<FetchNearbyPointsUseCase>((ref) {
  return FetchNearbyPointsUseCase(
    pointsRepository: ref.watch(pointsRepositoryProvider),
  );
});

// Likes
final likePointUseCaseProvider = Provider<LikePointUseCase>((ref) {
  return LikePointUseCase(
    likesRepository: ref.watch(likesRepositoryProvider),
  );
});

final unlikePointUseCaseProvider = Provider<UnlikePointUseCase>((ref) {
  return UnlikePointUseCase(
    likesRepository: ref.watch(likesRepositoryProvider),
  );
});

final getLikeCountUseCaseProvider = Provider<GetLikeCountUseCase>((ref) {
  return GetLikeCountUseCase(
    likesRepository: ref.watch(likesRepositoryProvider),
  );
});
```

**Point Drop Providers**:
```dart
final pointDropNotifierProvider = StateNotifierProvider<PointDropNotifier, PointDropState>((ref) {
  return PointDropNotifier(
    locationService: ref.watch(locationServiceProvider),
    dropPointUseCase: ref.watch(dropPointUseCaseProvider),
  );
});

final pointDropStateProvider = Provider<PointDropState>((ref) {
  return ref.watch(pointDropNotifierProvider);
});

final isDroppingPointProvider = Provider<bool>((ref) {
  final state = ref.watch(pointDropStateProvider);
  return state.maybeWhen(
    fetchingLocation: () => true,
    dropping: () => true,
    orElse: () => false,
  );
});
```

**Feed Providers**:
```dart
final feedNotifierProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(
    locationService: ref.watch(locationServiceProvider),
    fetchNearbyPointsUseCase: ref.watch(fetchNearbyPointsUseCaseProvider),
  );
});

final feedStateProvider = Provider<FeedState>((ref) {
  return ref.watch(feedNotifierProvider);
});

final nearbyPointsProvider = Provider<List<Point>>((ref) {
  final feedState = ref.watch(feedStateProvider);
  return feedState.maybeWhen(
    loaded: (points, _) => points,
    orElse: () => [],
  );
});

final isLoadingFeedProvider = Provider<bool>((ref) {
  final feedState = ref.watch(feedStateProvider);
  return feedState.maybeWhen(
    loading: () => true,
    orElse: () => false,
  );
});
```

**Like Providers**:
```dart
final likeNotifierProvider = StateNotifierProvider<LikeNotifier, LikeState>((ref) {
  return LikeNotifier(
    likesRepository: ref.watch(likesRepositoryProvider),
    likePointUseCase: ref.watch(likePointUseCaseProvider),
    unlikePointUseCase: ref.watch(unlikePointUseCaseProvider),
    getLikeCountUseCase: ref.watch(getLikeCountUseCaseProvider),
  );
});

final likeStateProvider = Provider<LikeState>((ref) {
  return ref.watch(likeNotifierProvider);
});

// Family providers (per-point state access)
final pointLikeStatusProvider = Provider.family<bool, String>((ref, pointId) {
  final likeState = ref.watch(likeStateProvider);
  return likeState.likedByUser[pointId] ?? false;
});

final pointLikeCountProvider = Provider.family<int, String>((ref, pointId) {
  final likeState = ref.watch(likeStateProvider);
  return likeState.likeCounts[pointId] ?? 0;
});
```

---

## Data Flow Patterns

### Pattern 1: Simple State Fetch

**Use Case**: Fetch and display user profile

```
┌─────────────┐
│     UI      │ ref.watch(profileStateProvider)
└──────┬──────┘
       │
       ↓
┌─────────────────┐
│ profileNotifier │ fetchProfile(userId)
└──────┬──────────┘
       │
       ↓
┌──────────────────────┐
│ FetchProfileUseCase  │ Validates userId
└──────┬───────────────┘
       │
       ↓
┌───────────────────────┐
│ ProfileRepository     │ Supabase query
└──────┬────────────────┘
       │
       ↓
┌──────────────┐
│   Database   │
└──────────────┘
```

**Code**:
```dart
// UI triggers fetch
@override
void initState() {
  super.initState();
  final userId = ref.read(currentUserIdProvider);
  if (userId != null) {
    ref.read(profileNotifierProvider.notifier).fetchProfile(userId);
  }
}

// UI watches state
final profileState = ref.watch(profileStateProvider);
profileState.when(
  loaded: (profile) => Text(profile.username),
  loading: () => CircularProgressIndicator(),
  // ...
);
```

---

### Pattern 2: Two-Phase Operation

**Use Case**: Create a point (GPS fetch → database create)

```
┌─────────────┐
│     UI      │ ref.read(notifier).dropPoint()
└──────┬──────┘
       │
       ↓
┌──────────────────────┐
│ PointDropNotifier    │ State: fetchingLocation
└──────┬───────────────┘
       │
       ↓
┌──────────────────────┐
│  LocationService     │ GPS fetch
└──────┬───────────────┘
       │
       ↓
┌──────────────────────┐
│ PointDropNotifier    │ State: dropping
└──────┬───────────────┘
       │
       ↓
┌──────────────────────┐
│  DropPointUseCase    │ Validates content
└──────┬───────────────┘
       │
       ↓
┌──────────────────────┐
│  PointsRepository    │ Supabase INSERT
└──────┬───────────────┘
       │
       ↓
┌──────────────────────┐
│  PointDropNotifier   │ State: success(point)
└──────────────────────┘
```

**Code**:
```dart
// UI triggers drop
onPressed: () async {
  final userId = ref.read(currentUserIdProvider);
  if (userId != null) {
    await ref.read(pointDropNotifierProvider.notifier).dropPoint(
      userId: userId,
      content: _contentController.text,
    );
  }
}

// UI watches state with different messages per phase
pointDropState.when(
  fetchingLocation: () => LoadingIndicator(message: 'Getting your location...'),
  dropping: () => LoadingIndicator(message: 'Creating point...'),
  success: (point) => Navigator.pop(context),
  // ...
);
```

---

### Pattern 3: Optimistic Update with Rollback

**Use Case**: Like/unlike a point

```
┌─────────────┐
│     UI      │ User taps like button
└──────┬──────┘
       │
       ↓
┌──────────────────────┐
│   LikeNotifier       │ 1. Optimistic update (instant UI)
│                      │    - likedByUser[pointId] = true
│                      │    - likeCounts[pointId] += 1
└──────┬───────────────┘
       │
       ↓
┌──────────────────────┐
│  LikePointUseCase    │ 2. Server call (async)
└──────┬───────────────┘
       │
       ├─────── SUCCESS ───→ Keep optimistic state
       │
       └─────── FAILURE ───→ Rollback to previous state
                             + show error message
```

**Code**:
```dart
// UI triggers toggle
IconButton(
  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
  onPressed: isLoading ? null : () async {
    await ref.read(likeNotifierProvider.notifier).toggleLike(
      pointId: point.id,
      userId: currentUserId,
    );
  },
);

// UI updates instantly via optimistic state
final isLiked = ref.watch(pointLikeStatusProvider(point.id));
final likeCount = ref.watch(pointLikeCountProvider(point.id));
```

---

### Pattern 4: Real-Time Location Updates

**Use Case**: Auto-refresh feed when location changes

```
┌──────────────────┐
│ locationStream   │ Emits location every 10m movement
└────────┬─────────┘
         │
         ↓
┌──────────────────┐
│   UI Listener    │ Detects location change
└────────┬─────────┘
         │
         ↓
┌──────────────────┐
│  FeedNotifier    │ Calls fetchNearbyPoints(customLocation)
└────────┬─────────┘
         │
         ↓
┌──────────────────┐
│  FetchNearbyUC   │ Filters by new location
└────────┬─────────┘
         │
         ↓
┌──────────────────┐
│  FeedNotifier    │ State: loaded(newPoints, newLocation)
└──────────────────┘
```

**Code**:
```dart
// Listen to location stream (in widget)
ref.listen(locationStreamProvider, (previous, next) {
  next.whenData((locationState) {
    locationState.maybeWhen(
      available: (newLocation) {
        final userId = ref.read(currentUserIdProvider);
        ref.read(feedNotifierProvider.notifier).fetchNearbyPoints(
          userId: userId,
          customLocation: newLocation,
        );
      },
      orElse: () {},
    );
  });
});
```

---

## Error Handling Strategy

### Exception Hierarchy

```
RepositoryException (abstract base)
├── NotFoundException
├── UnauthorizedException
├── DuplicateUsernameException
├── DuplicateLikeException
├── ValidationException
└── DatabaseException
```

### Error Mapping Tables

#### ProfileNotifier Errors

| Exception | User Message |
|-----------|--------------|
| `NotFoundException` | "Profile not found. Please create a profile first." |
| `DuplicateUsernameException` | Uses exception message (includes username) |
| `ValidationException` | Uses exception message (includes validation details) |
| `UnauthorizedException` | "You are not authorized to update this profile." |
| `DatabaseException` | "Unable to update profile. Please check your connection." |
| Generic | "An unexpected error occurred while updating profile." |

#### PointDropNotifier Errors

| Exception/State | User Message |
|-----------------|--------------|
| `LocationServiceState.permissionDenied` | "Location permission denied. Please enable location access." |
| `LocationServiceState.serviceDisabled` | "Location services disabled. Please enable GPS." |
| `ValidationException` | Uses exception message (content length, etc.) |
| `UnauthorizedException` | "You are not authorized to create this point." |
| `DatabaseException` | "Unable to create point. Please check your connection." |
| Generic | "An unexpected error occurred while creating point." |

#### FeedNotifier Errors

| Exception/State | User Message |
|-----------------|--------------|
| `LocationServiceState.permissionDenied` | "Location permission denied. Please enable location access in Settings to see nearby points." |
| `LocationServiceState.serviceDisabled` | "Location services disabled. Please enable GPS to see nearby points." |
| `DatabaseException` | "Unable to load nearby points. Please check your connection." |
| Generic | "An unexpected error occurred while loading the feed." |

#### LikeNotifier Errors

| Exception | User Message |
|-----------|--------------|
| `DuplicateLikeException` | "You have already liked this point." |
| `NotFoundException` | "Unable to update like. Point may have been deleted." |
| `UnauthorizedException` | "You are not authorized to perform this action." |
| `DatabaseException` | "Unable to update like. Please check your connection." |
| Generic | "An unexpected error occurred." |

### Error Display Best Practices

**1. Use Snackbars for temporary errors**:
```dart
feedState.maybeWhen(
  error: (message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  },
  orElse: () {},
);
```

**2. Use error widgets for persistent errors**:
```dart
profileState.when(
  error: (message) => ErrorCard(
    message: message,
    onRetry: () => ref.read(profileNotifierProvider.notifier).fetchProfile(userId),
  ),
  // ...
);
```

**3. Use inline errors for form validation**:
```dart
likeState.errors[pointId] != null
  ? Text(
      likeState.errors[pointId]!,
      style: TextStyle(color: Colors.red),
    )
  : Container()
```

---

## Usage Examples

### Example 1: Auth Gate Screen

**Requirement**: Show different screens based on auth state

```dart
class AuthGateScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      unauthenticated: () => LoginScreen(),
      authenticated: (userId, hasProfile) {
        if (!hasProfile) {
          return ProfileCreationScreen(userId: userId);
        }
        return MainFeedScreen();
      },
      loading: () => SplashScreen(),
      error: (message) => ErrorScreen(message: message),
    );
  }
}
```

---

### Example 2: Profile Screen

**Requirement**: Display and edit user profile

```dart
class ProfileScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Fetch profile on screen load
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      ref.read(profileNotifierProvider.notifier).fetchProfile(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileStateProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: profileState.when(
        initial: () => Center(child: Text('No profile loaded')),
        loading: () => Center(child: CircularProgressIndicator()),
        loaded: (profile) => _buildProfileForm(profile),
        error: (message) => ErrorCard(
          message: message,
          onRetry: () {
            final userId = ref.read(currentUserIdProvider);
            if (userId != null) {
              ref.read(profileNotifierProvider.notifier).fetchProfile(userId);
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileForm(Profile profile) {
    _bioController.text = profile.bio ?? '';

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(profile.username, style: TextStyle(fontSize: 24)),
          SizedBox(height: 16),
          TextField(
            controller: _bioController,
            decoration: InputDecoration(labelText: 'Bio'),
            maxLength: 280,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final userId = ref.read(currentUserIdProvider);
              if (userId != null) {
                await ref.read(profileNotifierProvider.notifier).updateProfile(
                  userId: userId,
                  bio: _bioController.text,
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
```

---

### Example 3: Point Creation Screen

**Requirement**: Create point with GPS location

```dart
class PointCreationScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<PointCreationScreen> createState() => _PointCreationScreenState();
}

class _PointCreationScreenState extends ConsumerState<PointCreationScreen> {
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final pointDropState = ref.watch(pointDropStateProvider);
    final isDropping = ref.watch(isDroppingPointProvider);

    // Handle success state
    ref.listen(pointDropStateProvider, (previous, next) {
      next.maybeWhen(
        success: (point) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Point dropped at ${point.maidenhead6char}')),
          );
          // Refresh feed
          final userId = ref.read(currentUserIdProvider);
          ref.read(feedNotifierProvider.notifier).fetchNearbyPoints(userId: userId);
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        },
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text('Drop a Point')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'What\'s happening?',
                hintText: 'Share something with people nearby...',
              ),
              maxLength: 280,
              maxLines: 4,
            ),
            SizedBox(height: 16),

            // Show different loading messages for each phase
            if (isDropping)
              pointDropState.when(
                fetchingLocation: () => Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Getting your location...'),
                  ],
                ),
                dropping: () => Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Creating point...'),
                  ],
                ),
                orElse: () => Container(),
              ),

            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isDropping ? null : _handleDropPoint,
              child: Text('Drop Point'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDropPoint() {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to drop a point')),
      );
      return;
    }

    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    ref.read(pointDropNotifierProvider.notifier).dropPoint(
      userId: userId,
      content: content,
    );
  }
}
```

---

### Example 4: Main Feed Screen

**Requirement**: Display nearby points with pull-to-refresh

```dart
class MainFeedScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends ConsumerState<MainFeedScreen> {
  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  void _loadFeed() {
    final userId = ref.read(currentUserIdProvider);
    ref.read(feedNotifierProvider.notifier).fetchNearbyPoints(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedStateProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Nearby Points')),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadFeed();
        },
        child: feedState.when(
          initial: () => _buildEmptyState(),
          loading: () => Center(child: CircularProgressIndicator()),
          loaded: (points, userLocation) {
            if (points.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              itemCount: points.length,
              itemBuilder: (context, index) => PointCard(
                point: points[index],
                userLocation: userLocation,
              ),
            );
          },
          error: (message) => ErrorCard(
            message: message,
            onRetry: _loadFeed,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PointCreationScreen()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No points nearby'),
          Text('Be the first to drop a point!'),
        ],
      ),
    );
  }
}
```

---

### Example 5: Point Card with Like Button

**Requirement**: Display point with like/unlike functionality

```dart
class PointCard extends ConsumerStatefulWidget {
  final Point point;
  final LocationCoordinate userLocation;

  const PointCard({
    required this.point,
    required this.userLocation,
  });

  @override
  ConsumerState<PointCard> createState() => _PointCardState();
}

class _PointCardState extends ConsumerState<PointCard> {
  @override
  void initState() {
    super.initState();

    // Initialize like state for this point
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      ref.read(likeNotifierProvider.notifier).initializeLikeStateForPoint(
        pointId: widget.point.id,
        userId: userId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = ref.watch(pointLikeStatusProvider(widget.point.id));
    final likeCount = ref.watch(pointLikeCountProvider(widget.point.id));
    final likeState = ref.watch(likeStateProvider);
    final isLoading = likeState.loadingStates[widget.point.id] ?? false;
    final error = likeState.errors[widget.point.id];

    // Calculate distance
    final distance = HaversineCalculator.calculateDistance(
      widget.userLocation,
      widget.point.location,
    );
    final formattedDistance = DistanceFormatter.format(distance);

    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content
            Text(
              widget.point.content,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Metadata row
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  widget.point.maidenhead6char,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(width: 16),
                Text(
                  formattedDistance,
                  style: TextStyle(color: Colors.grey),
                ),
                Spacer(),

                // Like button
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: isLoading ? null : _handleLikeToggle,
                    ),
                    Text('$likeCount'),
                  ],
                ),
              ],
            ),

            // Error message (if any)
            if (error != null)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleLikeToggle() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to like points')),
      );
      return;
    }

    await ref.read(likeNotifierProvider.notifier).toggleLike(
      pointId: widget.point.id,
      userId: userId,
    );
  }
}
```

---

## Testing Strategy

### Unit Testing Notifiers

**Pattern**: Mock dependencies and test state transitions

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFetchProfileUseCase extends Mock implements FetchProfileUseCase {}
class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

void main() {
  late ProfileNotifier notifier;
  late MockFetchProfileUseCase mockFetchUseCase;
  late MockUpdateProfileUseCase mockUpdateUseCase;

  setUp(() {
    mockFetchUseCase = MockFetchProfileUseCase();
    mockUpdateUseCase = MockUpdateProfileUseCase();
    notifier = ProfileNotifier(
      fetchProfileUseCase: mockFetchUseCase,
      updateProfileUseCase: mockUpdateUseCase,
    );
  });

  group('ProfileNotifier', () {
    test('initial state is ProfileState.initial()', () {
      expect(notifier.state, const ProfileState.initial());
    });

    test('fetchProfile sets loading then loaded on success', () async {
      final profile = Profile(
        id: 'user-123',
        username: 'testuser',
        createdAt: DateTime.now(),
      );

      when(() => mockFetchUseCase(any())).thenAnswer((_) async => profile);

      final states = <ProfileState>[];
      notifier.addListener((state) => states.add(state));

      await notifier.fetchProfile('user-123');

      expect(states, [
        const ProfileState.loading(),
        ProfileState.loaded(profile: profile),
      ]);
    });

    test('fetchProfile sets error on NotFoundException', () async {
      when(() => mockFetchUseCase(any())).thenThrow(
        NotFoundException('Profile not found'),
      );

      await notifier.fetchProfile('user-123');

      expect(
        notifier.state,
        const ProfileState.error(
          message: 'Profile not found. Please create a profile first.',
        ),
      );
    });

    // Test updateProfile success, validation errors, etc.
  });
}
```

### Integration Testing Providers

**Pattern**: Test provider dependencies and state flow

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('profileNotifierProvider depends on use case providers', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Verify dependencies are created
    final fetchUseCase = container.read(fetchProfileUseCaseProvider);
    expect(fetchUseCase, isA<FetchProfileUseCase>());

    final updateUseCase = container.read(updateProfileUseCaseProvider);
    expect(updateUseCase, isA<UpdateProfileUseCase>());

    // Verify notifier is created with dependencies
    final notifier = container.read(profileNotifierProvider.notifier);
    expect(notifier, isA<ProfileNotifier>());
  });

  testWidgets('currentProfileProvider returns null when state is not loaded', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final currentProfile = container.read(currentProfileProvider);
    expect(currentProfile, isNull);
  });

  testWidgets('currentProfileProvider returns profile when state is loaded', (tester) async {
    final container = ProviderContainer(
      overrides: [
        // Override with test data
      ],
    );
    addTearDown(container.dispose);

    // Load profile
    final notifier = container.read(profileNotifierProvider.notifier);
    await notifier.fetchProfile('user-123');

    // Verify currentProfileProvider extracts profile
    final currentProfile = container.read(currentProfileProvider);
    expect(currentProfile, isNotNull);
    expect(currentProfile!.id, 'user-123');
  });
}
```

### Widget Testing with Providers

**Pattern**: Use ProviderScope to inject test providers

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('ProfileScreen shows loading indicator while fetching', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    // Should show loading initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ProfileScreen shows profile data when loaded', (tester) async {
    final mockProfile = Profile(
      id: 'user-123',
      username: 'testuser',
      bio: 'Test bio',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileStateProvider.overrideWith((ref) => ProfileState.loaded(profile: mockProfile)),
        ],
        child: MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    expect(find.text('testuser'), findsOneWidget);
    expect(find.text('Test bio'), findsOneWidget);
  });
}
```

---

## Integration Checklist

### Before UI Integration

- [ ] All state models have Freezed generated files
- [ ] All notifiers compile without errors
- [ ] All providers are registered in provider files
- [ ] Provider dependencies are correctly wired
- [ ] Error messages are user-friendly (not technical)
- [ ] Documentation is up-to-date

### UI Screen Integration

For each screen:

- [ ] Import required providers (`profile_providers.dart`, `point_providers.dart`, etc.)
- [ ] Watch state providers in `build()` method
- [ ] Use `ref.listen()` for side effects (navigation, snackbars)
- [ ] Call notifier methods via `ref.read(notifierProvider.notifier)`
- [ ] Handle all state variants (`.when()` exhaustive pattern matching)
- [ ] Display loading indicators during async operations
- [ ] Show error messages with retry options
- [ ] Clean up state on screen disposal (call `reset()` if needed)

### Testing Integration

- [ ] Unit tests for all notifiers
- [ ] Integration tests for provider dependencies
- [ ] Widget tests for UI screens with mock providers
- [ ] End-to-end tests for critical flows

---

## Performance Considerations

### Provider Optimization

**1. Use `.select()` to reduce rebuilds**:
```dart
// ❌ Bad: Rebuilds on any LikeState change
final likeState = ref.watch(likeStateProvider);
final isLiked = likeState.likedByUser[pointId] ?? false;

// ✅ Good: Rebuilds only when this point's like status changes
final isLiked = ref.watch(pointLikeStatusProvider(pointId));
```

**2. Use `Provider.family` for per-item state**:
```dart
// ✅ Efficient: Each point card only watches its own like status
final pointLikeStatusProvider = Provider.family<bool, String>((ref, pointId) {
  return ref.watch(likeStateProvider.select((state) => state.likedByUser[pointId] ?? false));
});
```

**3. Dispose notifiers when not needed**:
```dart
@override
void dispose() {
  ref.read(profileNotifierProvider.notifier).reset();
  super.dispose();
}
```

### State Model Optimization

**1. Use immutable collections**:
```dart
// Current implementation uses Map<String, T>
// For large collections, consider using built_collection for better performance
```

**2. Lazy loading for large feeds**:
```dart
// Future enhancement: Implement pagination for feeds with 100+ points
// Current implementation loads all nearby points at once (acceptable for MVP)
```

---

## Future Enhancements

### 1. Real-Time Updates (Supabase Realtime)

**Current**: Feed requires manual refresh

**Enhanced**:
```dart
final realtimePointsProvider = StreamProvider<List<Point>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);

  return supabase
    .from('points')
    .stream(primaryKey: ['id'])
    .where('is_active', isEqualTo: true)
    .map((data) => data.map((json) => Point.fromJson(json)).toList());
});

// FeedNotifier automatically updates when new points are created
```

### 2. Offline Support

**Current**: Requires network connection

**Enhanced**: Use local caching with providers
```dart
final cachedFeedProvider = FutureProvider<List<Point>>((ref) async {
  try {
    // Try network first
    final points = await ref.read(fetchNearbyPointsUseCaseProvider)(request);
    // Cache to local storage
    await cachePoints(points);
    return points;
  } catch (e) {
    // Fallback to cache on error
    return await getCachedPoints();
  }
});
```

### 3. Analytics Integration

**Track state changes for analytics**:
```dart
ref.listen(pointDropStateProvider, (previous, next) {
  next.maybeWhen(
    success: (point) => analytics.logEvent('point_created'),
    error: (message) => analytics.logEvent('point_creation_failed', {'error': message}),
    orElse: () {},
  );
});
```

---

## Summary

### Key Takeaways

1. **Riverpod + StateNotifier** provides robust, testable state management
2. **Freezed** ensures immutable, type-safe state models
3. **Clean Architecture** separates concerns across layers
4. **Use Cases** contain all business logic and validation
5. **Notifiers** orchestrate use cases and manage UI state
6. **Providers** compose dependencies and expose state to UI
7. **Error Handling** maps technical exceptions to user-friendly messages
8. **Optimistic Updates** improve perceived performance (likes)
9. **Two-Phase Loading** provides better UX for multi-step operations (point drop)
10. **Per-Item State** enables efficient concurrent operations (likes)

### Implementation Stats

- **7 State Models**: AuthState, ProfileState, PointDropState, FeedState, LikeState, LocationPermissionState, LocationServiceState
- **5 Notifiers**: AuthNotifier, ProfileNotifier, PointDropNotifier, FeedNotifier, LikeNotifier
- **27 Providers**: Organized across 5 provider files
- **11 Use Cases**: Integrated with state layer
- **~2,500 Lines**: Total state management code

### Next Steps

1. **UI Integration**: Wire providers into existing screens (Auth Gate, Main Feed, Point Creation)
2. **Testing**: Write unit tests for notifiers, integration tests for providers
3. **Real-Time**: Integrate Supabase Realtime for auto-updating feed
4. **Analytics**: Track state changes for user behavior insights
5. **Offline Support**: Add local caching for offline functionality

---

**Document Version**: 1.0
**Last Updated**: Phase 5.4 Complete
**Maintained By**: Development Team
