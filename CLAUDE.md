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

## Project Overview

**tuPoint (tP.2)** is a specification-driven Flutter application for hyper-local, ephemeral social media where content disappears when users leave the area. The project uniquely combines detailed specification documents with specialized AI agents for implementation.

**Key Principle**: "Content disappears when you leave the area" - every feature must reinforce this hyper-local, ephemeral nature.

## Project Structure

```
/Users/joemc3/tmp/tuPoint/
├── app/                          # Flutter application (minimal scaffold currently)
├── project_standards/            # Detailed specifications (source of truth)
│   ├── architecture_and_state_management.md
│   ├── api_strategy.md
│   ├── product_requirements_document(PRD).md
│   ├── tuPoint_data_schema.md
│   ├── UX_user_flow.md
│   ├── testing_strategy.md
│   └── project-theme.md
├── general_standards/            # Flutter/UX best practices
└── .claude/                      # Agents and commands
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

Use the custom slash commands for database operations:

```bash
/supabase-migration-assistant --create    # Create migration
/supabase-schema-sync --pull             # Pull schema from Supabase
/supabase-type-generator --all-tables    # Generate TypeScript types
/supabase-security-audit --comprehensive  # Run security audit
/supabase-data-explorer --inspect        # Explore database
```

### Theme Generation

```bash
/createThemeTemplate [requirements]       # Generate theme specification
```

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