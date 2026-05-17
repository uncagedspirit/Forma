# Forma — System Specifications

> Habit Journal · Flutter · Local-first · Premium-ready

---

## 1. Project Identity

| Field | Value |
|---|---|
| App name | **Forma** |
| Tagline | *A habit journal for the intentional.* |
| Platform | iOS 16+ · Android 10+ (API 29+) |
| Framework | Flutter 3.22+ (Dart 3.4+) |
| Architecture | Feature-first · Clean Architecture (Data / Domain / Presentation) |
| State mgmt | **Riverpod 2** (code-gen, `@riverpod`) |
| Storage | **Hive 2** (local-first, encrypted box for sensitive prefs) |
| Auth (future) | Firebase Auth — plugged in but gated behind `FeatureFlags.authEnabled` |
| Analytics (future) | Firebase Analytics — plugged in but gated behind `FeatureFlags.analyticsEnabled` |
| Min Dart SDK | 3.4.0 |
| Min Flutter SDK | 3.22.0 |

---

## 2. Supported Platforms (Phase 1)

- **iOS** — iPhone (portrait-only in v1)
- **Android** — Phone (portrait-only in v1)

iPad / tablet layout is a v2 stretch goal.

---

## 3. Device & OS Requirements

### iOS
| Requirement | Value |
|---|---|
| Min OS | iOS 16.0 |
| Min device | iPhone XS (A12 chip) |
| Orientation | Portrait only |
| Notch support | Safe-area aware (padding injection) |
| Dynamic Island | Status bar avoidance, no custom treatment in v1 |

### Android
| Requirement | Value |
|---|---|
| Min SDK | API 29 (Android 10) |
| Target SDK | API 35 (Android 15) |
| Compile SDK | API 35 |
| Orientation | Portrait only |
| Edge-to-edge | Enabled; WindowCompat.setDecorFitsSystemWindows = false |
| Nav bar | Transparent, gesture nav supported |

---

## 4. Storage Strategy

### Local (Phase 1 — Hive)

```
Box name              Key pattern              Contents
────────────────────────────────────────────────────────
habitsBox             habit:{id}               HabitModel JSON
goalsBox              goal:{id}                GoalModel JSON
logsBox               log:{yyyy-MM-dd}:{id}    HabitLogModel JSON
moodBox               mood:{yyyy-MM-dd}        MoodEntry JSON
prefsBox              prefs:*                  UserPreferences JSON
```

- All boxes stored in the app's sandboxed Documents directory
- `prefsBox` optionally encrypted with `HiveCipher` (key stored in Flutter Secure Storage)
- No cloud sync in v1; export via JSON/CSV

### Cloud (Phase 2 — Firebase)

- **Firestore** — mirrored document structure (users/{uid}/habits/{id}, etc.)
- **Firebase Auth** — email, Google, Apple sign-in
- **Sync strategy** — "local wins on conflict" for offline edits; last-write-wins on cross-device

---

## 5. Notifications

| Type | Mechanism |
|---|---|
| Habit reminders | `flutter_local_notifications` with exact scheduling |
| Streak at-risk | Computed nightly at 8 PM device time |
| Weekly summary | Push (Phase 2 via Firebase Cloud Messaging) |

Exact alarm permission (Android 12+) — requested on onboarding.

---

## 6. Permissions

| Permission | When requested | Rationale |
|---|---|---|
| `SCHEDULE_EXACT_ALARM` | Onboarding step 3 | Habit reminders |
| `POST_NOTIFICATIONS` (Android 13+) | Onboarding step 3 | Local notifications |
| `NSUserNotificationUsageDescription` | Onboarding step 3 | iOS notifications |
| Photo library (future) | Habit proof capture | Photo evidence for habits |
| Camera (future) | Habit proof capture | — |

No location, contacts, or microphone access.

---

## 7. Flavors / Build Variants

| Flavor | Bundle ID | API | Purpose |
|---|---|---|---|
| `dev` | `com.forma.app.dev` | Local / mock | Daily dev work |
| `staging` | `com.forma.app.staging` | Firebase staging project | QA & TestFlight |
| `prod` | `com.forma.app` | Firebase prod project | Store release |

Build commands:
```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter build appbundle --flavor prod -t lib/main_prod.dart
```

---

## 8. Performance Targets

| Metric | Target |
|---|---|
| Cold start (release) | < 1.5 s to first frame |
| Home screen render | < 16 ms per frame (60 fps sustained) |
| Hive read (all habits) | < 5 ms |
| Hive write (single log) | < 2 ms |
| App size (Android AAB) | < 25 MB download |
| App size (iOS IPA) | < 30 MB download |

---

## 9. Third-party Dependencies (Phase 1)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Storage
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0

  # Navigation
  go_router: ^13.2.0

  # UI & Animation
  flutter_animate: ^4.5.0
  lottie: ^3.1.0

  # Notifications
  flutter_local_notifications: ^17.2.2
  timezone: ^0.9.4

  # Utilities
  uuid: ^4.4.0
  intl: ^0.19.0
  collection: ^1.18.0

  # Charts (activity graph)
  fl_chart: ^0.68.0

dev_dependencies:
  riverpod_generator: ^2.4.3
  build_runner: ^2.4.11
  hive_generator: ^2.0.1
  flutter_lints: ^4.0.0
  mocktail: ^1.0.4
```

Firebase packages added in Phase 2 behind a feature flag.

---

## 10. CI/CD (Phase 2)

- **GitHub Actions** — lint, test, build on every PR
- **Fastlane** — `deliver` (iOS) + `supply` (Android)
- **Shorebird** — OTA code-push for minor fixes without store review

---

## 11. Feature Flags

Defined in `lib/core/config/feature_flags.dart`:

```dart
class FeatureFlags {
  static const bool authEnabled        = bool.fromEnvironment('AUTH_ENABLED',       defaultValue: false);
  static const bool analyticsEnabled   = bool.fromEnvironment('ANALYTICS_ENABLED',  defaultValue: false);
  static const bool cloudSyncEnabled   = bool.fromEnvironment('CLOUD_SYNC_ENABLED', defaultValue: false);
  static const bool photoProofEnabled  = bool.fromEnvironment('PHOTO_PROOF',        defaultValue: false);
}
```

---

## 12. Accessibility

- All interactive elements meet 44×44 pt minimum touch target
- `Semantics` widgets on all custom checkboxes and habit rows
- Dynamic Type support — text scales with system font size
- Color contrast ratio ≥ 4.5:1 for all text on background combinations
- Reduce Motion respected (`MediaQuery.of(ctx).disableAnimations`)