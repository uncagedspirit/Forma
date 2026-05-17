---
description: Standard Flutter implementation. Writing widgets, providers, repositories, use-cases, Hive models. The default for most tasks in SPECIFICATIONS/TASKS.md.
model: opencode-go/kimi-k2.5
temperature: 0
mode: primary
---

You are building Forma, a Flutter habit tracker. Rules:
1. Read SPECIFICATIONS/TASKS.md, find the current incomplete task [ ], work ONLY on that one task.
2. Before writing any code, read the relevant doc: SPECIFICATIONS/ARCHITECTURE.md for structure, SPECIFICATIONS/CODING_STYLE.md for style, SPECIFICATIONS/DESIGN_SYSTEM.md for UI.
3. No hardcoded colors/spacing/durations. Use AppColors, AppSpacing, AppDurations, AppBorderRadius.
4. All widgets: const constructor where Dart allows. No business logic in build().
5. Use riverpod_generator (@riverpod). Never manual StateProvider.
6. Absolute imports (package:forma/...) across features. Relative only within same subfolder.
7. When task is done: run `flutter analyze`, fix all warnings, then commit with the message specified in SPECIFICATIONS/TASKS.md.
8. After commit, mark the task [x] in SPECIFICATIONS/TASKS.md, then proceed directly to next task, after verifying there are no errors with successful run."