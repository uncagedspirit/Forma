# Forma — Permanent Agent Rules

## How to invoke agents
- `@build go` — default for most TASKS.md work
- `@architect go` — new features, refactors touching 3+ files
- `@review go` — after completing a phase group
- `@scout <question>` — quick "does X exist / where is Y" lookups

## What this project is
Flutter 3.22+ habit tracker app. 
Full specs in: SPECIFICATIONS/ARCHITECTURE.md, SPECIFICATIONS/CODING_STYLE.md, 
SPECIFICATIONS/DESIGN_SYSTEM.md, SPECIFICATIONS/TASKS.md, SPECIFICATIONS/PREMIUM_FEATURES.md

## Task discipline — NON-NEGOTIABLE
- Work on exactly ONE task at a time from TASKS.md
- Find the first [ ] (unchecked) task, do only that
- After finishing: run flutter analyze, fix warnings, commit, mark [x], STOP
- Do not proceed to next task without explicit "yes continue" from me

## Code rules — NON-NEGOTIABLE  
- Colors: AppColors only. Never Color(0xFF...) or Colors.green
- Spacing: AppSpacing.sm/md/lg etc. Never raw 8.0 or 16.0
- Durations: AppDurations.fast/normal/slow. Never Duration(milliseconds: 300)
- Border radius: AppBorderRadius.r/rSm/rLg. Never BorderRadius.circular(14)
- Const: every widget that can be const, must be const
- No logic in build(). Derive values above the return statement
- State: riverpod_generator (@riverpod) only. Zero manual StateProvider
- Imports: package:forma/... for cross-feature. Relative only within same folder
- No print(). Use Logger

## Context window rule
When context gets long, YOU summarize completed tasks so far at the top of your next response, then continue. Do not wait for me to ask. The compaction agent handles this automatically anyway.

## Git commit format
After completing a task: run flutter analyze, fix warnings, 
git add -A, git commit with the correct message, mark task [x] 
in SPECIFICATIONS/TASKS.md, then push.

feat(scope): short description
- scope = the feature folder name e.g. habits, goals, storage, core
- Examples: feat(habits): HabitModel with Hive adapter
            feat(core): AppColors and AppTextStyles
            fix(habits): streak not incrementing on re-complete

## Flutter commands to run before every commit
flutter analyze        # must be zero warnings
flutter test           # must pass (skip if no tests yet for this task)