# Forma — Architecture

> Feature-first · Clean Architecture · Riverpod 2 · Hive · GoRouter

---

## 1. Philosophy

Forma uses **Clean Architecture** sliced by **feature**, not by layer. Every feature is a self-contained vertical slice — its own data, domain, and presentation code — so adding or deleting a feature never touches shared infrastructure unexpectedly.

The three horizontal layers inside each feature:

```
Presentation  →  What the user sees (widgets, screens, controllers)
Domain        →  What the app does  (entities, use-cases, repo interfaces)
Data          →  Where data lives   (Hive adapters, repo implementations, DTOs)
```

State is managed by **Riverpod 2** with code generation. UI never talks to Hive directly; it talks to providers which delegate to repositories which talk to Hive.

---

## 2. Folder Structure

```
forma/
├── lib/
│   ├── main.dart                   # Prod entry point
│   ├── main_dev.dart               # Dev entry point (mock data)
│   │
│   ├── core/                       # Cross-cutting infrastructure (no feature logic)
│   │   ├── config/
│   │   │   ├── feature_flags.dart
│   │   │   └── app_config.dart     # Env-specific URLs, keys
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   ├── app_spacing.dart
│   │   │   └── app_durations.dart
│   │   ├── extensions/
│   │   │   ├── date_time_ext.dart
│   │   │   └── string_ext.dart
│   │   ├── router/
│   │   │   └── app_router.dart     # GoRouter definition
│   │   ├── storage/
│   │   │   ├── hive_service.dart   # Box open/close lifecycle
│   │   │   └── secure_storage.dart
│   │   ├── notifications/
│   │   │   └── notification_service.dart
│   │   └── theme/
│   │       ├── app_theme.dart      # ThemeData (light + dark)
│   │       └── app_typography.dart
│   │
│   ├── features/
│   │   ├── habits/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── habit_model.dart        # Hive TypeAdapter
│   │   │   │   │   └── habit_log_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── habit_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── habit.dart
│   │   │   │   │   └── habit_log.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── habit_repository.dart   # Abstract interface
│   │   │   │   └── usecases/
│   │   │   │       ├── add_habit.dart
│   │   │   │       ├── delete_habit.dart
│   │   │   │       ├── reorder_habits.dart
│   │   │   │       ├── complete_habit.dart
│   │   │   │       └── get_habits_for_date.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── habits_provider.dart
│   │   │       │   └── habit_completion_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── add_habit_screen.dart
│   │   │       └── widgets/
│   │   │           ├── habit_row.dart
│   │   │           ├── habit_check_button.dart
│   │   │           └── habit_heat_row.dart
│   │   │
│   │   ├── goals/
│   │   │   ├── data/ ...
│   │   │   ├── domain/ ...
│   │   │   └── presentation/ ...
│   │   │
│   │   ├── mood/
│   │   │   ├── data/
│   │   │   │   └── models/mood_model.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/mood_entry.dart
│   │   │   │   └── usecases/log_mood.dart
│   │   │   └── presentation/
│   │   │       ├── providers/mood_provider.dart
│   │   │       └── widgets/
│   │   │           ├── mood_selector.dart
│   │   │           └── mood_week_chart.dart
│   │   │
│   │   ├── activity_graph/         # GitHub-style contribution graph
│   │   │   ├── domain/
│   │   │   │   └── usecases/compute_daily_completion_score.dart
│   │   │   └── presentation/
│   │   │       ├── providers/activity_graph_provider.dart
│   │   │       └── widgets/activity_graph.dart
│   │   │
│   │   ├── stats/
│   │   │   ├── domain/
│   │   │   │   └── usecases/compute_stats.dart
│   │   │   └── presentation/
│   │   │       ├── providers/stats_provider.dart
│   │   │       └── screens/stats_screen.dart
│   │   │
│   │   ├── home/
│   │   │   └── presentation/
│   │   │       ├── screens/home_screen.dart
│   │   │       └── widgets/
│   │   │           ├── date_strip.dart
│   │   │           ├── progress_ring.dart
│   │   │           └── section_header.dart
│   │   │
│   │   ├── onboarding/
│   │   │   └── presentation/ ...
│   │   │
│   │   ├── profile/
│   │   │   └── presentation/ ...
│   │   │
│   │   └── premium/                # Paywall + IAP logic
│   │       ├── data/
│   │       │   └── iap_service.dart          # purchases package wrapper
│   │       ├── domain/
│   │       │   └── premium_status_provider.dart
│   │       └── presentation/
│   │           ├── screens/paywall_screen.dart
│   │           └── widgets/premium_badge.dart
│   │
│   └── shared/                     # Truly shared widgets (used by 2+ features)
│       ├── widgets/
│       │   ├── forma_bottom_nav.dart
│       │   ├── forma_modal_sheet.dart
│       │   ├── forma_text_field.dart
│       │   ├── emoji_picker.dart
│       │   ├── confetti_overlay.dart
│       │   └── skeleton_loader.dart
│       └── hooks/                  # flutter_hooks helpers
│           └── use_debounce.dart
│
├── test/
│   ├── unit/
│   │   └── features/
│   │       ├── habits/
│   │       └── activity_graph/
│   ├── widget/
│   └── integration/
│
├── assets/
│   ├── fonts/                      # Fraunces, Instrument Sans
│   ├── lottie/                     # Check animation, confetti
│   └── images/
│
├── android/ ...
├── ios/ ...
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 3. Data Flow

```
Widget
  │  watches / reads
  ▼
