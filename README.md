# tuPoint (tP.2)

**The anti-social media app where content disappears when you leave the area.**

## What is tuPoint?

tuPoint makes every post ("Point") an exclusive, in-the-moment local discovery. Drop a Point at your location, see what others have shared nearby, and watch content naturally fade as you move on. No algorithms, no endless feeds—just hyper-local, ephemeral moments.

## Product Vision

Every feature must reinforce this hyper-local, ephemeral nature. Content lives and dies by proximity.

## Current Status

**Development Phase**: Database Setup Complete → Domain Layer Complete → Data Layer Complete → **State Management COMPLETE** (Phase 5.1-5.4) → UI Integration Next

## Codebase Statistics

- **Total Dart Files**: 74 files (~16,000 lines of code, excluding generated files)
- **Screens**: 3 complete screens (Auth Gate, Main Feed, Point Creation)
- **Reusable Widgets**: 1 component (PointCard - fully tested)
- **Domain Layer**: 100% complete
  - **Entities**: 10 core models (Profile, Point, Like, AuthState, ProfileState, PointDropState, FeedState, LikeState, LocationPermissionState, LocationServiceState) with Freezed immutability
  - **Repository Interfaces**: 3 contracts (IPointsRepository, IProfileRepository, ILikesRepository)
  - **Use Cases**: 11 business logic classes
  - **Geospatial Utilities**: 3 utilities (Maidenhead, Haversine, Distance)
  - **Value Objects**: 1 type (LocationCoordinate)
  - **Exceptions**: 7 domain exception classes
- **Data Layer**: 100% complete
  - **Repository Implementations**: 3 Supabase repositories (~915 lines)
  - **RLS-Aware**: Defensive checks mirror database policies
  - **PostGIS Integration**: WKT/GeoJSON geometry handling
  - **Error Mapping**: PostgrestException → domain exceptions
- **State Management Layer**: 100% complete (Phase 5.1-5.4)
  - **Riverpod Providers**: 27 providers across 5 files (repository, auth, location, profile, point/feed/like)
  - **Core Services**: 1 (LocationService - 318 lines)
  - **State Notifiers**: 5 notifiers (~2,500 lines total)
    - AuthNotifier (346 lines) - Authentication
    - ProfileNotifier - Profile fetch/update
    - PointDropNotifier - Point creation with GPS
    - FeedNotifier - Nearby points filtering
    - LikeNotifier - Like/unlike with optimistic updates
  - **Authentication**: Email/password, Google OAuth, Apple Sign In support
  - **Location Services**: GPS permissions, one-time fetch, real-time streaming
- **Database**:
  - **Migrations**: 4 SQL schema files
  - **RLS Policies**: 10 security policies
- **Test Coverage**: 369 comprehensive tests (96.2% pass rate)
  - ✅ Domain Utilities: 91 tests
  - ✅ Domain Entities: 73 tests (Profile, Point, Like, LocationPermissionState, LocationServiceState)
  - ✅ Domain Use Cases: 126 tests
  - ✅ Widget Tests: 21 tests
  - ✅ Integration Tests: 58 tests (real database)
- **Documentation**: 9 specification documents in project_standards/ (including 73KB state management guide) + comprehensive AI agent system
- **Theme**: 2 polished variants (Light "BLUE IMMERSION", Dark "BLUE ELECTRIC")

### Phase 0-1: Database Foundation ✅ COMPLETE

The backend is now fully operational:
- ✅ **Local Supabase environment** running (PostgreSQL 17 + PostGIS)
- ✅ **Database schema migrated** - `profile`, `points`, `likes` tables
- ✅ **Row Level Security (RLS)** - 10 policies enforcing authorization (profile: 4, points: 3, likes: 3)
- ✅ **PostGIS spatial support** - GEOMETRY(POINT, 4326) for lat/lon
- ✅ **Auth providers configured** - Email/Password, Google OAuth, Apple Sign In
- ✅ **Environment setup** - `.env` and config files created

### UI Mockups ✅ COMPLETE

