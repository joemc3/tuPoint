# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ CRITICAL: Git Branching Policy

**BEFORE making ANY file changes (create, edit, or delete) in a new session:**

1. **Check current branch**: Run `git branch --show-current`
2. **If on `main`**: STOP and ask user for permission to either:
   - Create a feature branch: `git checkout -b feature/<descriptive-name>`, OR
   - Get explicit permission to commit directly to main for this specific change
3. **Never assume permission**: Even if granted in a previous session, always verify for new sessions
4. **This applies to**:
   - All direct file operations (Write, Edit, NotebookEdit)
   - All agent invocations that create/modify files
   - All slash commands that generate files

**New session triggers**: Start of conversation, after `/reset`, after `/compact`

**Exception**: Only commit to main with explicit user permission granted in the current session for that specific change.

### Commit Policy

**DO NOT auto-commit changes.** The user wants to review all changes before committing.

- Make file changes as requested
- Show diffs or summaries of changes
- Wait for user to either:
  - Manually commit using git commands, OR
  - Explicitly ask you to commit with specific message

## Project Overview

**tuPoint (tP.2)** is a specification-driven Flutter application for hyper-local, ephemeral social media where content disappears when users leave the area. The project uniquely combines detailed specification documents with specialized AI agents for implementation.

**Key Principle**: "Content disappears when you leave the area" - every feature must reinforce this hyper-local, ephemeral nature.

## Codebase Statistics

- **Total Dart Files**: 74 files (~16,000 lines of code, excluding generated files)
- **Screens**: 3 complete screens (Auth Gate, Main Feed, Point Creation)
- **Reusable Widgets**: 1 component (PointCard)
- **Domain Entities**: 10 core models (Profile, Point, Like, AuthState, ProfileState, PointDropState, FeedState, LikeState, LocationPermissionState, LocationServiceState) + generated Freezed/JSON files
- **Repository Interfaces**: 3 contracts (IPointsRepository, IProfileRepository, ILikesRepository)
- **Repository Implementations**: 3 Supabase implementations (~915 lines)
- **Core Services**: 1 (LocationService for GPS and permissions - 318 lines)
- **Riverpod Providers**: 27 providers across 5 provider files (Supabase + 3 repositories + 6 auth + 6 location + 4 profile + 7 point/feed/like)
- **State Notifiers**: 5 notifiers (~2,500 lines total)
  - AuthNotifier (346 lines) - Authentication state
  - ProfileNotifier - Profile fetch/update
  - PointDropNotifier - Point creation with GPS
  - FeedNotifier - Nearby points filtering
  - LikeNotifier - Like/unlike with optimistic updates
- **Use Cases**: 11 business logic classes (Profile: 3, Point: 3, Like: 3, GetLikeCount: 1, FetchNearbyPoints: 1)
- **Request DTOs**: 9 strongly-typed request objects (added UpdateProfileRequest)
- **Geospatial Utilities**: 3 utilities (MaidenheadConverter, HaversineCalculator, DistanceFormatter)
- **Value Objects**: 1 immutable type (LocationCoordinate)
- **Domain Exceptions**: 7 exception classes
- **Supabase Migrations**: 4 SQL schema files
- **RLS Policies**: 10 security policies (profile: 4, points: 3, likes: 3)
- **Test Coverage**: 369 comprehensive tests (~3,245 lines)
  - ✅ **Domain Utilities**: 91 tests
  - ✅ **Domain Entities**: 73 tests (Profile: 25, Point: 16, Like: 8, LocationPermissionState: 9, LocationServiceState: 15)
  - ✅ **Domain Use Cases**: 126 tests
  - ✅ **Widget Tests**: 21 tests (PointCard: 20, smoke test: 1)
  - ✅ **Integration Tests**: 58 tests (repository implementations with real database)
- **Test Pass Rate**: 355/369 passing (96.2%)
- **Specialized AI Agents**: 8 agents for architecture domains
- **Specification Documents**: 9 comprehensive spec files in `project_standards/` (including AUTH_ARCHITECTURE.md, STATE_MANAGEMENT_IMPLEMENTATION.md)
- **Theme Variants**: 2 modes (Light "BLUE IMMERSION", Dark "BLUE ELECTRIC")

