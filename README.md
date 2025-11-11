# tuPoint (tP.2)

**The anti-social media app where content disappears when you leave the area.**

## What is tuPoint?

tuPoint makes every post ("Point") an exclusive, in-the-moment local discovery. Drop a Point at your location, see what others have shared nearby, and watch content naturally fade as you move on. No algorithms, no endless feeds—just hyper-local, ephemeral moments.

## Product Vision

Every feature must reinforce this hyper-local, ephemeral nature. Content lives and dies by proximity.

## Tech Stack

- **Frontend**: Flutter (iOS, Android, Web)
- **Backend**: Supabase (PostgreSQL + PostGIS + Auth)
- **State Management**: Riverpod
- **Architecture**: Clean Architecture (3-layer)
- **Security**: Row Level Security (RLS) policies
- **Geospatial**: PostGIS storage, client-side Haversine filtering (5km radius)

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
│   │   ├── presentation/        # UI widgets, screens, view models
│   │   ├── domain/              # Business logic, entities, use cases
│   │   └── data/                # Supabase integration, repositories
│   └── test/                    # Unit, widget, integration tests
├── project_standards/           # Architectural specifications (source of truth)
│   ├── architecture_and_state_management.md
│   ├── api_strategy.md
│   ├── product_requirements_document(PRD).md
│   ├── tuPoint_data_schema.md
│   ├── UX_user_flow.md
│   ├── testing_strategy.md
│   └── project-theme.md
├── general_standards/           # Flutter/UX best practices
└── .claude/                     # AI agents and automation commands
```

## Core Features (MVP)

- **Sign Up**: OAuth (Google, Apple) via Supabase Auth
- **Drop a Point**: Create location-based posts with text content
- **View Nearby Points**: See posts within 5km radius
- **Like Points**: Simple social interaction
- **Profile Creation**: Username + optional bio

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