Riverpod Provider (AsyncNotifier / NotifierProvider)
  │  calls
  ▼
Use-Case (pure Dart, no Flutter dependency)
  │  calls
  ▼
Repository Interface (abstract class)
  │  implemented by
  ▼
Repository Implementation
  │  reads/writes
  ▼
Hive Box
```

**Rule**: Widgets never import Hive. Use-cases never import Flutter. Repositories never import Riverpod.

---

## 4. Key Provider Patterns

### Habits for a selected date

```dart
// features/habits/presentation/providers/habits_provider.dart

@riverpod
Future<List<Habit>> habitsForDate(HabitsForDateRef ref, DateTime date) async {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.getHabitsForDate(date);
}
```

### Habit completion (optimistic update)

```dart
@riverpod
class HabitCompletion extends _$HabitCompletion {
  @override
  Future<void> build() async {}

  Future<void> complete(String habitId, DateTime date) async {
    state = const AsyncLoading();
    // Optimistic local state update via ref.invalidate
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(completeHabitUseCaseProvider);
      await useCase(habitId: habitId, date: date);
      ref.invalidate(habitsForDateProvider(date));
    });
  }
}
```

---

## 5. Activity Graph Architecture

The GitHub-style graph is its own feature slice:

```
Domain
  ComputeDailyCompletionScore usecase
    Input:  date range (startDate, endDate)
    Output: Map<DateTime, double>  (0.0 → 1.0 completion ratio)

Presentation
  ActivityGraphProvider
    - watches habitsForDateProvider for each day in range
    - maps ratio → ActivityLevel enum (none/light/medium/dark/full)

  ActivityGraph widget
    - Renders a scrollable grid of 52 weeks × 7 days
    - Each cell is a rounded square, colored by ActivityLevel
    - Long-press on a cell shows a tooltip (date + n/n habits done)
```

### ActivityLevel enum → color mapping

```dart
enum ActivityLevel { none, light, medium, dark, full }

// In app_colors.dart:
static const graphNone   = Color(0xFFE4DDD2); // paper3 — no data
static const graphLight  = Color(0xFFB8D4B8); // 1 habit done
static const graphMedium = Color(0xFF7AAD7A); // ~25–50% done
static const graphDark   = Color(0xFF4A8C4A); // ~51–75% done  
static const graphFull   = Color(0xFF2D6E2D); // all done
```

Proportion thresholds:
```
0 habits          → none
> 0, ≤ 25%        → light
> 25%, ≤ 60%      → medium
> 60%, < 100%     → dark
100%              → full
```

---

## 6. Navigation — GoRouter

```dart
// Routes
const String homeRoute        = '/';
const String statsRoute       = '/stats';
const String profileRoute     = '/profile';
const String addHabitRoute    = '/habits/add';
const String addGoalRoute     = '/goals/add';
const String habitDetailRoute = '/habits/:id';
const String goalDetailRoute  = '/goals/:id';
const String onboardingRoute  = '/onboarding';
const String paywallRoute     = '/premium';
```

The bottom nav shell uses GoRouter's `ShellRoute` with a persistent `FormaBottomNav`.

---

## 7. Hive Type IDs

Every Hive adapter needs a unique `typeId`. Reserved IDs:

| typeId | Model |
|---|---|
| 0 | HabitModel |
| 1 | HabitLogModel |
| 2 | GoalModel |
| 3 | MoodModel |
| 4 | UserPreferencesModel |
| 5–19 | Reserved for v2 |

---

## 8. Premium Feature Gate

```dart
// Usage anywhere in UI:
final isPremium = ref.watch(premiumStatusProvider);

if (!isPremium) {
  return PremiumGateWidget(
    feature: PremiumFeature.moodCorrelation,
    child: LockedFeatureBlur(child: actualWidget),
  );
}
```

`premiumStatusProvider` reads from `prefsBox` (local purchase receipt verification). Phase 2 adds server-side validation.

---

## 9. Error Handling Strategy

- **Use-cases** return `Either<Failure, T>` (using `fpdart` or simple sealed class)
- **Providers** surface errors as `AsyncError` state — UI shows inline error widgets, not dialogs
- **Hive errors** are caught at the repository layer and rethrown as typed `StorageFailure`
- **No `try/catch` in UI code**

---

## 10. Testing Strategy

| Layer | Tool | Notes |
|---|---|---|
| Domain (use-cases) | `dart test` + `mocktail` | Pure Dart, fast |
| Repository | `dart test` + in-memory Hive | Use `Hive.init(tempDir)` |
| Providers | `ProviderContainer` in tests | No Flutter needed |
| Widgets | `flutter_test` | Golden tests for key screens |
| Integration | `integration_test` package | Smoke tests on device |