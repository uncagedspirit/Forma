import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/goals/domain/entities/goal.dart';
import 'package:forma/features/goals/presentation/providers/goals_provider.dart';
import 'package:forma/features/goals/presentation/widgets/goal_block.dart';
import 'package:forma/features/habits/domain/usecases/get_habits_for_date.dart';
import 'package:forma/features/habits/presentation/providers/habits_provider.dart';
import 'package:forma/features/habits/presentation/widgets/habit_row.dart';
import 'package:forma/features/home/presentation/providers/selected_date_provider.dart';
import 'package:forma/features/home/presentation/widgets/date_strip.dart';
import 'package:forma/features/home/presentation/widgets/mood_selector.dart';
import 'package:forma/features/profile/presentation/providers/user_preferences_provider.dart';
import 'package:forma/shared/widgets/add_flow_sheet.dart';
import 'package:forma/shared/widgets/inline_error.dart';
import 'package:intl/intl.dart';

/// Today tab — the primary daily ritual screen.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final habitsAsync = ref.watch(habitsForDateProvider(selectedDate));
    final goalsAsync = ref.watch(goalsProvider);
    final prefs = ref.watch(userPreferencesProvider);

    final hasError = habitsAsync.hasError || goalsAsync.hasError;
    final errorMessage = habitsAsync.error?.toString() ??
        goalsAsync.error?.toString() ??
        'Something went wrong';

    final habits = habitsAsync.valueOrNull ?? const <HabitWithStatus>[];
    final goals = goalsAsync.valueOrNull ?? const <Goal>[];
    final activeGoals = goals.where((g) => !g.isArchived).toList();
    final generalHabits = habits.where((h) => h.habit.goalId == null).toList();

    final userName = prefs?.name ?? '';
    final greeting = _computeGreeting();
    final pageTitle = userName.isEmpty ? greeting : '$greeting, $userName';
    final formattedDate = DateFormat('EEEE, MMMM d').format(selectedDate);

    final isLoading = habitsAsync.isLoading || goalsAsync.isLoading;
    final hasNoContent = habits.isEmpty && activeGoals.isEmpty;

    if (hasError) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: InlineError(
                message: errorMessage,
                onRetry: () {
                  ref.invalidate(habitsForDateProvider(selectedDate));
                  ref.invalidate(goalsProvider);
                },
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const _LoadingBody()
            : hasNoContent
                ? _EmptyState(onAddGoal: () => showAddFlowSheet(context))
                : CustomScrollView(
                    slivers: [
                      // ── Greeting ──
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenHorizontal,
                            AppSpacing.contentTop,
                            AppSpacing.screenHorizontal,
                            AppSpacing.xs,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pageTitle,
                                style: AppTextStyles.displayLarge.copyWith(
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                formattedDate,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.ink2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Date strip ──
                      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
                      const SliverToBoxAdapter(child: DateStrip()),
                      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

                      // ── Mood selector ──
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          child: const MoodSelector(),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

                      // ── Goals with habits ──
                      if (activeGoals.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: activeGoals.map((goal) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: GoalBlock(key: ValueKey(goal.id), goal: goal),
                              );
                            }).toList(),
                          ),
                        ),

                      // ── General habits section header ──
                      if (generalHabits.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.screenHorizontal,
                              AppSpacing.xs,
                              AppSpacing.screenHorizontal,
                              AppSpacing.sm,
                            ),
                            child: Text(
                              'GENERAL',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.ink3,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),

                      // ── General habits list ──
                      if (generalHabits.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return HabitRow(
                                key: ValueKey(generalHabits[index].habit.id),
                                habitWithStatus: generalHabits[index],
                              );
                            },
                            childCount: generalHabits.length,
                          ),
                        ),

                      // ── "Add a goal" nudge when user only has general habits ──
                      if (activeGoals.isEmpty && generalHabits.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.screenHorizontal,
                              AppSpacing.lg,
                              AppSpacing.screenHorizontal,
                              0,
                            ),
                            child: _AddGoalNudge(
                              onTap: () => showAddFlowSheet(context),
                            ),
                          ),
                        ),

                      // ── FAB clearance ──
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
      ),
      // Floating add button
      floatingActionButton: hasNoContent || isLoading
          ? null
          : FloatingActionButton(
              heroTag: 'home_add_fab',
              onPressed: () => showAddFlowSheet(context),
              backgroundColor: AppColors.ink,
              foregroundColor: AppColors.paper,
              elevation: 2,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 24),
            ),
    );
  }

  String _computeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ---------------------------------------------------------------------------
// Loading body
// ---------------------------------------------------------------------------

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.sage),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state — no goals and no habits
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddGoal});
  final VoidCallback onAddGoal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'What do you want to achieve\nin the coming months?',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.ink,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start with a goal, then build habits around it.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            GestureDetector(
              onTap: onAddGoal,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: AppBorderRadius.small,
                ),
                child: Text(
                  '+ Add a goal',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.paper,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "Add a goal" nudge strip — shown when user has habits but no goals
// ---------------------------------------------------------------------------

class _AddGoalNudge extends StatelessWidget {
  const _AddGoalNudge({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.paper2,
          borderRadius: AppBorderRadius.regular,
          border: Border.all(color: AppColors.line2),
        ),
        child: Row(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Give your habits a purpose',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.ink),
                  ),
                  Text(
                    'Group them under a goal',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink3),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.ink3, size: 20),
          ],
        ),
      ),
    );
  }
}
