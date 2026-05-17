# Forma — Coding Style Guide

> Consistency is the only style that matters at scale.

---

## 1. Dart Style Baseline

Follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style) plus these Forma-specific rules.

Enable all rules in `analysis_options.yaml`:
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  errors:
    missing_required_param: error
    missing_return: error
    dead_code: warning

linter:
  rules:
    - always_declare_return_types
    - always_put_required_named_parameters_first
    - avoid_dynamic_calls
    - avoid_print           # use logger instead
    - cancel_subscriptions
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - sort_constructors_first
    - use_super_parameters
```

---

## 2. Naming Conventions

### Files
- All lowercase, underscore-separated: `habit_repository_impl.dart`
- Feature screens: `{feature}_screen.dart` — `add_habit_screen.dart`
- Widget files: noun-first — `habit_row.dart`, `progress_ring.dart`
- Provider files: `{noun}_provider.dart` — `habits_provider.dart`
- Use-case files: verb-first — `complete_habit.dart`, `get_habits_for_date.dart`

### Classes
```dart
// Entities — plain nouns
class Habit { ... }
class HabitLog { ... }

// Models (Hive) — Model suffix
class HabitModel extends HiveObject { ... }

// Repositories — interface is noun, impl adds Impl
abstract class HabitRepository { ... }
class HabitRepositoryImpl implements HabitRepository { ... }

// Use-cases — callable classes, verb phrase
class CompleteHabit {
  const CompleteHabit(this._repository);
  Future<void> call({required String habitId, required DateTime date}) { ... }
}

// Riverpod providers — lowercase camelCase, descriptive
@riverpod
Future<List<Habit>> habitsForDate(HabitsForDateRef ref, DateTime date) { ... }

// Screens — PascalCase, Screen suffix
class HomeScreen extends ConsumerWidget { ... }

// Widgets — PascalCase, no suffix unless it's a layout wrapper
class HabitRow extends StatelessWidget { ... }
class HabitRowSkeleton extends StatelessWidget { ... }   // skeleton variant
```

### Variables & parameters
```dart
// Good
final completedHabits = habits.where((h) => h.isCompletedToday).toList();
final DateTime selectedDate;

// Bad — abbreviations and noise
final compHbts = ...;
final DateTime dt;
final String habitNameString;  // "String" is redundant
```

---

## 3. Widget Structure

Every widget follows this exact order:

```dart
class HabitRow extends ConsumerWidget {        // 1. class declaration

  // 2. Constructor — const where possible
  const HabitRow({
    super.key,
    required this.habit,
    this.onComplete,
  });

  // 3. Properties — final, required first
  final Habit habit;
  final VoidCallback? onComplete;

  // 4. build() — only method in StatelessWidget
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 5. Local derived values — top of build, no logic in widget tree
    final isCompleted = habit.isCompletedToday;
    final streakLabel = habit.streak > 0 ? '${habit.streak}d streak' : 'Start today';

    // 6. Return — clean, readable tree
    return GestureDetector(
      onTap: onComplete,
      child: Container(
        // ...
      ),
    );
  }
}
```

**Rules:**
- No business logic in `build()`. No `if/else` computing values inline in the widget tree — derive them above the `return`.
- Max ~80 lines per widget's `build()`. Extract sub-widgets if longer.
- Never pass `BuildContext` across async gaps without checking `mounted`.

---

## 4. Provider Rules

```dart
// ✅ Good — code-gen provider, typed, descriptive name
@riverpod
Future<List<Habit>> habitsForDate(HabitsForDateRef ref, DateTime date) async {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.getHabitsForDate(date);
}

// ✅ Good — NotifierProvider for mutable state
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  void select(DateTime date) => state = date;
}

// ❌ Bad — manual StateProvider, magic string key
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
```

**Rules:**
- Always use `riverpod_generator` (`@riverpod` annotation). No manual providers.
- Providers are in `features/{feature}/presentation/providers/`.
- Repository providers live in `features/{feature}/data/repositories/` and are exposed via `{name}RepositoryProvider`.
- Never call `ref.read` inside `build()`. Use `ref.watch`.
- `ref.read` is only for event handlers (`onTap`, `onSubmit`).

---

## 5. Repository Pattern

```dart
// domain/repositories/habit_repository.dart
abstract class HabitRepository {
  Future<List<Habit>> getAll();
  Future<List<Habit>> getHabitsForDate(DateTime date);
  Future<void> save(Habit habit);
  Future<void> delete(String id);
  Future<void> reorder(List<String> orderedIds);
}

