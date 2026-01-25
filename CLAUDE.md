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

### Colors (Warm, Empowering)

```dart
// Primary
const Color(0xFF8B5CF6)         // Primary purple (same as FoodPilot)
const Color(0xFFEC4899)         // Accent pink/magenta
const Color(0xFFF59E0B)         // Gold for achievements

// Backgrounds (Light)
Colors.white                    // Card background
const Color(0xFFF3F4F6)         // gray-100 - Secondary

// Backgrounds (Dark)
const Color(0xFF1F2937)         // Card background (gray-800)
const Color(0xFF374151)         // gray-700 - Secondary
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
