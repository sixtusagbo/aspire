# CLAUDE.md

Guidance for Claude Code when working with this Flutter/Dart codebase.

## Project Context

Aspire is a hackathon entry for RevenueCat's Shipyard 2026 contest, building for Gabby Beckford (@PacksLight).

**Deadline:** February 12, 2026

**Target:** Android only (for now)

**Related Project:** FoodPilot (~/projects/foodpilot) - we borrow patterns and code from there.

## Build Commands

```bash
flutter pub get                                          # Install dependencies
dart run build_runner build --delete-conflicting-outputs # Code generation
dart run build_runner watch --delete-conflicting-outputs # Watch mode
flutter analyze                                          # Analyze code
flutter test                                             # Run tests
```

**Note:** Don't run `flutter build` or `flutter run` - the user runs the app themselves.

## Firebase Deploy Commands

Use the Makefile for deploying Firebase resources:

```bash
make deploy-firestore  # Deploy Firestore rules + indexes
make deploy-rules      # Deploy Firestore rules only
make deploy-indexes    # Deploy Firestore indexes only
make deploy-all        # Deploy everything
```

**Important:** When adding new queries or collections, update `firestore.rules` and `firestore.indexes.json`, then run `make deploy-firestore`.

## MCP Tools (dart-mcp-server)

Use MCP tools for Dart/Flutter operations instead of shell commands:

- `mcp__dart-mcp-server__analyze_files` - Analyze code for errors
- `mcp__dart-mcp-server__run_tests` - Run tests (use instead of `flutter test`)
- `mcp__dart-mcp-server__dart_fix` - Apply dart fixes
- `mcp__dart-mcp-server__dart_format` - Format code
- `mcp__dart-mcp-server__pub` - Run pub commands (get, add, remove, etc.)
- `mcp__dart-mcp-server__pub_dev_search` - Search pub.dev for packages
- `mcp__dart-mcp-server__hover` - Get hover info at cursor position
- `mcp__dart-mcp-server__resolve_workspace_symbol` - Look up symbols by name

## Planning & Development

- Development plan is in `docs/MVP.md`
- Track progress by checking off items in the plan
- Each phase should be testable before moving on
- Time is critical - 19 days total
- **Atomic commits** - commit frequently as we go, not at the end

## Core Principles

- Follow **SOLID principles** and [Effective Dart](https://dart.dev/effective-dart) guidelines
- Prioritize **immutability** - prefer `final` variables and immutable data structures
- Favor **composition over inheritance**
- Write **concise, declarative code** with clear intent
- **DRY Principle**: Extract common widgets with parameters rather than duplicating code
- **Borrow from FoodPilot** wherever possible to save time

## Dart Style

### Naming Conventions

| Element                          | Convention | Example                        |
| -------------------------------- | ---------- | ------------------------------ |
| Classes, enums, typedefs         | PascalCase | `GoalService`, `GoalCategory`  |
| Variables, functions, parameters | camelCase  | `goalCount`, `fetchUserData()` |
| Files and directories            | snake_case | `goal_detail_screen.dart`      |
| Constants                        | camelCase  | `defaultPadding`               |
| Private members                  | prefix `_` | `_internalState`               |

### Formatting

- **Line length**: 80 characters maximum
- Run `dart format` before committing
- Use trailing commas for multi-line parameter lists

### Null Safety

- Use null safety soundly - avoid `!` unless certain
- Prefer `?.` and `??` operators for null handling
- Use `late` only when initialization is guaranteed

## Architecture

### State Management: Riverpod + Flutter Hooks

- Providers use `@riverpod` annotations → generated `*.g.dart` files
- Widgets use `HookConsumerWidget`

### Data Serialization: dart_mappable

Models use `@MappableClass()` → generated `*.mapper.dart` files.

### Firebase Backend

- **Auth**: Email/password + Google Sign-In via `AuthService`
- **Firestore**: `users`, `goals`, `micro_actions`, `daily_logs`

### Monetization: RevenueCat

- Required for hackathon
- Free tier: 1 active goal
- Premium: Unlimited goals

### Routing: GoRouter

Routes in `lib/core/utils/app_router.dart`.

## Project Structure

```
lib/
├── core/
│   ├── theme/      # App theme
│   ├── utils/      # App router, helpers
│   ├── widgets/    # Shared widgets
│   └── providers/  # Global providers
├── features/
│   └── [feature]/
│       ├── [screen].dart
│       └── widgets/
├── models/         # Data models
├── services/       # Firebase, notifications, etc.
└── data/           # Static data
```

## Code Style

### Widgets

- **No function widgets** - always use widget classes
- Use **private widget classes**: `class _Header extends StatelessWidget`
- Use **const constructors** wherever possible

### Performance

- Use `ListView.builder` for long lists
- Apply `const` to widgets that don't depend on runtime values

### File Size Limits

- UI files: **200-250 lines max** (use `part`/`part of` to split)
- Functions: **20-50 lines max**

## Design System

### Theme: Inspired by packslight.com (Gabby's website)

```dart
// Primary (Pink/Magenta)
const Color(0xFFDB4291)         // Primary pink
const Color(0xFFFF6D99)         // Secondary hot pink

// Secondary (Cyan/Teal)
const Color(0xFF6EC1E4)         // Cyan accent
const Color(0xFF00C1CF)         // Deeper teal

// Achievement
const Color(0xFFBFA35A)         // Gold for achievements
const Color(0xFFDDC995)         // Lighter gold
```

### Celebrations

- **Confetti**: Use `confetti` package
- **Haptics**: Use `HapticFeedback` on completions
- Small burst on task completion
- Big celebration on streaks and goal completion

## Testing

Follow **Arrange-Act-Assert** pattern. Mock Firebase dependencies.

## Accessibility

- Add `Semantics` widgets for screen readers
- Check `MediaQuery.of(context).disableAnimations`
- Maintain contrast ratios
