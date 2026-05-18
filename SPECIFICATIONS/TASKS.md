# Forma — Task Board

> Tasks are done **one at a time**, in order. Do not start the next task until the current one is complete and committed.

Status key: `[ ]` todo · `[~]` in progress · `[x]` done · `[!]` blocked

---

## Phase 0 — Project Bootstrap

### T-001 · Flutter project setup
- [x] Run `flutter create forma --org com.forma --platforms ios,android`
- [x] Set minimum iOS to 16.0 in `ios/Podfile` and `Info.plist`
- [x] Set `minSdkVersion 29`, `targetSdkVersion 35` in `android/app/build.gradle`
- [x] Enable edge-to-edge in `MainActivity.kt` (`WindowCompat.setDecorFitsSystemWindows(window, false)`)
- [x] Set portrait-only in `AndroidManifest.xml` and `Info.plist`
- [x] Delete boilerplate counter code from `main.dart`
- [x] Commit: `chore: initial Flutter project setup`

### T-002 · Folder structure
- [x] Create all folders per `ARCHITECTURE.md §2` (features/, core/, shared/)
- [x] Add `.gitkeep` to empty leaf directories
- [x] Commit: `chore: create feature-first folder structure`

### T-003 · Dependency installation
- [x] Add all Phase 1 dependencies from `SYSTEM_SPECS.md §9` to `pubspec.yaml`
- [x] Run `flutter pub get`
- [x] Run `dart pub run build_runner build` — confirm code gen runs clean
- [x] Commit: `chore: add Phase 1 dependencies`

### T-004 · Linting & code style
- [x] Configure `analysis_options.yaml` per `CODING_STYLE.md §1`
- [x] Run `flutter analyze` — fix any existing warnings
- [x] Add `import_sorter` to dev deps; configure in `pubspec.yaml`
- [x] Commit: `chore: configure analysis_options and linting`

### T-005 · Asset setup
- [x] Download Fraunces variable font (Google Fonts) — add to `assets/fonts/`
- [x] Download Instrument Sans (Google Fonts) — add to `assets/fonts/`
- [x] Declare fonts in `pubspec.yaml`
- [x] Create placeholder `assets/lottie/` and `assets/images/` directories
- [x] Run `flutter pub get`; verify fonts load with a test screen
- [x] Commit: `feat: add Fraunces and Instrument Sans fonts`

---

## Phase 1 — Core & Theme

### T-006 · AppColors
- [x] Create `lib/core/constants/app_colors.dart`
- [x] Define all color tokens from `DESIGN_SYSTEM.md §2` as `static const Color`
- [x] Include activity graph color set (`graphNone` → `graphFull`)
- [x] Write unit test: verify no color values are duplicated
- [x] Commit: `feat(core): add AppColors`

### T-007 · AppTextStyles + AppTypography
- [x] Create `lib/core/constants/app_text_styles.dart`
- [x] Define full type scale from `DESIGN_SYSTEM.md §3`
- [x] Create `lib/core/theme/app_typography.dart` returning a `TextTheme`
- [x] Commit: `feat(core): add AppTextStyles and AppTypography`

### T-008 · AppSpacing + AppDurations + AppBorderRadius
- [x] Create `lib/core/constants/app_spacing.dart`
- [x] Create `lib/core/constants/app_durations.dart`
- [x] Create `lib/core/constants/app_border_radius.dart`
- [x] Commit: `feat(core): add spacing, durations, and border radius constants`

### T-009 · AppTheme (light)
- [x] Create `lib/core/theme/app_theme.dart`
- [x] Build `ThemeData.light()` using all color + typography constants
- [x] Set `ColorScheme.fromSeed` with `paper` as seed surface
- [x] Verify in a test screen that colors render correctly
- [x] Commit: `feat(core): light theme`

### T-010 · AppTheme (dark)
- [x] Add dark color tokens per `DESIGN_SYSTEM.md §10`
- [x] Build `ThemeData.dark()` with parchment night palette
- [x] Wire `platformBrightness` detection in `main.dart`
- [x] Commit: `feat(core): dark theme (parchment night)`

---

## Phase 2 — Storage Layer

### T-011 · Hive initialization
- [x] Create `lib/core/storage/hive_service.dart`
- [x] `HiveService.init()` — opens all boxes, registers all adapters
- [x] Call `HiveService.init()` before `runApp` in all entry points
- [x] Commit: `feat(storage): Hive service initialization`