## Current Status

**Development Phase**: Database Setup Complete → Domain Layer Complete → Data Layer Complete → **State Management COMPLETE** (Phase 5.1-5.4) → UI Integration Next

### Completed (Phase 0-4): ✅

**Backend & Infrastructure:**
- ✅ **Local Supabase Environment** - Docker containers running with PostgreSQL 17 + PostGIS
- ✅ **Database Schema** - 4 migrations applied (profile, points, likes tables)
- ✅ **Row Level Security (RLS)** - 10 RLS policies enforcing authorization at database level (profile: 4, points: 3, likes: 3). Points table intentionally omits DELETE policy (soft delete via UPDATE). Likes table intentionally omits UPDATE policy (likes are immutable).
- ✅ **PostGIS Spatial Support** - GEOMETRY(POINT, 4326) for lat/lon storage
- ✅ **Auth Providers** - Email/Password, Google OAuth, Apple Sign In configured
- ✅ **Environment Config** - `.env` and `env_config.dart` for local development

**Presentation Layer (UI Only):**
- ✅ **Full UI mockups** with hardcoded test data for visual demonstration
- ✅ **v3.0 "BLUE DOMINANCE" theme** - Location Blue (#3A9BFC) prominently featured throughout
- ✅ **3 navigable screens**: Authentication Gate → Main Feed (with 5 Point cards) → Point Creation
- ✅ **Material 3 design** with Inter typography
- ✅ **100% theme compliance** - zero hardcoded colors, fonts, or sizes

**Domain Layer Foundation (Phase 2.1):**
- ✅ **Dependencies Installed** - Riverpod, Supabase, Geolocator, Freezed, JSON serialization packages
- ✅ **LocationCoordinate Value Object** - Immutable lat/lon with validation
- ✅ **MaidenheadConverter Utility** - Ham radio grid square system (~800m precision)
- ✅ **HaversineCalculator Utility** - Great-circle distance calculation (<0.5% error)
- ✅ **DistanceFormatter Utility** - Human-readable distance display
- ✅ **Comprehensive Test Coverage** - 91 passing tests for all geospatial utilities

**Domain Layer Entities (Phase 3.1):**
- ✅ **Profile Entity** - Freezed immutable model with id, username, bio, timestamps
- ✅ **Point Entity** - Freezed model with LocationCoordinate integration, PostGIS geometry converter
- ✅ **Like Entity** - Freezed model representing composite key relationship
- ✅ **JSON Serialization** - Snake_case to camelCase mapping for all entities
- ✅ **Entity Test Coverage** - 49 comprehensive tests for all entities (25 Profile, 16 Point, 8 Like)

**Domain Layer Repository Interfaces (Phase 3.2):**
- ✅ **IPointsRepository** - Abstract contract for Point CRUD operations (6 methods)
- ✅ **IProfileRepository** - Abstract contract for Profile operations (5 methods)
- ✅ **ILikesRepository** - Abstract contract for Like operations (6 methods)
- ✅ **Domain Exceptions** - 7 exception classes (UnauthorizedException, NotFoundException, ValidationException, etc.)
- ✅ **RLS-Aware Design** - Repository methods mirror database RLS policies
- ✅ **Technology-Agnostic** - No Supabase imports, pure Dart interfaces

**Domain Layer Use Cases (Phase 3.3):**
- ✅ **CreateProfileUseCase** - Profile creation with username validation
- ✅ **FetchProfileUseCase** - Get user profile by ID
- ✅ **DropPointUseCase** - Create Point with content validation (1-280 chars)
- ✅ **FetchNearbyPointsUseCase** - 5km radius filtering with HaversineCalculator
- ✅ **FetchUserPointsUseCase** - Get user's points sorted by date
- ✅ **LikePointUseCase** - Like a point
- ✅ **UnlikePointUseCase** - Unlike a point
- ✅ **GetLikeCountUseCase** - Get like count for a point
- ✅ **Request DTOs** - 8 strongly-typed request classes
- ✅ **UseCase Base Class** - Abstract generic class for all use cases
- ✅ **Comprehensive Test Coverage** - 126 tests for all use cases (validation, error handling, edge cases)

**Domain Layer Status**:
- ✅ **Utilities**: COMPLETE with comprehensive tests (91 tests)
- ✅ **Entities**: COMPLETE with comprehensive tests (49 tests)
- ✅ **Repository Interfaces**: COMPLETE (technology-agnostic contracts)
- ✅ **Use Cases**: COMPLETE with comprehensive tests (126 tests)
- ✅ **Widget Tests**: COMPLETE (21 tests for PointCard and smoke test)

**Data Layer (Phase 4): ✅ COMPLETE**

**Repository Implementations:**
- ✅ **SupabaseProfileRepository** - Profile CRUD with RLS enforcement (5 methods, ~274 lines)
- ✅ **SupabasePointsRepository** - Point CRUD with PostGIS geometry handling (6 methods, ~335 lines)
- ✅ **SupabaseLikesRepository** - Like operations with composite key handling (6 methods, ~306 lines)

**Key Features:**
- ✅ **RLS-Aware Design** - Defensive client-side checks mirror database RLS policies
- ✅ **PostGIS Integration** - WKT format for INSERT/UPDATE, GeoJSON for SELECT
- ✅ **Error Mapping** - PostgrestException → domain exceptions (23505 → DuplicateUsernameException, 42501 → UnauthorizedException, etc.)
- ✅ **Comprehensive Documentation** - Inline comments explain RLS policies, constraints, and edge cases

**Integration Test Coverage:**
- ✅ **SupabaseProfileRepository Tests** - 23 tests (create, fetch, update, RLS, validation)
- ✅ **SupabasePointsRepository Tests** - 19 tests (CRUD, PostGIS, content validation, deactivation)
- ✅ **SupabaseLikesRepository Tests** - 16 tests (like/unlike, counts, duplicate prevention)
- ✅ **Test Helper** - SupabaseTestHelper for integration test setup, cleanup, and auth

**Total Test Coverage**: 345 comprehensive tests (96.0% pass rate)
- ✅ Domain Utilities: 91 tests
- ✅ Domain Entities: 49 tests
- ✅ Domain Use Cases: 126 tests
- ✅ Widget Tests: 21 tests
- ✅ Integration Tests: 58 tests (real database)

**State Management Layer (Phase 5): ✅ COMPLETE**

**Repository Providers (Phase 5.1): ✅ COMPLETE**
- ✅ **Supabase Initialization** - App-wide Supabase client initialization in main.dart
- ✅ **ProviderScope Setup** - Riverpod enabled for entire app
- ✅ **Repository Providers** - Core infrastructure providers:
  - `supabaseClientProvider` - Singleton Supabase client access
  - `profileRepositoryProvider` - IProfileRepository implementation
  - `pointsRepositoryProvider` - IPointsRepository implementation
  - `likesRepositoryProvider` - ILikesRepository implementation

**Authentication State (Phase 5.2): ✅ COMPLETE**
- ✅ **AuthState Model** - Freezed union type (Unauthenticated, Authenticated, Loading, Error)
- ✅ **AuthNotifier** - StateNotifier managing all auth operations (346 lines)
  - Email/password sign in and sign up
  - Google OAuth and Apple Sign In support
  - Automatic profile creation during signup
  - Session persistence via Supabase auth state stream
  - User-friendly error mapping
- ✅ **Auth Providers** - 6 Riverpod providers in `auth_providers.dart` (131 lines):
  - `authNotifierProvider` - Main authentication state notifier
  - `authStateProvider` - Convenience provider for current state
  - `currentUserIdProvider` - Extracts userId when authenticated
  - `hasProfileProvider` - Checks profile completion status
  - `createProfileUseCaseProvider` - Profile creation use case
  - `fetchProfileUseCaseProvider` - Profile fetching use case
- ✅ **Documentation** - Comprehensive usage guide and architecture diagrams

**Location Services (Phase 5.3): ✅ COMPLETE**
- ✅ **LocationPermissionState Model** - Freezed union type (notAsked, granted, denied, deniedForever, serviceDisabled)
- ✅ **LocationServiceState Model** - Freezed union type (loading, available, permissionDenied, serviceDisabled, error)
- ✅ **LocationService Class** - GPS and permission handling service (318 lines)
  - Check and request location permissions
  - One-time location fetch (getCurrentLocation)
  - Real-time location stream (getLocationStream)
  - Platform settings access (openLocationSettings, openAppSettings)
  - High accuracy GPS with 10m distance filter
- ✅ **Location Providers** - 6 Riverpod providers in `location_providers.dart` (217 lines):
  - `locationServiceProvider` - LocationService instance
  - `locationPermissionProvider` - Current permission state
  - `currentLocationProvider` - One-time location fetch
  - `locationStreamProvider` - Real-time location stream
  - `hasLocationPermissionProvider` - Boolean permission check
  - `locationServicesEnabledProvider` - GPS enabled check
- ✅ **Platform Configuration** - iOS Info.plist and Android AndroidManifest.xml updated
- ✅ **Test Coverage** - 24 tests for location state models (100% pass rate)
- ✅ **Documentation** - 3 comprehensive guides (README, Quick Start, Summary)

**Application State (Phase 5.4): ✅ COMPLETE**
- ✅ **ProfileState Model** - Freezed union type (initial, loading, loaded, error)
- ✅ **ProfileNotifier** - StateNotifier for profile operations
  - Fetch user profiles by ID
  - Update profile (username, bio)
  - User-friendly error mapping
- ✅ **UpdateProfileUseCase** - Profile update business logic with validation
- ✅ **Profile Providers** - 4 Riverpod providers in `profile_providers.dart`:
  - `updateProfileUseCaseProvider` - UpdateProfileUseCase instance
  - `profileNotifierProvider` - Main profile state notifier
  - `profileStateProvider` - Convenience provider for current state
  - `currentProfileProvider` - Extracts Profile from loaded state
- ✅ **PointDropState Model** - Freezed union type (initial, fetchingLocation, dropping, success, error)
- ✅ **PointDropNotifier** - StateNotifier for point creation with GPS integration
  - Two-phase operation (GPS fetch → database create)
  - Automatic Maidenhead conversion
  - Location service integration
- ✅ **FeedState Model** - Freezed union type (initial, loading, loaded with location, error)
- ✅ **FeedNotifier** - StateNotifier for nearby points feed
  - 5km radius filtering via HaversineCalculator
  - Real-time location integration
  - Excludes user's own points
  - Sorted by distance (nearest first)
- ✅ **LikeState Model** - Freezed data class for per-point like tracking
- ✅ **LikeNotifier** - StateNotifier for like/unlike with optimistic updates
  - Instant UI feedback (optimistic updates)
  - Automatic rollback on errors
  - Per-point independent state
  - Concurrent like operations supported
- ✅ **Point Providers** - 16 providers in `point_providers.dart`:
  - Use case providers (5): drop, fetchNearby, like, unlike, getLikeCount
  - Point drop providers (3): notifier, state, isDropping
  - Feed providers (4): notifier, state, nearbyPoints, isLoading
  - Like providers (4): notifier, state, pointLikeStatus (family), pointLikeCount (family)
- ✅ **Comprehensive Documentation** - 73KB STATE_MANAGEMENT_IMPLEMENTATION.md with:
  - Complete architecture documentation
  - 15+ usage examples
  - Data flow diagrams
  - Error handling strategies
  - Testing guidelines
  - Integration checklist

**State Management Summary:**
- **7 State Models**: AuthState, ProfileState, PointDropState, FeedState, LikeState, LocationPermissionState, LocationServiceState
- **5 Notifiers**: AuthNotifier, ProfileNotifier, PointDropNotifier, FeedNotifier, LikeNotifier (~2,500 lines)
- **27 Providers**: Across 5 provider files (repository, auth, location, profile, point/feed/like)
- **11 Use Cases**: All wired into state layer

**Next Steps (Phase 6+):**
- ❌ **UI Integration** - Wire state providers into Auth Gate, Main Feed, Point Creation screens
- ❌ **Permission Flows** - Add location permission request UI
- ❌ **Testing** - Unit tests for notifiers, integration tests for providers
- ❌ **Real-Time Updates** - Integrate Supabase Realtime for auto-updating feed
- ❌ **Error Display** - Implement user-friendly error messages throughout UI

**Current Phase**: State Management Complete (Phase 5.1-5.4) → UI Integration Next

## Project Structure

```
/Users/joemc3/tmp/tuPoint/
├── app/                          # Flutter application
│   ├── .env                      # Local Supabase credentials (gitignored)
│   ├── lib/
│   │   ├── core/
│   │   │   ├── config/          # Environment configuration
│   │   │   ├── constants/       # App-wide constants (spacing, sizes, colors)
│   │   │   ├── providers/       # Riverpod providers ✅ (27 total)
│   │   │   │   ├── repository_providers.dart    # Repository providers (4 providers)
│   │   │   │   ├── auth_providers.dart          # Authentication providers (6 providers)
│   │   │   │   ├── location_providers.dart      # Location providers (6 providers)
│   │   │   │   ├── profile_providers.dart       # Profile providers (4 providers)
│   │   │   │   └── point_providers.dart         # Point/Feed/Like providers (16 providers)
│   │   │   ├── services/        # Core services ✅
│   │   │   │   ├── location_service.dart        # GPS and permission service (318 lines)
│   │   │   │   └── LOCATION_SERVICES_README.md  # Location services documentation
│   │   │   └── theme/           # Material 3 theme v3.0 (BLUE DOMINANCE)
│   │   ├── presentation/
│   │   │   ├── notifiers/       # State management notifiers ✅ (5 total, ~2,500 lines)
│   │   │   │   ├── auth_notifier.dart           # Authentication state notifier (346 lines)
│   │   │   │   ├── profile_notifier.dart        # Profile state notifier
│   │   │   │   ├── point_drop_notifier.dart     # Point creation notifier
│   │   │   │   ├── feed_notifier.dart           # Feed state notifier
│   │   │   │   ├── like_notifier.dart           # Like/unlike notifier
│   │   │   │   ├── README.md                    # Notifier usage documentation
│   │   │   │   └── LIKE_NOTIFIER_README.md      # Like notifier detailed guide
│   │   │   ├── screens/         # Auth, MainFeed, PointCreation screens
│   │   │   └── widgets/         # Reusable PointCard component
│   │   ├── domain/              # Domain layer (business logic)
│   │   │   ├── utils/           # Geospatial calculation utilities ✅
│   │   │   │   ├── maidenhead_converter.dart
│   │   │   │   ├── haversine_calculator.dart
│   │   │   │   └── distance_formatter.dart
│   │   │   ├── value_objects/   # Immutable value objects ✅
│   │   │   │   └── location_coordinate.dart
│   │   │   ├── entities/        # Domain entities with Freezed ✅ (10 total)
│   │   │   │   ├── profile.dart (+ .freezed.dart, .g.dart)             # User profile entity
│   │   │   │   ├── point.dart (+ .freezed.dart, .g.dart)               # Location post entity
│   │   │   │   ├── like.dart (+ .freezed.dart, .g.dart)                # Like relationship entity
│   │   │   │   ├── auth_state.dart (+ .freezed.dart)                   # Authentication state model
│   │   │   │   ├── profile_state.dart (+ .freezed.dart)                # Profile operation state
│   │   │   │   ├── point_drop_state.dart (+ .freezed.dart)             # Point creation state
│   │   │   │   ├── feed_state.dart (+ .freezed.dart)                   # Feed display state
│   │   │   │   ├── like_state.dart (+ .freezed.dart)                   # Like/unlike state
│   │   │   │   ├── location_permission_state.dart (+ .freezed.dart)    # Location permission states
│   │   │   │   └── location_service_state.dart (+ .freezed.dart)       # Location service states
│   │   │   ├── exceptions/      # Domain exceptions ✅
│   │   │   │   └── repository_exceptions.dart
│   │   │   ├── repositories/    # Repository interfaces ✅
│   │   │   │   ├── i_points_repository.dart
│   │   │   │   ├── i_profile_repository.dart
│   │   │   │   └── i_likes_repository.dart
│   │   │   └── use_cases/       # Business logic use cases ✅ (11 total)
│   │   │       ├── profile_use_cases/    # CreateProfileUseCase, FetchProfileUseCase, UpdateProfileUseCase
│   │   │       ├── point_use_cases/      # DropPointUseCase, FetchNearbyPointsUseCase, FetchUserPointsUseCase
│   │   │       ├── like_use_cases/       # LikePointUseCase, UnlikePointUseCase, GetLikeCountUseCase
│   │   │       ├── requests.dart         # 9 request DTOs (added UpdateProfileRequest)
│   │   │       └── use_case_base.dart    # Abstract UseCase<Success, Request> base class
│   │   └── data/                # Data layer ✅
│   │       └── repositories/    # Supabase repository implementations ✅
│   │           ├── supabase_profile_repository.dart    # Profile CRUD (274 lines)
│   │           ├── supabase_points_repository.dart     # Point CRUD with PostGIS (335 lines)
│   │           └── supabase_likes_repository.dart      # Like operations (306 lines)
│   └── test/
│       ├── widget_test.dart     # Basic widget test (1 test)
│       ├── helpers/             # Test utilities ✅
│       │   └── supabase_test_helper.dart    # Integration test helper
│       ├── widget/              # Widget tests ✅
│       │   └── point_card_test.dart    # PointCard component tests (20 tests)
│       ├── domain/              # Domain layer tests ✅
│       │   ├── utils/           # Geospatial utility tests (91 tests)
│       │   ├── entities/        # Entity tests (73 tests: Profile, Point, Like, LocationPermissionState, LocationServiceState)
│       │   └── use_cases/       # Use case tests (126 tests)
│       │       ├── profile_use_cases/
│       │       ├── point_use_cases/
│       │       └── like_use_cases/
│       └── data/                # Data layer integration tests ✅
│           └── repositories/    # Repository integration tests (58 tests)
│               ├── supabase_profile_repository_integration_test.dart    # 23 tests
│               ├── supabase_points_repository_integration_test.dart     # 19 tests
│               └── supabase_likes_repository_integration_test.dart      # 16 tests
├── supabase/                     # Supabase configuration
│   ├── config.toml              # Auth providers, API settings
│   └── migrations/              # Database schema migrations (4 files)
│       ├── 20251112143441_enable_postgis.sql
│       ├── 20251112143459_create_profile_table.sql
│       ├── 20251112143529_create_points_table.sql
│       └── 20251112143615_create_likes_table.sql
├── project_standards/            # Detailed specifications (source of truth)
│   ├── architecture_and_state_management.md
│   ├── api_strategy.md
│   ├── AUTH_ARCHITECTURE.md     # Authentication architecture diagrams and flows
│   ├── STATE_MANAGEMENT_IMPLEMENTATION.md    # Complete state management reference (73KB)
│   ├── product_requirements_document(PRD).md
│   ├── tuPoint_data_schema.md
│   ├── UX_user_flow.md
│   ├── testing_strategy.md
│   └── project-theme.md         # v3.0 - Aggressive Location Blue usage
├── general_standards/            # Flutter/UX best practices
├── .claude/                      # Agents and commands
└── .env.example                  # OAuth setup documentation
```

## Development Commands

### Flutter App (in `/app` directory)

```bash
# Install dependencies
cd app && flutter pub get

# Run on connected device/emulator
flutter run

# Run specific platform
flutter run -d chrome          # Web
flutter run -d macos           # macOS
flutter run -d <device-id>     # Specific device

# Run tests
flutter test                    # All tests
flutter test test/path/to/test_file.dart  # Single test

# Build
flutter build apk              # Android APK
flutter build ios              # iOS (requires macOS)
flutter build web              # Web build

# Code analysis
flutter analyze                # Static analysis
dart fix --apply              # Auto-fix lints
```

### Supabase Commands

**Local Development (Docker):**

```bash
# Start Supabase services
supabase start

# Stop Supabase services
supabase stop

# Reset database (reapplies all migrations)
supabase db reset

# Create new migration
supabase migration new <migration_name>

# View status
supabase status

# View logs
supabase logs -f
```

**Supabase Studio (GUI):**
- Open `http://127.0.0.1:54323` for visual database management
- View tables, run SQL queries, inspect RLS policies

**Custom slash commands for advanced operations:**

```bash
/supabase-migration-assistant --create    # Create migration
/supabase-schema-sync --pull             # Pull schema from Supabase
/supabase-type-generator --all-tables    # Generate TypeScript types
/supabase-security-audit --comprehensive  # Run security audit
/supabase-data-explorer --inspect        # Explore database
```

**Note**: MCP tools require access token configuration. For local dev, use `supabase` CLI commands directly.

### Theme Generation

```bash
/createThemeTemplate [requirements]       # Generate theme specification
```

## Visual Design: Theme v3.0 "BLUE DOMINANCE"

The app uses an aggressively bold theme where **Location Blue (#3A9BFC) dominates every screen**. This is not a subtle accent color—blue is the defining visual characteristic.

### Theme Characteristics

**Light Theme - "BLUE IMMERSION":**
- Background: `#D6EEFF` - Obviously blue, impossible to miss
- Cards: `#F0F7FF` blue-tinted with **3dp solid blue borders**
- Chips: `#99CCFF` - Saturated blue for Maidenhead codes
- FAB: Location Blue with massive 24dp glow effect
- Dividers: 30% opacity blue lines between cards

**Dark Theme - "BLUE ELECTRIC":**
- Background: `#0F1A26` - Dark with clear blue tint
- Cards: `#1A2836` blue-tinted with **2dp glowing blue borders + aura effect**
- Primary: `#66B8FF` - Brighter electric blue that glows
- FAB: Dual-layer glow (24dp + 32dp blur) for maximum impact
- Dividers: 40% opacity glowing blue lines

### Design Principles

1. **100% Theme Compliance**: Zero hardcoded colors, fonts, or sizes anywhere in presentation layer
2. **Constants-Driven**: All spacing, sizes, and style values reference `AppConstants`
3. **Accessibility First**: All combinations achieve WCAG 2.1 AA (most achieve AAA)
4. **Material 3**: Uses latest Material Design components with proper theming

### Key Files

- **Theme Spec**: `project_standards/project-theme.md` (v3.0 with detailed color tables)
- **Theme Implementation**: `app/lib/core/theme/app_theme.dart`
- **Constants**: `app/lib/core/constants/app_constants.dart`

## Architecture

### Three-Layer Clean Architecture

1. **Presentation Layer** (`lib/presentation/`)
   - Flutter widgets, screens, view models
   - Riverpod ConsumerWidgets for state consumption
   - NO business logic in widgets

2. **Domain Layer** (`lib/domain/`)
   - Core business logic, entities, use cases
   - Repository interfaces (contracts)
   - Technology-agnostic (pure Dart, no Flutter dependencies)
   - Examples: `Point`, `Profile`, `DropPointUseCase`, `ToggleLikeUseCase`

3. **Data Layer** (`lib/data/`)
   - Supabase client integration via PostgREST
   - Repository implementations
   - DTOs for API responses
   - RLS-aware error handling

### State Management: Riverpod

**Provider Types Used:**

| Type | Purpose | Example |
|------|---------|---------|
| `Provider` | Read-only values | `pointsRepositoryProvider` |
| `StateNotifierProvider` | Complex mutable state | `authProvider`, `pointDropNotifier` |
| `FutureProvider` | Async operations | `allActivePointsFutureProvider` |
| `StreamProvider` | Real-time data | `currentLocationProvider` |

**Key Data Flow Pattern:**
```dart
// Providers watch and compose other providers
final nearbyPointsProvider = Provider((ref) {
  final points = ref.watch(allActivePointsFutureProvider);
  final location = ref.watch(currentLocationProvider);
  return points.when(
    data: (pointList) => _filterByDistance(pointList, location),
    // ...
  );
});
```

## Backend: Supabase with RLS

### API Strategy

- **All API calls** use PostgREST (auto-generated REST API from PostgreSQL)
- **Authentication**: JWT in Authorization header (Supabase Auth)
- **Security**: Row Level Security (RLS) policies enforce access control at database level
- **Client-side defensive checks**: Mirror RLS policies in repository code for transparency

### Core Tables

| Table | Purpose | Key Fields |
|-------|---------|-----------|
| `auth.users` | Supabase managed | id, email, metadata |
| `profile` | User metadata | id (FK), username, bio |
| `points` | Location posts | id, user_id (FK), content, geom (PostGIS), maidenhead_6char, is_active |
| `likes` | Social interactions | point_id (FK), user_id (FK) |

### Geospatial Features

1. **PostGIS**: `geom` column stores POINT(lat, lon) in SRID 4326
2. **Maidenhead Locator**: 6-character grid square format for generalized location display (~800m precision)
3. **Client-Side Filtering**: 5km radius filtering done locally using Haversine formula (NOT PostGIS queries)

## Specialized Agents

Use these agents for domain-specific implementation:

| Agent | When to Use |
|-------|-------------|
| `state-management-architect` | Riverpod providers, StateNotifiers, use cases |
| `flutter-ui-builder` | UI screens from UX specs, widgets, layouts |
| `flutter-data-architect` | Data models, DTOs, JSON serialization |
| `backend-security-guard` | Supabase repositories, RLS enforcement |
| `location-spatial-utility` | Maidenhead calculation, Haversine distance, geolocation |
| `supabase-schema-architect` | Database schema design, migrations |
| `qa-testing-agent` | Test strategy, test implementation |

## Development Workflow

### For New Features

1. **Update Specifications** → Modify relevant `project_standards/` document
2. **Invoke Agent** → Use appropriate specialized agent for implementation
3. **Follow Patterns** → Reference architecture documents
4. **Test** → Validate against `testing_strategy.md` and `UX_user_flow.md`

### For Database Changes

1. Update `tuPoint_data_schema.md`
2. Use `/supabase-migration-assistant --create [migration-name]`
3. Update RLS policies in schema document
4. Run `/supabase-security-audit --rls`
5. Generate types if needed: `/supabase-type-generator`

### For State Management Changes

1. Review data flow in `architecture_and_state_management.md`
2. Determine appropriate Riverpod provider type
3. Use `state-management-architect` agent
4. Implement use cases in domain layer first
5. Wire into presentation layer via ConsumerWidget

## Key Architectural Decisions

1. **Specification-First Development**: All features begin with specification documents in `project_standards/`. Agents implement based on specs.

2. **Client-Side Geospatial Filtering**: Server returns all active points; client calculates Haversine distance locally (5km radius). Keeps logic testable and reduces server complexity.

3. **PostgREST + RLS Security Model**: No custom backend services. Security enforced by PostgreSQL RLS policies. Client code adds defensive checks that mirror RLS.

4. **Maidenhead Grid Locators**: Unique use of ham radio grid square system for approximate location display without revealing exact coordinates.

5. **Agent-Based Development**: Each architectural domain has a specialized agent that encapsulates deep expertise and ensures consistent implementation patterns.

## MVP Constraints

- **Single main loop**: Sign up → Drop Point → View Nearby Points
- **5km default radius** for feed display (not configurable in MVP)
- **Client-side filtering** only (no complex server-side spatial queries)
- **Basic profile**: username + optional bio only
- **No chat, moderation, or real-time features** in MVP

## Build-Measure-Learn Cycle

The MVP goal is to prove assumptions. Future analytics should measure:
- **Activation**: % users who drop a Point within 24 hours of sign-up
- **Retention**: Day 7 retention rate
- **Engagement**: Average Points Liked per session

## Important Notes

- **Always reference specification documents** in `project_standards/` before implementing features
- **Use agents proactively** - they embody best practices and architectural patterns
- **RLS policies are enforced server-side** but should be mirrored in client code for better error messages
- **All coordinates** use WGS84 (SRID 4326)
- **Client filters for 5km radius** - do not rely on PostGIS server-side spatial queries
- **Specifications are source of truth** - update specs before implementing features
- **See branching policy above** - always verify branch before making changes