# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

# 🚨 MANDATORY SESSION START CHECKLIST 🚨

**BEFORE reading any files or making ANY changes in a new session, you MUST:**

1. **Run**: `git branch --show-current`
2. **If output is `main`**:
   - ❌ STOP immediately - DO NOT proceed with ANY file operations
   - 💬 Ask user: "We're currently on the main branch. Should I create a feature branch for this work?"
   - ⏸️ Wait for explicit user response
3. **If user approves**:
   - Run: `git checkout -b feature/<descriptive-name>` or `fix/<descriptive-name>`
   - Confirm branch switch before proceeding
4. **Only then proceed** with requested work

**Session Start Triggers:**
- Start of ANY new conversation
- After `/reset` or `/compact` commands
- When user reopens Claude Code

**NO EXCEPTIONS. Even for "small" changes, test fixes, or "quick" edits.**

---

## 🔄 Session Start Protocol (MANDATORY)

**Every new session MUST begin with this pattern:**

**Example 1: Work Request**
```
User: "Let's fix the integration tests"

Assistant Response (CORRECT):
"I'll help fix the integration tests. Let me first check our git branch status..."
[Runs: git branch --show-current]
[If on main: Creates feature branch with user permission]
[Then proceeds with work]
```

**Example 2: Planning Request**
```
User: "Let's plan the next step"

Assistant Response (CORRECT):
"I'll help plan the next steps. First, let me verify our git branch..."
[Runs: git branch --show-current]
[If on main: Asks user about creating feature branch]
[Even for planning, check branch BEFORE any file reads]
```

---

## ⚠️ CRITICAL: Git Branching Policy

This policy is enforced by the SESSION START CHECKLIST above.

**This applies to:**
- All direct file operations (Write, Edit, NotebookEdit)
- All agent invocations that create/modify files
- All slash commands that generate files

**Exception**: Only commit to main with explicit user permission granted in the current session for that specific change.

### Commit Policy

**DO NOT auto-commit changes.** The user wants to review all changes before committing.

- Make file changes as requested
- Show diffs or summaries of changes
- Wait for user to either:
  - Manually commit using git commands, OR
  - Explicitly ask you to commit with specific message

---

## Project Overview

**tuPoint (tP.2)** is a specification-driven Flutter application for hyper-local, ephemeral social media where content disappears when users leave the area.

**Key Principle**: "Content disappears when you leave the area" - every feature must reinforce this hyper-local, ephemeral nature.

## Current Status

**Development Phase**: Phase 6.1 Complete (Authentication Flow) → Phase 6.2 Next (Main Feed Integration)

### What's Complete ✅

**Backend Infrastructure:**
- Local Supabase (PostgreSQL 17 + PostGIS)
- 4 database migrations (profile, points, likes tables)
- 10 RLS policies enforcing authorization
- Auth providers (Email/Password, Google OAuth, Apple Sign In)

**Domain Layer:**
- 10 entities (Profile, Point, Like, + 7 state models)
- 3 repository interfaces (IPointsRepository, IProfileRepository, ILikesRepository)
- 11 use cases (Profile: 3, Point: 3, Like: 3, + 2 helpers)
- 3 geospatial utilities (Maidenhead, Haversine, Distance Formatter)
- 7 domain exceptions

**Data Layer:**
- 3 Supabase repository implementations (~915 lines)
- PostGIS geometry handling (WKT/GeoJSON)
- RLS-aware error mapping

**State Management:**
- 5 notifiers (~2,500 lines): Auth, Profile, PointDrop, Feed, Like
- 27 Riverpod providers across 5 files
- Complete state models for all operations

**Services:**
- LocationService (GPS + permissions, 318 lines)

**UI (Phase 6.1 Complete):**
- AuthGateScreen with state-driven routing
- Email/password authentication flow
- ProfileCreationScreen for new users
- Theme v3.0 "BLUE DOMINANCE" applied

**Testing:**
- 394 passing + 2 skipped = 396 total tests
- Domain: 91 utility + 73 entity + 143 use case tests
- Widget: 21 tests
- Integration: 56 passing + 2 skipped tests
- Security: 27 tests

### Known Issues (Phase 6 Cleanup)