The frontend mockups demonstrate the design:
- ✅ **Complete UI mockups** demonstrating the full user flow
- ✅ **v3.0 "BLUE DOMINANCE" theme** - Location Blue aggressively featured throughout (fully implemented)
  - ✅ AppBar with blue gradient (documented for per-widget implementation)
  - ✅ Input fields with blue borders even when unfocused
  - ✅ Auth screen with bold gradient background
- ✅ **Material 3 design** with Inter typography and 100% theme compliance
- ✅ **Navigable screens**: Auth Gate → Main Feed (5 test Points) → Point Creation

### Phase 2.1: Domain Layer Foundation ✅ COMPLETE

The core geospatial utilities are now implemented:
- ✅ **All dependencies installed** - Riverpod, Supabase, Geolocator, Freezed, JSON serialization
- ✅ **LocationCoordinate value object** - Immutable lat/lon with validation
- ✅ **MaidenheadConverter utility** - Ham radio grid square system (~800m precision)
- ✅ **HaversineCalculator utility** - Great-circle distance calculation (<0.5% error)
- ✅ **DistanceFormatter utility** - Human-readable distance display ("X.X km")
- ✅ **Comprehensive test coverage** - 91 passing tests for all utilities

### Phase 3.1: Domain Entities ✅ COMPLETE

The domain entity layer is now implemented:
- ✅ **Profile entity** - Freezed immutable model with id, username, bio, timestamps (25 tests)
- ✅ **Point entity** - Freezed model with LocationCoordinate integration, PostGIS geometry converter (16 tests)
- ✅ **Like entity** - Freezed model representing composite key relationship (8 tests)
- ✅ **JSON serialization** - Snake_case to camelCase mapping for database compatibility
- ✅ **Entity test coverage** - 49 comprehensive tests for all entities

### Phase 3.2: Repository Interfaces ✅ COMPLETE

The domain repository contracts are now defined:
- ✅ **IPointsRepository** - Abstract contract for Point CRUD operations (6 methods)
- ✅ **IProfileRepository** - Abstract contract for Profile operations (5 methods)
- ✅ **ILikesRepository** - Abstract contract for Like operations (6 methods)
- ✅ **Domain exceptions** - 7 exception classes (UnauthorizedException, NotFoundException, ValidationException, etc.)
- ✅ **RLS-aware design** - Repository methods mirror database RLS policies
- ✅ **Technology-agnostic** - No Supabase imports, pure Dart interfaces

### Phase 3.3: Use Cases ✅ COMPLETE

🎉 **Domain Layer Complete!** The business logic layer is now fully implemented:

**Profile Use Cases:**
- ✅ **CreateProfileUseCase** - Create new user profile with username/bio validation (3-30 chars, alphanumeric + underscore only)
- ✅ **FetchProfileUseCase** - Fetch profile by ID or username

**Point Use Cases:**
- ✅ **DropPointUseCase** - Create new Point with content validation (1-280 chars), Maidenhead normalization
- ✅ **FetchNearbyPointsUseCase** - **CRITICAL MVP FEATURE** - Fetch points within 5km radius using HaversineCalculator, implements "content disappears when you leave the area", sorts by distance (nearest first)
- ✅ **FetchUserPointsUseCase** - Get all active points by user, sorted by creation date (newest first)

**Like Use Cases:**
- ✅ **LikePointUseCase** - Record a like on a point (validates IDs before calling repository)
- ✅ **UnlikePointUseCase** - Remove a like from a point (validates IDs before calling repository)
- ✅ **GetLikeCountUseCase** - Get like count for a point

**Supporting Infrastructure:**
- ✅ **UseCase base class** - Abstract generic class for all use cases: `UseCase<Success, Request>`
- ✅ **Request DTOs** - 8 strongly-typed request classes for all use cases (CreateProfileRequest, DropPointRequest, FetchNearbyPointsRequest, etc.)
- ✅ **Validation-first pattern** - All inputs validated before repository calls
- ✅ **Exception propagation** - Domain exceptions bubble up to presentation layer for proper error handling