### T-012 · HabitModel (Hive adapter)
- [x] Create `lib/features/habits/data/models/habit_model.dart`
- [x] Fields: `id`, `name`, `icon`, `goalId` (nullable), `color`, `sortOrder`, `reminderTime` (nullable), `reminderMessage` (nullable), `createdAt`, `isArchived`
- [x] Add `@HiveType(typeId: 0)` + `@HiveField` annotations
- [x] Run `build_runner` — verify adapter generated
- [x] `toEntity()` and `fromEntity()` methods
- [x] Unit test: roundtrip (model → entity → model), verify all fields preserved
- [x] Commit: `feat(habits/data): HabitModel with Hive adapter`

### T-013 · HabitLogModel (Hive adapter)
- [x] Create `lib/features/habits/data/models/habit_log_model.dart`
- [x] Fields: `id`, `habitId`, `date`, `completedAt`, `photoPath` (nullable), `note` (nullable)
- [x] `@HiveType(typeId: 1)`, run build_runner
- [x] `toEntity()` / `fromEntity()`
- [x] Unit test: roundtrip + date serialization edge cases (midnight UTC)
- [x] Commit: `feat(habits/data): HabitLogModel with Hive adapter`

### T-014 · GoalModel (Hive adapter)
- [x] `GoalModel` — `id`, `name`, `color` (hex string), `sortOrder`, `createdAt`, `isArchived`
- [x] `@HiveType(typeId: 2)`, build_runner
- [x] Unit test: roundtrip
- [x] Commit: `feat(goals/data): GoalModel with Hive adapter`

### T-015 · MoodModel (Hive adapter)
- [x] `MoodModel` — `date` (DateTime), `value` (1–5 int), `note` (nullable String)
- [x] `@HiveType(typeId: 3)`, build_runner
- [x] Unit test
- [x] Commit: `feat(mood/data): MoodModel with Hive adapter`