Address at end of Phase 6:
- ⚠️ **Theme Consistency** - Some fonts/sizes hardcoded instead of from theme/constants
- ⚠️ **Password Validation** - Should allow special characters (!, @, #, $, %, etc.)
- ⚠️ **In-Form Validation** - Email/password validation on input, not submit
- ⚠️ **Form State Persistence** - Prefill form after submission errors
- ⚠️ **Field Error Highlighting** - Visual indicators for invalid fields
- ⚠️ **Missing Logout** - No sign out button (must reset database)
- ⚠️ **Missing User Menu** - Need menu for logout and profile editing

### Next Steps

- **Phase 6.2** - Main Feed Integration (wire feedNotifier, location services, like/unlike)
- **Phase 6.3** - Point Creation Integration (GPS capture, Maidenhead, real API calls)
- **Phase 6.4** - Location Permission Flows (permission request UI and error states)
- **Phase 6.5** - Phase 6 Cleanup (address known issues above)
- **Phase 7+** - Real-Time Updates (Supabase Realtime)

## Project Structure

```
/Users/joemc3/tmp/tuPoint/
├── app/                          # Flutter application
│   ├── .env                      # Local Supabase credentials (gitignored)
│   ├── lib/
│   │   ├── core/
│   │   │   ├── config/          # Environment configuration
│   │   │   ├── constants/       # App-wide constants
│   │   │   ├── providers/       # 27 Riverpod providers (5 files)
│   │   │   ├── services/        # LocationService
│   │   │   └── theme/           # Material 3 theme v3.0
│   │   ├── presentation/
│   │   │   ├── notifiers/       # 5 state notifiers (~2,500 lines)
│   │   │   ├── screens/         # Auth, MainFeed, PointCreation, ProfileCreation
│   │   │   └── widgets/         # Reusable components (PointCard)
│   │   ├── domain/              # Business logic
│   │   │   ├── utils/           # Geospatial utilities (3)
│   │   │   ├── value_objects/   # LocationCoordinate
│   │   │   ├── entities/        # 10 domain entities
│   │   │   ├── exceptions/      # 7 exception classes
│   │   │   ├── repositories/    # 3 repository interfaces
│   │   │   └── use_cases/       # 11 use cases
│   │   └── data/                # Data layer
│   │       └── repositories/    # 3 Supabase implementations
│   └── test/                    # 396 tests
│       ├── helpers/             # SupabaseTestHelper
│       ├── widget/              # Widget tests
│       ├── domain/              # Domain layer tests
│       └── data/                # Integration tests
├── supabase/                     # Supabase configuration
│   ├── config.toml              # Auth providers, API settings
│   └── migrations/              # 4 SQL schema files
├── project_standards/            # Specifications (source of truth)
│   ├── architecture_and_state_management.md
│   ├── api_strategy.md
│   ├── AUTH_ARCHITECTURE.md
│   ├── STATE_MANAGEMENT_IMPLEMENTATION.md
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

# Run app
flutter run                                      # Default device
flutter run -d chrome                           # Web
flutter run -d macos                            # macOS

# Tests
flutter test                                     # All tests
flutter test test/path/to/test_file.dart        # Single test

# Build
flutter build apk                                # Android
flutter build web                                # Web

# Analysis
flutter analyze                                  # Static analysis
dart fix --apply                                 # Auto-fix lints
```

### Supabase Commands

```bash
# Start/Stop
supabase start                                   # Start Docker containers
supabase stop                                    # Stop containers

# Database
supabase db reset                                # Reset + reapply migrations
supabase migration new <name>                    # Create migration
supabase status                                  # View status
supabase logs -f                                 # View logs

# GUI
# Open http://127.0.0.1:54323 for Supabase Studio
```

**Custom slash commands:**
```bash
/supabase-migration-assistant --create           # Create migration
/supabase-schema-sync --pull                     # Pull schema
/supabase-type-generator --all-tables            # Generate types
/supabase-security-audit --comprehensive         # Security audit
/supabase-data-explorer --inspect                # Explore database
/createThemeTemplate [requirements]              # Generate theme
```

## Visual Design: Theme v3.0 "BLUE DOMINANCE"

**Location Blue (#3A9BFC) dominates every screen** - not a subtle accent, but the defining visual characteristic.

**Light Theme - "BLUE IMMERSION":**
- Background: `#D6EEFF` (obviously blue)
- Cards: `#F0F7FF` with 3dp solid blue borders
- Chips: `#99CCFF` (saturated blue)
- FAB: Location Blue with 24dp glow

**Dark Theme - "BLUE ELECTRIC":**
- Background: `#0F1A26` (blue-tinted dark)
- Cards: `#1A2836` with 2dp glowing borders + aura
- Primary: `#66B8FF` (electric blue)
- FAB: Dual-layer glow (24dp + 32dp)

**Design Principles:**
- 100% Theme Compliance (zero hardcoded values)
- Constants-Driven (AppConstants)
- WCAG 2.1 AA+ accessibility
- Material 3

**Key Files:**
- `project_standards/project-theme.md` - Spec
- `app/lib/core/theme/app_theme.dart` - Implementation
- `app/lib/core/constants/app_constants.dart` - Constants

## Architecture

### Three-Layer Clean Architecture

1. **Presentation** (`lib/presentation/`)
   - Flutter widgets, screens
   - Riverpod ConsumerWidgets
   - NO business logic in widgets

2. **Domain** (`lib/domain/`)
   - Entities, use cases, repository interfaces
   - Pure Dart (no Flutter dependencies)
   - Technology-agnostic

3. **Data** (`lib/data/`)
   - Supabase repository implementations
   - PostgREST integration
   - RLS-aware error handling

### State Management: Riverpod

**Provider Types:**

| Type | Purpose | Example |
|------|---------|---------|
| `Provider` | Read-only values | `pointsRepositoryProvider` |
| `StateNotifierProvider` | Mutable state | `authNotifierProvider` |
| `FutureProvider` | Async operations | `currentLocationProvider` |
| `StreamProvider` | Real-time data | `locationStreamProvider` |

**Data Flow:**
```dart
// Providers compose other providers
final nearbyPointsProvider = Provider((ref) {
  final points = ref.watch(allPointsProvider);
  final location = ref.watch(currentLocationProvider);
  return filterByDistance(points, location, 5000); // 5km
});
```

## Backend: Supabase with RLS

**API Strategy:**
- PostgREST (auto-generated REST from PostgreSQL)
- JWT authentication (Supabase Auth)
- RLS policies enforce access control at DB level
- Client-side defensive checks mirror RLS

**Core Tables:**

| Table | Purpose | Key Fields |
|-------|---------|-----------|
| `auth.users` | Supabase managed | id, email, metadata |
| `profile` | User metadata | id (FK), username, bio |
| `points` | Location posts | id, user_id, content, geom (PostGIS), maidenhead_6char |
| `likes` | Social interactions | point_id (FK), user_id (FK) |

**Geospatial:**
- PostGIS GEOMETRY(POINT, 4326) for lat/lon
- Maidenhead 6-char grid (~800m precision)
- Client-side 5km filtering (Haversine)

## Specialized Agents

| Agent | When to Use |
|-------|-------------|
| `state-management-architect` | Riverpod providers, StateNotifiers, use cases |
| `flutter-ui-builder` | UI screens from UX specs, widgets, layouts |
| `flutter-data-architect` | Data models, DTOs, JSON serialization |
| `backend-security-guard` | Supabase repositories, RLS enforcement |
| `location-spatial-utility` | Maidenhead, Haversine, geolocation |
| `supabase-schema-architect` | Database schema, migrations |
| `qa-testing-agent` | Test strategy, test implementation |

## Development Workflow

### New Features
1. Update relevant `project_standards/` document
2. Invoke appropriate specialized agent
3. Follow architecture patterns
4. Validate against specs

### Database Changes
1. Update `tuPoint_data_schema.md`
2. Create migration: `/supabase-migration-assistant --create`
3. Update RLS policies in schema doc
4. Run security audit: `/supabase-security-audit --rls`

### State Management Changes
1. Review `architecture_and_state_management.md`
2. Determine provider type
3. Use `state-management-architect` agent
4. Implement use cases first
5. Wire to presentation via ConsumerWidget

## Key Architectural Decisions

1. **Specification-First** - All features start with `project_standards/` docs
2. **Client-Side Geospatial** - 5km filtering via Haversine (not server-side PostGIS queries)
3. **RLS Security** - No custom backend; PostgreSQL RLS enforces access control
4. **Maidenhead Grids** - Ham radio locators for approximate location display
5. **Agent-Based Development** - Specialized agents ensure consistent patterns

## MVP Constraints

- Single main loop: Sign up → Drop Point → View Nearby
- 5km fixed radius (not configurable)
- Client-side filtering only
- Basic profile (username + bio)
- No chat, moderation, or real-time in MVP

## Important Notes

- **Always reference specifications** in `project_standards/` before implementing
- **Use agents proactively** - they embody best practices
- **RLS enforced server-side** but mirrored in client for better errors
- **All coordinates use WGS84** (SRID 4326)
- **Client filters 5km radius** - don't rely on PostGIS server queries
- **Specs are source of truth** - update before implementing
- **Check git branch** - see branching policy above