### Phase 3.4: Testing & Documentation ✅ COMPLETE

**Comprehensive Audit Remediation (2025-11-12):**
- ✅ **Specification updates** - Username validation rules documented (3-30 chars, alphanumeric + underscore)
- ✅ **Theme v3.0 completion** - All missing features implemented (gradients, borders, auth screen)
- ✅ **Documentation accuracy** - RLS policy count corrected (10 not 12), test coverage clarified
- ✅ **Use case tests** - 126 comprehensive tests added (8 test files covering all business logic)
- ✅ **Widget tests** - 20 PointCard tests added (rendering, theming, interactions, edge cases)
- ✅ **Test coverage leap** - From 141 tests → 287 tests (+103% increase)
- ✅ **Pass rate** - 281/287 passing (97.9%)

**Domain layer is now battle-tested and ready for data layer implementation.**

### Phase 4: Data Layer ✅ COMPLETE

**Repository Implementations (2025-11-13):**
- ✅ **SupabaseProfileRepository** - Profile CRUD with RLS enforcement (5 methods, 274 lines, 23 tests)
- ✅ **SupabasePointsRepository** - Point CRUD with PostGIS geometry (6 methods, 335 lines, 19 tests)
- ✅ **SupabaseLikesRepository** - Like operations with composite keys (6 methods, 306 lines, 16 tests)
- ✅ **Integration tests** - 58 tests using real local Supabase database (not mocks)
- ✅ **RLS-aware design** - Defensive client checks mirror database RLS policies
- ✅ **Error mapping** - PostgrestException → domain exceptions (UnauthorizedException, NotFoundException, ValidationException, etc.)
- ✅ **PostGIS integration** - WKT format for writes, GeoJSON for reads, automatic conversion
- ✅ **Test helper** - SupabaseTestHelper for setup, cleanup, and test user management
- ✅ **Test coverage** - From 287 tests → 345 tests (+58 integration tests, +20% increase)
- ✅ **Pass rate** - 331/345 passing (96.0%)

**Data layer is now complete and ready for state management wiring.**

### Phase 5.1: Repository Providers ✅ COMPLETE

**Riverpod Infrastructure Setup (2025-11-13):**
- ✅ **Supabase initialization** - App-wide Supabase client setup in main.dart
- ✅ **ProviderScope** - Riverpod enabled for entire app
- ✅ **Repository providers** - 4 core infrastructure providers:
  - `supabaseClientProvider` - Singleton Supabase client access
  - `profileRepositoryProvider` - IProfileRepository implementation
  - `pointsRepositoryProvider` - IPointsRepository implementation
  - `likesRepositoryProvider` - ILikesRepository implementation

**Repository providers are ready for state notifier consumption.**

### Phase 5.2: Authentication State ✅ COMPLETE

**Authentication State Management (2025-11-13):**
- ✅ **AuthState model** - Freezed union type (Unauthenticated, Authenticated, Loading, Error) with profile completion tracking
- ✅ **AuthNotifier** - StateNotifier managing all auth operations (346 lines):
  - Email/password sign in and sign up
  - Google OAuth and Apple Sign In support
  - Automatic profile creation during signup
  - Session persistence via Supabase auth state stream
  - User-friendly error mapping (AuthException → readable messages)
- ✅ **Auth providers** - 6 Riverpod providers in `auth_providers.dart` (131 lines):
  - `authNotifierProvider` - Main authentication state notifier
  - `authStateProvider` - Convenience provider for current state
  - `currentUserIdProvider` - Extracts userId when authenticated
  - `hasProfileProvider` - Checks profile completion status
  - `createProfileUseCaseProvider` - Profile creation use case
  - `fetchProfileUseCaseProvider` - Profile fetching use case
- ✅ **Documentation** - Comprehensive usage guide (README.md) and architecture diagrams (AUTH_ARCHITECTURE.md)
- ✅ **Clean architecture** - Uses domain layer use cases, maintains proper separation

**Authentication foundation is complete with 721 lines of production code.**

