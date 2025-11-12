# tuPoint (tP.2)

**The anti-social media app where content disappears when you leave the area.**

## What is tuPoint?

tuPoint makes every post ("Point") an exclusive, in-the-moment local discovery. Drop a Point at your location, see what others have shared nearby, and watch content naturally fade as you move on. No algorithms, no endless feeds—just hyper-local, ephemeral moments.

## Product Vision

Every feature must reinforce this hyper-local, ephemeral nature. Content lives and dies by proximity.

## Current Status

**Development Phase**: UI Mockup with Test Data

The app currently features:
- ✅ **Complete UI mockups** demonstrating the full user flow
- ✅ **v3.0 "BLUE DOMINANCE" theme** - Location Blue aggressively featured throughout
- ✅ **Material 3 design** with Inter typography and 100% theme compliance
- ✅ **Navigable screens**: Auth Gate → Main Feed (5 test Points) → Point Creation
- ❌ **No business logic yet** - buttons skip actions and navigate to next screen
- ❌ **No API integration** - all data is hardcoded for demonstration
- ❌ **No state management** - Riverpod not yet implemented

**Current Branch**: `feature/ui-mockups-with-test-data`

Run `flutter run` in the `app/` directory to see the mockup in action!

## Tech Stack

- **Frontend**: Flutter (iOS, Android, Web)
- **Backend**: Supabase (PostgreSQL + PostGIS + Auth) *(not yet integrated)*
- **State Management**: Riverpod *(planned, not yet implemented)*
- **Architecture**: Clean Architecture (3-layer) *(UI layer complete, domain/data pending)*
- **Security**: Row Level Security (RLS) policies *(specification complete, implementation pending)*
- **Geospatial**: PostGIS storage, client-side Haversine filtering (5km radius) *(pending)*

## Quick Start

### Prerequisites

- Flutter SDK 3.9.2+
- Dart 3.9.2+
- Supabase account (for backend)

### Setup

```bash
# Clone repository
git clone <repository-url>
cd tuPoint

# Install Flutter dependencies
cd app
flutter pub get

# Run on device/emulator
flutter run
```

See [SETUP.md](SETUP.md) for detailed setup instructions.

See [CLAUDE.md](CLAUDE.md) for complete development guidance.

## Project Structure

```
├── app/                          # Flutter application
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/       # ✅ App-wide constants (spacing, sizes, colors)
│   │   │   └── theme/           # ✅ Material 3 theme v3.0 (BLUE DOMINANCE)
│   │   ├── presentation/
│   │   │   ├── screens/         # ✅ Auth, MainFeed, PointCreation (mockups)
│   │   │   └── widgets/         # ✅ PointCard component
│   │   ├── domain/              # ❌ Not yet implemented
│   │   └── data/                # ❌ Not yet implemented
│   └── test/                    # ✅ Basic widget tests
├── project_standards/           # Architectural specifications (source of truth)
│   ├── architecture_and_state_management.md
│   ├── api_strategy.md
│   ├── product_requirements_document(PRD).md
│   ├── tuPoint_data_schema.md
│   ├── UX_user_flow.md
│   ├── testing_strategy.md
│   └── project-theme.md         # ✅ v3.0 - Aggressive Location Blue usage
├── general_standards/           # Flutter/UX best practices
└── .claude/                     # AI agents and automation commands
```

## Core Features (MVP)

- **Sign Up**: OAuth (Google, Apple) via Supabase Auth *(mockup only)*
- **Drop a Point**: Create location-based posts with text content *(mockup only)*
- **View Nearby Points**: See posts within 5km radius *(mockup with test data)*
- **Like Points**: Simple social interaction *(mockup with visual toggle)*
- **Profile Creation**: Username + optional bio *(not in mockup flow)*

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