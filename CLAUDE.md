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

## Current Status

**Development Phase**: Database Setup Complete → Domain Layer Foundation Complete → Domain Entities Complete → Repository Interfaces Complete → Use Cases Next

### Completed (Phase 0-3.2): ✅

**Backend & Infrastructure:**
- ✅ **Local Supabase Environment** - Docker containers running with PostgreSQL 17 + PostGIS
- ✅ **Database Schema** - 4 migrations applied (profile, points, likes tables)
- ✅ **Row Level Security (RLS)** - 12 policies enforcing authorization at database level
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

**Domain Layer Repository Interfaces (NEW - Phase 3.2):**
- ✅ **IPointsRepository** - Abstract contract for Point CRUD operations (6 methods)
- ✅ **IProfileRepository** - Abstract contract for Profile operations (5 methods)
- ✅ **ILikesRepository** - Abstract contract for Like operations (6 methods)
- ✅ **Domain Exceptions** - 7 exception classes (UnauthorizedException, NotFoundException, ValidationException, etc.)
- ✅ **RLS-Aware Design** - Repository methods mirror database RLS policies
- ✅ **Technology-Agnostic** - No Supabase imports, pure Dart interfaces
- ✅ **Total Test Coverage** - 141 passing tests (91 utils + 49 entities + 1 widget)

### Not Yet Implemented: ❌
- ❌ **Domain Layer Use Cases** (business logic: DropPoint, ToggleLike, etc.)
- ❌ **Data Layer** (Supabase repository implementations, DTOs)
- ❌ **State Management** (Riverpod providers not yet integrated)
- ❌ **Business Logic Wiring** (buttons skip to next screen, no data persistence)
- ❌ **API Integration** (Supabase client not wired to UI)
- ❌ **Real Authentication** (OAuth buttons navigate directly to feed)
- ❌ **Location Services Integration** (GPS permission handling, real-time location)

**Next Phase**: Use Cases (Phase 3.3), then Data Layer (Phase 4), then State Management (Phase 5)

## Project Structure

```
/Users/joemc3/tmp/tuPoint/
├── app/                          # Flutter application
│   ├── .env                      # Local Supabase credentials (gitignored)
│   ├── lib/
│   │   ├── core/
│   │   │   ├── config/          # Environment configuration
│   │   │   ├── constants/       # App-wide constants (spacing, sizes, colors)
│   │   │   └── theme/           # Material 3 theme v3.0 (BLUE DOMINANCE)
│   │   ├── presentation/
│   │   │   ├── screens/         # Auth, MainFeed, PointCreation screens
│   │   │   └── widgets/         # Reusable PointCard component
│   │   ├── domain/              # Domain layer (business logic)
│   │   │   ├── utils/           # Geospatial calculation utilities ✅
│   │   │   │   ├── maidenhead_converter.dart
│   │   │   │   ├── haversine_calculator.dart
│   │   │   │   └── distance_formatter.dart
│   │   │   ├── value_objects/   # Immutable value objects ✅
│   │   │   │   └── location_coordinate.dart
│   │   │   ├── entities/        # Domain entities with Freezed ✅
│   │   │   │   ├── profile.dart (+ .freezed.dart, .g.dart)
│   │   │   │   ├── point.dart (+ .freezed.dart, .g.dart)
│   │   │   │   └── like.dart (+ .freezed.dart, .g.dart)
│   │   │   ├── exceptions/      # Domain exceptions ✅
│   │   │   │   └── repository_exceptions.dart
│   │   │   ├── repositories/    # Repository interfaces ✅
│   │   │   │   ├── i_points_repository.dart
│   │   │   │   ├── i_profile_repository.dart
│   │   │   │   └── i_likes_repository.dart
│   │   │   └── use_cases/       # (Not yet implemented)
│   │   └── data/                # (Not yet implemented)
│   └── test/
│       ├── widget_test.dart     # Basic widget test (1 test)
│       └── domain/              # Domain layer tests ✅
│           ├── utils/           # Geospatial utility tests (91 tests)
│           └── entities/        # Entity tests (49 tests)
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