### Phase 5.3: Location Services ✅ COMPLETE

**Location Services State Management (2025-11-13):**
- ✅ **LocationPermissionState model** - Freezed union type (notAsked, granted, denied, deniedForever, serviceDisabled)
- ✅ **LocationServiceState model** - Freezed union type (loading, available, permissionDenied, serviceDisabled, error)
- ✅ **LocationService class** - GPS and permission handling service (318 lines):
  - Check and request location permissions
  - One-time location fetch with 15s timeout
  - Real-time location stream with 10m distance filter
  - Platform settings access (openLocationSettings, openAppSettings)
  - High accuracy GPS positioning
  - Comprehensive error handling
- ✅ **Location providers** - 6 Riverpod providers in `location_providers.dart` (217 lines):
  - `locationServiceProvider` - LocationService instance
  - `locationPermissionProvider` - Current permission state
  - `currentLocationProvider` - FutureProvider for one-time location
  - `locationStreamProvider` - StreamProvider for real-time updates
  - `hasLocationPermissionProvider` - Boolean permission check
  - `locationServicesEnabledProvider` - GPS enabled check
- ✅ **Platform configuration** - iOS Info.plist and Android AndroidManifest.xml updated with location permissions
- ✅ **Test coverage** - 24 comprehensive tests for location state models (100% pass rate)
- ✅ **Documentation** - 3 comprehensive guides (LOCATION_SERVICES_README.md, LOCATION_QUICK_START.md, PHASE_5.3_LOCATION_SERVICES_SUMMARY.md)
- ✅ **Domain integration** - Returns LocationCoordinate value objects from domain layer

**Location services foundation is complete with 853 lines of production code (service + providers + state models).**

### Phase 5.4: Application State ✅ COMPLETE

**Profile/Point/Feed/Like State Management (2025-11-14):**
- ✅ **ProfileState model** - Freezed union type (initial, loading, loaded, error)
- ✅ **ProfileNotifier** - StateNotifier for profile fetch/update operations
- ✅ **UpdateProfileUseCase** - Profile update business logic with validation
- ✅ **Profile providers** - 4 Riverpod providers in `profile_providers.dart`
- ✅ **PointDropState model** - Freezed union type (initial, fetchingLocation, dropping, success, error)
- ✅ **PointDropNotifier** - StateNotifier for two-phase point creation (GPS → database)
- ✅ **FeedState model** - Freezed union type (initial, loading, loaded with location, error)
- ✅ **FeedNotifier** - StateNotifier for nearby points feed with 5km filtering
- ✅ **LikeState model** - Freezed data class for per-point like tracking
- ✅ **LikeNotifier** - StateNotifier for like/unlike with optimistic updates and rollback
- ✅ **Point providers** - 16 providers in `point_providers.dart` (use cases, notifiers, family providers)
- ✅ **Comprehensive documentation** - 73KB STATE_MANAGEMENT_IMPLEMENTATION.md reference guide

**State Management Summary:**
- **7 State Models**: AuthState, ProfileState, PointDropState, FeedState, LikeState, LocationPermissionState, LocationServiceState
- **5 Notifiers**: AuthNotifier, ProfileNotifier, PointDropNotifier, FeedNotifier, LikeNotifier (~2,500 lines)
- **27 Providers**: Across 5 provider files (repository, auth, location, profile, point/feed/like)
- **11 Use Cases**: All wired into state layer

**State management is now complete and ready for UI integration.**

### Next Phase: UI Integration & Testing 🚧

Ready to implement (Phase 6+):
- ❌ **UI Integration** - Wire state providers into Auth Gate, Main Feed, Point Creation screens
- ❌ **Permission flows** - Add location permission request UI
- ❌ **Testing** - Unit tests for notifiers, integration tests for providers
- ❌ **Real-time updates** - Integrate Supabase Realtime for auto-updating feed
- ❌ **Error display** - Implement user-friendly error messages throughout UI