### T-016 · UserPreferencesModel (Hive adapter)
- [x] Fields: `isPremium`, `premiumReceiptData` (nullable), `hasCompletedOnboarding`, `themeIndex`, `name` (user's name), `joinDate`
- [x] `@HiveType(typeId: 4)`, build_runner
- [x] Commit: `feat(prefs): UserPreferencesModel`

---

## Phase 3 — Domain Layer

### T-017 · Habit entity + domain interfaces
- [x] Create `Habit` entity (pure Dart, no Flutter, no Hive)
- [x] Create `HabitLog` entity
- [x] Create `HabitRepository` abstract interface — full method set per architecture doc
- [x] Create `Goal` entity + `GoalRepository` interface
- [x] Create `MoodEntry` entity + `MoodRepository` interface
- [x] Commit: `feat(domain): Habit, Goal, Mood entities and repository interfaces`

### T-018 · HabitRepository implementation
- [x] Implement `HabitRepositoryImpl` backed by Hive `habitsBox` + `logsBox`
- [x] `getHabitsForDate` — return habits where date falls within frequency; join with logs to compute `isCompleted`
- [x] `complete` — write a `HabitLogModel` to `logsBox`, key `log:{date}:{habitId}`
- [x] `save`, `delete`, `reorder` implementations
- [x] Unit tests with in-memory Hive (use `Hive.init(tempDirectory)`)
- [x] Commit: `feat(habits/data): HabitRepositoryImpl`

### T-019 · GoalRepository implementation
- [x] `GoalRepositoryImpl` backed by `goalsBox`
- [x] Unit tests
- [x] Commit: `feat(goals/data): GoalRepositoryImpl`

### T-020 · MoodRepository implementation
- [x] `MoodRepositoryImpl` backed by `moodBox` — one entry per date
- [x] Unit tests
- [x] Commit: `feat(mood/data): MoodRepositoryImpl`

### T-021 · Use-cases
- [ ] `AddHabit(repo).call(Habit)` — validates name not empty, assigns UUID, saves
- [ ] `DeleteHabit(repo).call(id)` — soft-deletes (sets `isArchived=true`)
- [ ] `CompleteHabit(habitRepo, logRepo).call(habitId, date)` — idempotent, returns existing log if already done
- [ ] `GetHabitsForDate(repo).call(date)` — returns sorted list with completion status
- [ ] `ReorderHabits(repo).call(List<String> orderedIds)` — updates sortOrder
- [ ] `ComputeCompletionRatio(logRepo).call(date)` — returns 0.0–1.0
- [ ] `ComputeDailyCompletionScores(logRepo).call(start, end)` — returns `Map<DateTime, double>`
- [ ] `LogMood(moodRepo).call(date, value, note)` — upsert
- [ ] Unit tests for all use-cases (mock repo with `mocktail`)
- [ ] Commit: `feat(domain): all v1 use-cases`

---

## Phase 4 — State (Riverpod Providers)

### T-022 · Repository providers
- [ ] `habitRepositoryProvider` — provides `HabitRepositoryImpl`
- [ ] `goalRepositoryProvider`
- [ ] `moodRepositoryProvider`
- [ ] All `@riverpod`, code-gen
- [ ] Commit: `feat(providers): repository providers`

### T-023 · Selected date provider
- [ ] `SelectedDateNotifier` — holds `DateTime`, `select(date)` method
- [ ] Default: `DateTime.now()`
- [ ] Commit: `feat(providers): selected date provider`

### T-024 · Habits providers
- [ ] `habitsForDateProvider(DateTime date)` — async, watches `habitRepositoryProvider`
- [ ] `habitCompletionProvider` — `AsyncNotifier`, exposes `complete(habitId, date)` with optimistic update
- [ ] Invalidates `habitsForDateProvider` on completion
- [ ] Unit tests using `ProviderContainer`
- [ ] Commit: `feat(habits/providers): habits for date + completion`

### T-025 · Goals provider
- [ ] `goalsProvider` — list of goals with their habits
- [ ] `goalCompletionRatioProvider(goalId)` — derived provider
- [ ] Commit: `feat(goals/providers): goals provider`

### T-026 · Mood provider
- [ ] `moodForDateProvider(DateTime)` — async
- [ ] `logMoodProvider` — `AsyncNotifier` wrapping `LogMood` use-case
- [ ] Commit: `feat(mood/providers): mood provider`

### T-027 · Activity graph provider
- [ ] `activityGraphProvider(start, end)` — returns `Map<DateTime, ActivityLevel>`
- [ ] Maps `ComputeDailyCompletionScores` output → `ActivityLevel` enum
- [ ] Thresholds per `ARCHITECTURE.md §5`
- [ ] Unit tests: verify threshold boundaries (0%, 1%, 25%, 26%, 60%, 61%, 100%)
- [ ] Commit: `feat(activity-graph/providers): activity graph provider`

### T-028 · Stats provider
- [ ] `statsProvider` — computes: best streak, completion %, check-in count, best weekday
- [ ] `habitCompletionRatesProvider` — per-habit % over last 30 days
- [ ] `moodWeekProvider` — 7-day mood values for chart
- [ ] Commit: `feat(stats/providers): stats providers`

### T-029 · Premium status provider
- [ ] `premiumStatusProvider` — reads `UserPreferencesModel.isPremium` from Hive
- [ ] Returns bool — no async needed (Hive is sync after open)
- [ ] Commit: `feat(premium): premium status provider`

---

## Phase 5 — Navigation

### T-030 · GoRouter setup
- [ ] Create `lib/core/router/app_router.dart`
- [ ] Define all routes from `ARCHITECTURE.md §6`
- [ ] `ShellRoute` for bottom nav shell
- [ ] Redirect: if `!hasCompletedOnboarding` → `/onboarding`
- [ ] Commit: `feat(router): GoRouter with all routes and shell`

---

## Phase 6 — Shared Widgets

### T-031 · FormaBottomNav
- [ ] Implements the bottom nav from the prototype exactly
- [ ] `ShellRoute`-aware (uses `GoRouter.of(context).location`)
- [ ] FAB triggers `AddHabitSheet`
- [ ] Correct safe-area bottom padding
- [ ] Commit: `feat(shared): FormaBottomNav`

### T-032 · FormaModalSheet
- [ ] Reusable bottom sheet wrapper (handle bar, padding, spring animation)
- [ ] Used by: AddHabitSheet, AddGoalSheet, HabitDetailSheet
- [ ] Commit: `feat(shared): FormaModalSheet`

### T-033 · FormaTextField
- [ ] Styled text input matching design system
- [ ] Supports `error` state (terra border), `placeholder`, `onChanged`
- [ ] Commit: `feat(shared): FormaTextField`

### T-034 · EmojiPicker
- [ ] Grid of emoji options, single selection, animated selection state
- [ ] `EMOJIS` list from prototype (20 emojis, expandable)
- [ ] Commit: `feat(shared): EmojiPicker widget`

### T-035 · SkeletonLoader
- [ ] Shimmering placeholder matching HabitRow dimensions
- [ ] Used while `habitsForDateProvider` is loading
- [ ] Commit: `feat(shared): SkeletonLoader`

### T-036 · ConfettiOverlay
- [ ] Positioned confetti burst at a given screen coordinate
- [ ] Uses `flutter_animate` with random trajectories
- [ ] Colors from `AppColors` accent set
- [ ] Commit: `feat(shared): ConfettiOverlay`

---

## Phase 7 — Home Screen

### T-037 · DateStrip widget
- [ ] 7 chips: 3 past + today + 3 future
- [ ] Today chip: ink background, paper text
- [ ] Past chips with data: `paper2` background, `line2` border
- [ ] Future chips: transparent
- [ ] Tapping a past/future chip updates `selectedDateProvider`
- [ ] Chip dot shows if that day has any completions
- [ ] Commit: `feat(home): DateStrip widget`

### T-038 · MoodSelector widget
- [ ] 5 emoji dots, single selection
- [ ] Selected state: scale animation, shadow
- [ ] Shows free-text note input after selection
- [ ] On note dismiss / submit: calls `logMoodProvider`
- [ ] Watches `moodForDateProvider(selectedDate)` to restore selection
- [ ] Commit: `feat(home): MoodSelector widget`

### T-039 · ProgressRing widget
- [ ] Animated SVG-equivalent in Flutter (`CustomPainter`)
- [ ] Stroke: sage color, round cap
- [ ] Spring animation on value change (800 ms)
- [ ] Center: Fraunces number + "OF N" label
- [ ] Side: title, remaining caption, streak line
- [ ] Watches `habitsForDateProvider(selectedDate)` for done/total count
- [ ] Commit: `feat(home): ProgressRing widget`

### T-040 · HabitRow widget
- [ ] Icon (emoji), name, streak + heat-row, check button
- [ ] Check button: tap → scale animation + confetti + completion provider call
- [ ] Idempotent: already-done check button is visually locked, no re-trigger
- [ ] `void` tag shown for habits that haven't been done in 3+ days
- [ ] Long-press → options bottom sheet (skip today, edit, delete)
- [ ] Commit: `feat(habits): HabitRow widget`

### T-041 · MiniHeatRow widget
- [ ] 7 cells (last 7 days), 5×5 dp each, 2 dp gap
- [ ] Sage fill for done, `paper3` for not done
- [ ] Data from `HabitLog` history joined per habit
- [ ] Commit: `feat(habits): MiniHeatRow widget`

### T-042 · GoalBlock widget
- [ ] Goal header (color bar, title, done/total, pct)
- [ ] Progress bar (thin, fills to goal color)
- [ ] Collapsible habit list
- [ ] Each habit row: `goal-habit-row` variant (compact)
- [ ] "Add habit to this goal" row at bottom
- [ ] Watches `goalsProvider`
- [ ] Commit: `feat(goals): GoalBlock widget`

### T-043 · AddHabitSheet
- [ ] FormaModalSheet wrapper
- [ ] Fields: habit name (FormaTextField), EmojiPicker, time-of-day chip row
- [ ] Optional: goal assignment dropdown (shows existing goals)
- [ ] Submit: calls `AddHabit` use-case, invalidates providers, closes sheet
- [ ] Validation: name cannot be empty
- [ ] Commit: `feat(habits): AddHabitSheet`

### T-044 · AddGoalSheet
- [ ] FormaModalSheet wrapper
- [ ] Fields: goal name, color picker (6 swatches)
- [ ] Submit: `GoalRepository.save`, invalidates `goalsProvider`
- [ ] Commit: `feat(goals): AddGoalSheet`

### T-045 · HomeScreen assembly
- [ ] Assemble: statusbar-style top padding, page title (with name from prefs), page sub (formatted date)
- [ ] DateStrip → MoodSelector → ProgressRing → GoalBlocks list → GeneralHabits list
- [ ] SliverList for habit rows (performance for long lists)
- [ ] Empty state: friendly prompt when no habits added yet
- [ ] Commit: `feat(home): HomeScreen assembled`

---

## Phase 8 — Activity Graph

### T-046 · ActivityGraph widget
- [ ] Grid: 52 columns (weeks) × 7 rows (days), scrollable horizontally
- [ ] Cell: 10×10 dp rounded square, 2 dp gap
- [ ] Color per `ActivityLevel` from provider
- [ ] Month labels above columns (Jan, Feb…)
- [ ] Day labels left side (M, W, F)
- [ ] Long-press on cell: tooltip with date + "n/n habits"
- [ ] Scroll starts at current week (auto-scroll on init)
- [ ] Free tier: shows full graph but blurs cells older than 30 days with premium CTA
- [ ] Commit: `feat(activity-graph): ActivityGraph widget`

### T-047 · ActivityGraph screen section (Stats screen)
- [ ] Integrate `ActivityGraph` widget in StatsScreen below the stat tiles
- [ ] Section header: "Your year" with year label
- [ ] Legend row: empty → light → medium → dark → full (5 cells + labels)
- [ ] Commit: `feat(stats): integrate ActivityGraph in StatsScreen`

---

## Phase 9 — Stats Screen

### T-048 · Stat tiles
- [ ] 2-column grid of stat tiles: best streak, completion %, check-in count, best weekday
- [ ] Data from `statsProvider`
- [ ] Commit: `feat(stats): StatTile widgets`

### T-049 · MoodWeekChart
- [ ] 7 vertical bars (Mon–Sun), height proportional to mood value (1–5)
- [ ] Color: sage for 4–5, gold for 3, terra for 1–2
- [ ] Day label below each bar
- [ ] Data from `moodWeekProvider`
- [ ] Commit: `feat(stats): MoodWeekChart widget`

### T-050 · HabitCompletionBars
- [ ] Vertical list of habit rows: emoji + name, percentage, colored progress bar
- [ ] Sorted by completion % descending
- [ ] Data from `habitCompletionRatesProvider`
- [ ] Commit: `feat(stats): HabitCompletionBars widget`

### T-051 · InsightsList
- [ ] 3–5 insight cards (sage/terra/gold dots, text)
- [ ] Static in v1 (hardcoded insight templates filled with real data)
- [ ] e.g. "You feel X% better on days you do [best habit]" — computed from mood×habit correlation
- [ ] Commit: `feat(stats): InsightsList widget`

### T-052 · StatsScreen assembly
- [ ] Assemble all stat widgets in scroll view
- [ ] Loading skeleton while providers load
- [ ] Commit: `feat(stats): StatsScreen assembled`

---

## Phase 10 — Profile Screen

### T-053 · ProfileScreen
- [ ] Avatar ring (first letter of name, ink bg)
- [ ] Name, member-since date, streak display
- [ ] Premium block (upgrade CTA if not premium)
- [ ] Settings rows (Reminders, Appearance, Export, Backup)
- [ ] Reminders row → opens NotificationSettingsSheet (v2)
- [ ] Commit: `feat(profile): ProfileScreen`

### T-054 · Paywall screen
- [ ] Full-screen sheet from `paywallRoute`
- [ ] Per `DESIGN_SYSTEM.md §11` and `PREMIUM_FEATURES.md`
- [ ] Feature list, pricing toggle (monthly/annual), CTA
- [ ] Restore purchases text link
- [ ] No IAP integration yet — CTA shows "Coming soon" toast in v1
- [ ] Commit: `feat(premium): PaywallScreen`

---

## Phase 11 — Onboarding

### T-055 · Onboarding flow (3 screens)
- [ ] Screen 1: Welcome — headline, Lottie placeholder (use a simple Flutter animation as placeholder until Lottie asset ready)
- [ ] Screen 2: Add first habit — minimal form (name + emoji), creates first habit on submit
- [ ] Screen 3: Notifications — permission request button, skip option
- [ ] On complete: sets `UserPreferences.hasCompletedOnboarding = true`, navigates to home
- [ ] Commit: `feat(onboarding): 3-screen onboarding flow`

---

## Phase 12 — Notifications

### T-056 · NotificationService
- [ ] Create `lib/core/notifications/notification_service.dart`
- [ ] `init()` — request permission, initialize channels
- [ ] `scheduleHabitReminder(habit)` — schedule daily exact alarm at habit's `reminderTime`
- [ ] `cancelHabitReminder(habitId)` — cancel by notification ID
- [ ] `scheduleStreakAtRisk()` — daily 8 PM check: if any habit not done and has streak > 0 → notify
- [ ] Test on device (exact alarms require physical device on Android 12+)
- [ ] Commit: `feat(notifications): NotificationService`

---

## Phase 13 — Polish & QA

### T-057 · Reduced motion support
- [ ] Wrap all `flutter_animate` calls with `MediaQuery.of(context).disableAnimations` check
- [ ] Test on iOS Reduce Motion setting and Android Remove animations setting
- [ ] Commit: `fix(a11y): respect reduce motion preference`

### T-058 · Accessibility audit
- [ ] Add `Semantics` labels to all custom check buttons, mood dots, activity graph cells
- [ ] Verify 44×44 pt minimum touch target on all interactive elements
- [ ] Run Flutter accessibility scan in debug mode
- [ ] Commit: `feat(a11y): semantics and touch targets`

### T-059 · Dynamic Type / text scaling
- [ ] Test with system font size at max on iOS (Accessibility > Larger Text)
- [ ] Fix any overflow issues in HabitRow, GoalBlock, Stat tiles
- [ ] Commit: `fix(a11y): text scaling fixes`

### T-060 · Performance profiling
- [ ] Profile home screen with 20 habits on a mid-range Android device
- [ ] Verify < 16 ms frame budget — fix any jank in list rendering
- [ ] Add `const` constructors to all stateless widgets that allow it
- [ ] Commit: `perf: const constructors and list performance`

### T-061 · Empty states
- [ ] Home screen, no habits: ink illustration (simple SVG line art) + prompt
- [ ] Stats screen, < 7 days data: "Check back after a week" message
- [ ] Activity graph, no data: muted cells with "Start building your history" overlay
- [ ] Commit: `feat(ux): empty state screens`

### T-062 · Error states
- [ ] Hive open failure on launch: show a "Storage unavailable" full-screen error with retry
- [ ] Provider `AsyncError` inline error widgets with retry buttons
- [ ] Commit: `feat(ux): error state handling`

---

## Phase 14 — Release Prep

### T-063 · App icons
- [ ] Design Forma icon (simple circle with a subtle pen-stroke F mark, warm paper bg)
- [ ] Generate all required sizes with `flutter_launcher_icons`
- [ ] Commit: `feat(assets): app icons`

### T-064 · Splash screen
- [ ] White/paper bg with Forma wordmark centered (Fraunces italic)
- [ ] Use `flutter_native_splash`
- [ ] Commit: `feat(assets): splash screen`

### T-065 · Build & sign
- [ ] iOS: create provisioning profile, configure `ExportOptions.plist`
- [ ] Android: create keystore, configure `key.properties`, sign release build
- [ ] Test release build on physical device (debug flags off)
- [ ] Commit: `chore: release signing configuration`

### T-066 · Store metadata
- [ ] App Store: title, subtitle, description, keywords, screenshots (6.5", 5.5")
- [ ] Play Store: short description, full description, feature graphic, screenshots
- [ ] Privacy policy URL (required for both stores)
- [ ] Commit: `chore: store metadata`

---

## Phase 15 — Firebase Setup (when ready)

### T-067 · Firebase project setup
- [ ] Create Firebase project with `dev` and `prod` environments
- [ ] Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) per flavor
- [ ] Gate behind `FeatureFlags.analyticsEnabled`

### T-068 · Firebase Analytics
- [ ] Add `firebase_analytics` package
- [ ] Log: `habit_completed`, `mood_logged`, `goal_created`, `paywall_viewed`, `premium_purchased`
- [ ] Verify in Firebase DebugView

### T-069 · Firebase Auth (Phase 2)
- [ ] Add `firebase_auth`
- [ ] Enable Email, Google, Apple sign-in
- [ ] Build `AuthScreen` (sign in / sign up / anonymous continue)
- [ ] Gate all auth UI behind `FeatureFlags.authEnabled`

### T-070 · Firestore sync (Phase 2)
- [ ] Mirror Hive data to Firestore when user is signed in
- [ ] Conflict resolution: local-wins for offline edits
- [ ] Background sync worker

---

*Last updated: Phase 0 not started.*