// data/repositories/habit_repository_impl.dart
class HabitRepositoryImpl implements HabitRepository {
  const HabitRepositoryImpl(this._box);
  final Box<HabitModel> _box;

  @override
  Future<List<Habit>> getAll() async {
    return _box.values.map((m) => m.toEntity()).toList();
  }
  // ...
}
```

**Rules:**
- Repository interface in `domain/`, implementation in `data/`.
- All box access inside `try/catch`, rethrowing typed failures.
- `toEntity()` and `fromEntity()` are on the Model, not in the repository.

---

## 6. Error Handling

```dart
// Define typed failures
sealed class HabitFailure {
  const HabitFailure();
}
class HabitNotFoundFailure extends HabitFailure {
  const HabitNotFoundFailure(this.id);
  final String id;
}
class HabitStorageFailure extends HabitFailure {
  const HabitStorageFailure(this.message);
  final String message;
}

// Repository wraps storage errors
@override
Future<void> save(Habit habit) async {
  try {
    await _box.put(habit.id, HabitModel.fromEntity(habit));
  } catch (e, st) {
    _logger.e('HabitRepository.save failed', error: e, stackTrace: st);
    throw HabitStorageFailure(e.toString());
  }
}
```

- **No `print()`** — use `logger` package (`Logger` instance per class).
- Providers catch failures with `AsyncValue.guard`.
- UI reacts to `AsyncError` state with inline error widgets. No `showDialog` for data errors.

---

## 7. Theming & Styling

```dart
// ✅ Good — always read from theme, never hardcode
final colors = Theme.of(context).colorScheme;
final text = Theme.of(context).textTheme;

Text('Today', style: text.titleLarge);
Container(color: colors.surface);

// ❌ Bad — hardcoded values
Text('Today', style: TextStyle(fontSize: 18, color: Color(0xFF1C1914)));
Container(color: Color(0xFFF5F0E8));
```

- All colors defined in `AppColors` constants and registered into `ColorScheme`.
- All text styles in `AppTextStyles`, assigned to `TextTheme`.
- Spacing: use `AppSpacing.xs / sm / md / lg / xl` (4 / 8 / 16 / 24 / 32 dp).
- Never use magic numbers for padding/margin in widgets.

```dart
// app_spacing.dart
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
```

---

## 8. Animation Guidelines

- Use `flutter_animate` for simple reveal/fade/slide animations.
- Lottie only for the habit completion check animation and onboarding illustrations.
- All animation durations from `AppDurations`:
  ```dart
  class AppDurations {
    static const fast    = Duration(milliseconds: 150);
    static const normal  = Duration(milliseconds: 300);
    static const slow    = Duration(milliseconds: 600);
    static const spring  = Duration(milliseconds: 800);
  }
  ```
- Respect `MediaQuery.of(context).disableAnimations` — wrap all animations:
  ```dart
  if (!MediaQuery.of(context).disableAnimations) {
    return widget.animate().fadeIn(duration: AppDurations.normal);
  }
  return widget;
  ```

---

## 9. Code Comments

```dart
// ✅ Good — explains WHY, not WHAT
// Offset by 1 day because Hive stores log dates at midnight UTC,
// but the user sees their local date. Comparing raw DateTime objects
// would break at UTC-offset boundaries.
final logDate = log.date.toLocal().withoutTime();

// ✅ Good — public API docs
/// Returns the completion ratio (0.0–1.0) for [date].
/// Returns 0.0 if no habits are scheduled for that date.
Future<double> getCompletionRatio(DateTime date);

// ❌ Bad — explains WHAT (obvious from code)
// Increment streak
habit.streak++;
```

**Rules:**
- Public classes and methods get `///` doc comments.
- Complex logic gets a `//` comment explaining intent.
- TODO comments must include a GitHub issue number: `// TODO(#42): add voice input`.

---

## 10. Import Order

Follow `dart_style` import ordering (enforced by `import_sorter`):

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 4. Forma packages (absolute from lib/)
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/features/habits/domain/entities/habit.dart';
```

Use absolute imports (`package:forma/...`) for cross-feature imports. Relative imports only within the same sub-folder.

---

## 11. Git & PR Rules

- Branch naming: `feature/activity-graph`, `fix/streak-reset-bug`, `chore/update-dependencies`
- Commit style: Conventional Commits — `feat: add activity graph widget`, `fix: mood not saving on date change`
- Every PR needs: a description, a screenshot/recording for UI changes, passing CI
- No PR > 400 lines changed (split if larger)
- One approval required to merge to `main`