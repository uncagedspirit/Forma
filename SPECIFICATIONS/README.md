# Forma — Documentation Index

> Habit Journal · Flutter · Local-first · Premium-ready

---

## Documents

| File | Purpose | Read when... |
|---|---|---|
| [`SYSTEM_SPECS.md`](./SYSTEM_SPECS.md) | Platform targets, dependencies, storage, permissions, CI/CD | Setting up the project or onboarding a new dev |
| [`ARCHITECTURE.md`](./ARCHITECTURE.md) | Folder structure, data flow, provider patterns, navigation, Hive type IDs | Starting a new feature or debugging state |
| [`CODING_STYLE.md`](./CODING_STYLE.md) | Naming, widget structure, provider rules, error handling, imports, Git | Writing any code |
| [`DESIGN_SYSTEM.md`](./DESIGN_SYSTEM.md) | Colors, typography, spacing, components, motion, dark mode | Building any UI |
| [`PREMIUM_FEATURES.md`](./PREMIUM_FEATURES.md) | Premium feature specs, pricing, paywall tone | Building premium gates or the paywall screen |
| [`TASKS.md`](./TASKS.md) | Granular task list — do one at a time, in order | Every working session |

---

## Quick Reference

### Stack
```
Flutter 3.22+ · Dart 3.4+
Riverpod 2 (code-gen) — state
Hive 2 — local storage
GoRouter 13 — navigation
flutter_animate — animations
flutter_local_notifications — reminders
```

### Key design tokens
```
paper:   #F5F0E8    ink:   #1C1914
terra:   #B85C38    sage:  #5A7A5C
font:    Fraunces (display) + Instrument Sans (UI)
```

### Activity graph shades
```
0%        → graphNone   #E4DDD2
1–25%     → graphLight  #B8D4B8
26–60%    → graphMedium #7AAD7A
61–99%    → graphDark   #4A8C4A
100%      → graphFull   #2D6E2D
```

### Current phase
**Phase 0 — Bootstrap** (see TASKS.md)

---

## Principles

1. **Local first.** The app must be fully functional with no internet. Cloud is additive, never required.
2. **One task at a time.** Never start T-N+1 until T-N is committed and tested.
3. **Design is the spec.** If code doesn't match DESIGN_SYSTEM.md, the code is wrong.
4. **No magic numbers.** Every spacing, color, and duration value comes from a constant.
5. **Premium earns its price.** Free tier is genuinely useful. Premium makes you feel understood.