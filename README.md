# tuPoint (tP.2)

**The anti-social media app where content disappears when you leave the area.**

## What is tuPoint?

tuPoint makes every post ("Point") an exclusive, in-the-moment local discovery. Drop a Point at your location, see what others have shared nearby, and watch content naturally fade as you move on. No algorithms, no endless feeds—just hyper-local, ephemeral moments.

## Product Vision

Every feature must reinforce this hyper-local, ephemeral nature. Content lives and dies by proximity.

## Current Status

**Development Phase**: Database Setup Complete → Domain Layer Next

### Phase 0-1: Database Foundation ✅ COMPLETE

The backend is now fully operational:
- ✅ **Local Supabase environment** running (PostgreSQL 17 + PostGIS)
- ✅ **Database schema migrated** - `profile`, `points`, `likes` tables
- ✅ **Row Level Security (RLS)** - 12 policies enforcing authorization
- ✅ **PostGIS spatial support** - GEOMETRY(POINT, 4326) for lat/lon
- ✅ **Auth providers configured** - Email/Password, Google OAuth, Apple Sign In
- ✅ **Environment setup** - `.env` and config files created

### UI Mockups ✅ COMPLETE

The frontend mockups demonstrate the design:
- ✅ **Complete UI mockups** demonstrating the full user flow
- ✅ **v3.0 "BLUE DOMINANCE" theme** - Location Blue aggressively featured throughout
- ✅ **Material 3 design** with Inter typography and 100% theme compliance
- ✅ **Navigable screens**: Auth Gate → Main Feed (5 test Points) → Point Creation

### Next Phase: Domain Layer ⏭️

Ready to implement:
- ❌ **Domain entities** - Point, Profile, Like, Location models with Freezed
- ❌ **Repository interfaces** - Abstract contracts for data access
- ❌ **Use cases** - DropPoint, GetNearbyPoints, ToggleLike, CreateProfile
- ❌ **Geospatial utilities** - Maidenhead calculator, Haversine distance
- ❌ **Data layer** - Supabase repository implementations, DTOs
- ❌ **State management** - Riverpod providers wiring it all together
- ❌ **Business logic integration** - Connect backend to UI mockups

**Quick Start:**
- Run `flutter run` in the `app/` directory to see the UI mockup
- Run `supabase start` to launch the local database environment

## Tech Stack

- **Frontend**: Flutter (iOS, Android, Web)
- **Backend**: Supabase (PostgreSQL 17 + PostGIS + Auth) ✅ *database running locally*
- **State Management**: Riverpod *(planned, not yet implemented)*
- **Architecture**: Clean Architecture (3-layer) *(UI complete, domain/data pending)*
- **Security**: Row Level Security (RLS) policies ✅ *12 policies enforced at database level*
- **Geospatial**: PostGIS storage ✅ *schema ready*, client-side Haversine filtering *(pending)*

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
│   │   ├── domain/              # ❌ Not yet implemented
│   │   └── data/                # ❌ Not yet implemented
│   └── test/                    # ✅ Basic widget tests
├── supabase/                     # ✅ Supabase configuration
│   ├── config.toml              # ✅ Auth providers, API settings
│   └── migrations/              # ✅ Database schema (4 migrations)
├── project_standards/           # Architectural specifications (source of truth)
│   ├── architecture_and_state_management.md
│   ├── api_strategy.md
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

- **PostGIS** stores precise coordinates (`geom` POINT field)
- **Maidenhead Locator** provides ~800m precision for public display (6-char grid square)
- **Client-side filtering** calculates Haversine distance locally (5km radius)

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
flutter test                                    # All tests
flutter test test/unit/                        # Unit tests only
flutter test test/widget/                      # Widget tests only
flutter test test/integration/                 # Integration tests
```

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