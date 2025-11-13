# tuPoint Flutter App

This is the Flutter application for **tuPoint (tP.2)** - hyper-local, ephemeral social media where content disappears when you leave the area.

## Quick Start

```bash
# Install dependencies
flutter pub get

# Generate Freezed code (required for first run)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on device/emulator
flutter run

# Run tests
flutter test
```

## Project Structure

```
lib/
├── core/
│   ├── config/          # Environment configuration
│   ├── constants/       # App-wide constants
│   ├── providers/       # Riverpod providers ✅
│   └── theme/           # Material 3 theme (v3.0 "BLUE DOMINANCE")
├── presentation/
│   ├── screens/         # Auth Gate, Main Feed, Point Creation
│   └── widgets/         # Reusable components (PointCard)
├── domain/              # Business logic layer (pure Dart) ✅
│   ├── entities/        # Profile, Point, Like
│   ├── repositories/    # Repository interfaces
│   ├── use_cases/       # Business logic (8 use cases)
│   ├── utils/           # Geospatial utilities
│   ├── value_objects/   # LocationCoordinate
│   └── exceptions/      # Domain exceptions
└── data/                # Data layer ✅
    └── repositories/    # Supabase implementations

test/
├── domain/
│   ├── utils/           # 91 tests
│   ├── entities/        # 49 tests
│   └── use_cases/       # 126 tests
├── data/
│   └── repositories/    # 58 integration tests
└── widget/              # 21 tests
```

## Current Status

**Phase 5.1 In Progress**: State Management Infrastructure
- ✅ **Phase 4 Complete** - Data layer with Supabase repository implementations
- ✅ **Phase 5.1 Complete** - Repository providers and Riverpod initialization
- ✅ 345 comprehensive tests (96.0% pass rate)
  - Domain: 266 tests (utilities, entities, use cases)
  - Data: 58 integration tests
  - Widget: 21 tests
- ✅ 3 Supabase repository implementations (~915 lines)
- ✅ 4 Riverpod providers (Supabase client + 3 repositories)

**Next**: Phase 5.2 - Authentication state management (AuthNotifier, authProvider)

## Development

### Running Tests

```bash
# All tests
flutter test

# Domain tests only
flutter test test/domain/

# Widget tests only
flutter test test/widget/

# Specific test file
flutter test test/domain/use_cases/point_use_cases/fetch_nearby_points_use_case_test.dart
```

### Code Generation

When you modify Freezed entities or add JSON serialization:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Theme

The app uses Material 3 with an aggressive "BLUE DOMINANCE" theme where Location Blue (#3A9BFC) is featured throughout. See `lib/core/theme/app_theme.dart`.

## Documentation

For complete development guidance, see:
- [CLAUDE.md](../CLAUDE.md) - Development guidelines for AI assistance
- [README.md](../README.md) - Project overview and architecture
- [project_standards/](../project_standards/) - Comprehensive specifications

## Tech Stack

- Flutter 3.9.2+
- Riverpod (state management - repository providers wired, auth/UI pending)
- Freezed (immutable entities)
- Supabase (backend integration - repositories implemented)
- PostGIS (geospatial features)

## Architecture

Three-layer Clean Architecture:
1. **Presentation** - Flutter widgets, screens (UI mockups complete, state wiring pending)
2. **Domain** - Business logic, entities, use cases (✅ 100% complete)
3. **Data** - Repository implementations (✅ 100% complete)

**State Management**: Riverpod
- ✅ Repository providers configured
- 🔄 Authentication state (next)
- ⏳ Location services
- ⏳ Feature state (profile, points, likes)

See [architecture_and_state_management.md](../project_standards/architecture_and_state_management.md) for details.