**Quick Start:**
- Run `flutter run` in the `app/` directory to see the UI mockup
- Run `flutter test` to run all 369 tests (91 utils + 73 entities + 126 use cases + 21 widgets + 58 integration)
- Run `supabase start` to launch the local database environment

## Tech Stack

- **Frontend**: Flutter (iOS, Android, Web)
- **Backend**: Supabase (PostgreSQL 17 + PostGIS + Auth) ✅ *database running locally*
- **State Management**: Riverpod ✅ *providers wired, authentication state complete*
- **Architecture**: Clean Architecture (3-layer) ✅ *UI complete, domain layer complete, data layer complete, state management in progress*
- **Security**: Row Level Security (RLS) policies ✅ *10 policies enforced at database level*
- **Geospatial**: PostGIS storage ✅ *schema ready*, client-side Haversine filtering ✅ *utilities implemented & tested*

## Quick Start

### Prerequisites

- Flutter SDK 3.9.2+
- Dart 3.9.2+
- Docker Desktop (for local Supabase)
- Supabase CLI 2.58.5+

### Setup

```bash
# Clone repository
git clone <repository-url>
cd tuPoint

# Start local Supabase database
supabase start

# Install Flutter dependencies
cd app
flutter pub get

# Run Flutter app on device/emulator
flutter run
```

### Supabase Database

The local Supabase environment includes:
- **API URL**: `http://127.0.0.1:54321`
- **Studio (GUI)**: `http://127.0.0.1:54323`
- **Database**: PostgreSQL 17 with PostGIS extension
- **Migrations**: 4 schema files in `supabase/migrations/`

Credentials are stored in `app/.env` (gitignored). See `.env.example` for OAuth setup instructions.

See [CLAUDE.md](CLAUDE.md) for complete development guidance.

## Project Structure

```
├── app/                          # Flutter application
│   ├── .env                      # ✅ Local Supabase credentials (gitignored)
│   ├── lib/
│   │   ├── core/
│   │   │   ├── config/          # ✅ Environment configuration
│   │   │   ├── constants/       # ✅ App-wide constants (spacing, sizes, colors)
│   │   │   └── theme/           # ✅ Material 3 theme v3.0 (BLUE DOMINANCE)
│   │   ├── presentation/
│   │   │   ├── screens/         # ✅ Auth, MainFeed, PointCreation (mockups)
│   │   │   └── widgets/         # ✅ PointCard component
│   │   ├── domain/              # ✅ Domain layer (complete)
│   │   │   ├── utils/           # ✅ Geospatial utilities (Maidenhead, Haversine, Distance)
│   │   │   ├── value_objects/   # ✅ LocationCoordinate
│   │   │   ├── entities/        # ✅ Profile, Point, Like entities with Freezed
│   │   │   ├── exceptions/      # ✅ Domain exceptions (7 exception classes)
│   │   │   ├── repositories/    # ✅ Repository interfaces (IPointsRepository, IProfileRepository, ILikesRepository)
│   │   │   └── use_cases/       # ✅ 11 use cases (Profile, Point, Like operations)
│   │   │       ├── profile_use_cases/   # CreateProfileUseCase, FetchProfileUseCase, UpdateProfileUseCase
│   │   │       ├── point_use_cases/     # DropPointUseCase, FetchNearbyPointsUseCase, FetchUserPointsUseCase
│   │   │       ├── like_use_cases/      # LikePointUseCase, UnlikePointUseCase, GetLikeCountUseCase
│   │   │       ├── requests.dart        # 9 request DTOs
│   │   │       └── use_case_base.dart   # Abstract UseCase<Success, Request> base class
│   │   └── data/                # ✅ Data layer (Supabase implementations)
│   │       └── repositories/    # ✅ 3 repository implementations (~915 lines)
│   │           ├── supabase_profile_repository.dart
│   │           ├── supabase_points_repository.dart
│   │           └── supabase_likes_repository.dart
│   └── test/
│       ├── widget_test.dart     # ✅ Basic widget test (1 test)
│       ├── helpers/             # ✅ Test utilities
│       │   └── supabase_test_helper.dart
│       ├── widget/              # ✅ Widget tests (20 tests)
│       │   └── point_card_test.dart
│       ├── domain/              # ✅ Domain layer tests (266 tests)
│       │   ├── utils/           # ✅ Geospatial utility tests (91 tests)
│       │   ├── entities/        # ✅ Entity tests (49 tests)
│       │   └── use_cases/       # ✅ Use case tests (126 tests)
│       │       ├── profile_use_cases/
│       │       ├── point_use_cases/
│       │       └── like_use_cases/
│       └── data/                # ✅ Data layer integration tests (58 tests)
│           └── repositories/    # ✅ Repository integration tests (real database)
│               ├── supabase_profile_repository_integration_test.dart
│               ├── supabase_points_repository_integration_test.dart
│               └── supabase_likes_repository_integration_test.dart
├── supabase/                     # ✅ Supabase configuration
│   ├── config.toml              # ✅ Auth providers, API settings
│   └── migrations/              # ✅ Database schema (4 migrations)
├── project_standards/           # Architectural specifications (source of truth)
│   ├── architecture_and_state_management.md
│   ├── api_strategy.md
│   ├── AUTH_ARCHITECTURE.md
│   ├── STATE_MANAGEMENT_IMPLEMENTATION.md    # ✅ Complete state management guide (73KB)
│   ├── product_requirements_document(PRD).md
│   ├── tuPoint_data_schema.md
│   ├── UX_user_flow.md
│   ├── testing_strategy.md
│   └── project-theme.md         # ✅ v3.0 - Aggressive Location Blue usage
├── general_standards/           # Flutter/UX best practices
├── .claude/                     # AI agents and automation commands
└── .env.example                  # ✅ OAuth setup documentation
```

## Core Features (MVP)

- **Sign Up**: OAuth (Google, Apple) + Email/Password via Supabase Auth *(UI mockup + backend ready)*
- **Profile Creation**: Username + optional bio *(database schema ready)*
- **Drop a Point**: Create location-based posts with text content *(UI mockup + database schema ready)*
- **View Nearby Points**: See posts within 5km radius *(UI mockup with test data + database ready)*
- **Like Points**: Simple social interaction *(UI mockup + database schema ready)*

## Visual Design: Theme v3.0 "BLUE DOMINANCE"

The app uses an **aggressively bold theme** where Location Blue (#3A9BFC) is the dominant visual element. Blue is everywhere—backgrounds, borders, glows, dividers, and highlights.

### Key Design Features

- **Light Mode**: Obviously blue background (`#D6EEFF`), all cards have 3dp solid blue borders
- **Dark Mode**: Blue glows everywhere - 2dp borders with aura effects, brighter electric blue (`#66B8FF`)
- **FAB Glow**: Massive 24-32dp blue glow effects that command attention
- **Saturated Chips**: Maidenhead codes in bright blue (`#99CCFF`)
- **Blue Dividers**: 30-40% opacity blue lines between all cards
- **100% Theme Compliance**: Zero hardcoded colors, fonts, or sizes

See `project_standards/project-theme.md` for complete v3.0 specifications.

## Architectural Highlights

### Specification-Driven Development

This project follows a **specification-first approach**. All implementation decisions are documented in `project_standards/` before coding. Specifications include:

- Complete database schemas with RLS policies
- API contracts with request/response examples
- ASCII wireframes for all screens
- Riverpod provider hierarchies and data flows
- Testing strategies and security requirements

### Specialized AI Agents

The project uses 8 specialized Claude Code agents for implementation:

- `state-management-architect` - Riverpod providers, use cases
- `flutter-ui-builder` - UI widgets from UX specs
- `flutter-data-architect` - Data models, DTOs, serialization
- `backend-security-guard` - Supabase repositories, RLS enforcement
- `location-spatial-utility` - Maidenhead grids, Haversine distance
- `supabase-schema-architect` - Database design, migrations
- `qa-testing-agent` - Test implementation
- `theme-architect` - Visual design system

### Clean Architecture + Riverpod

Three-layer separation ensures testability and maintainability:

1. **Presentation**: Flutter widgets consume state via Riverpod providers
2. **Domain**: Pure business logic, use cases, entity models (no Flutter deps)
3. **Data**: Supabase integration, repository implementations

### Security: RLS-First

All data access is governed by PostgreSQL Row Level Security policies. The client adds defensive checks that mirror server-side RLS for better error transparency.

### Geospatial Design

tuPoint's unique location system combines server-side precision with client-side privacy:

- **PostGIS Storage**: Stores precise coordinates in `geom` POINT field (SRID 4326)
- **Maidenhead Grid Locators**: Ham radio 6-character grid squares (~800m precision) for approximate location display
  - Example: Boston @ 42.3601°N, 71.0589°W → "FN42li"
  - Prevents exact coordinate exposure while maintaining neighborhood-level accuracy
  - Implemented in `MaidenheadConverter` utility (bidirectional encoding/decoding)
- **Client-side Haversine Filtering**: Calculates great-circle distances locally
  - Filters Points within 5km radius of user location
  - <0.5% error for distances under 100km
  - Implemented in `HaversineCalculator` utility with bearing and destination methods
- **Human-Readable Distances**: Formats distances for UI display
  - "456 m" for distances under 1km
  - "1.2 km" for distances 1km and above
  - Implemented in `DistanceFormatter` utility with parsing support

**Status**: All geospatial utilities are implemented and tested (91 passing tests). Domain entities with LocationCoordinate integration complete (49 passing tests). Repository interfaces defined with RLS-aware contracts. All MVP use cases implemented with comprehensive validation (8 use cases). Domain layer is complete. Data layer implementations with Supabase are complete (3 repositories, 58 integration tests). Ready for state management wiring (Phase 5).

## Development Workflow

### Git Branching Policy ⚠️

**All changes must be made on feature branches, not directly on `main`.**

For each new work session:

1. **Create a feature branch**: `git checkout -b feature/<descriptive-name>`
2. **Make your changes** on the feature branch
3. **Review changes** before committing: `git diff`
4. **Commit** when ready (manually or via Claude)
5. **Push and create PR** for review before merging to main

**Exception**: Only commit directly to main with explicit approval for that specific change.

See [CLAUDE.md](CLAUDE.md) for complete branching policy details.

### Adding New Features

1. Update specification in `project_standards/`
2. Invoke appropriate AI agent from `.claude/agents/`
3. Implement following Clean Architecture patterns
4. Test against `testing_strategy.md` requirements

### Database Changes

Local Supabase commands:

```bash
supabase start                            # Start database services
supabase stop                             # Stop services
supabase db reset                         # Reset database (reapply migrations)
supabase migration new <name>             # Create new migration
supabase status                           # View service status
```

Open `http://127.0.0.1:54323` for Supabase Studio (visual database management).

Advanced operations via slash commands:

```bash
/supabase-migration-assistant --create [migration-name]
/supabase-security-audit --rls
/supabase-type-generator --all-tables
```

### Running Tests

```bash
cd app
flutter test                                    # All 345 tests
flutter test test/domain/                       # Domain layer tests (266 tests)
flutter test test/widget/                       # Widget tests (21 tests)
flutter test test/data/repositories/            # Integration tests (58 tests, requires running Supabase)
```

**Note**: Integration tests require local Supabase to be running (`supabase start`).

## Build-Measure-Learn Cycle

The MVP goal is to **prove assumptions** about user behavior. Future analytics should track:

- **Activation**: % of users who drop a Point within 24 hours of sign-up
- **Retention**: Day 7 retention rate
- **Engagement**: Average Points Liked per session

Beyond data, actively solicit feedback from early adopters—both active users and those who churn immediately. This feedback will inform the first major feature additions (e.g., chat, images, moderation).

## Contributing

This project is currently in early MVP development. See [CLAUDE.md](CLAUDE.md) for detailed architecture and development guidelines.

## License

[Add license information]