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
import 'package:forma/features/habits/presentation/widgets/add_habit_sheet.dart';
import 'package:forma/features/habits/presentation/widgets/habit_row.dart';
import 'package:forma/features/home/presentation/providers/selected_date_provider.dart';
import 'package:forma/features/home/presentation/widgets/date_strip.dart';
import 'package:forma/features/home/presentation/widgets/mood_selector.dart';
import 'package:forma/features/home/presentation/widgets/progress_ring.dart';
import 'package:forma/features/profile/presentation/providers/user_preferences_provider.dart';
import 'package:forma/shared/widgets/inline_error.dart';
import 'package:intl/intl.dart';

/// The main home screen for the Forma habit tracker app.
///
/// Assembles the home screen by combining all previously created widgets
/// into a [CustomScrollView] with slivers for performance.
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
    final generalHabits = habits.where((h) => h.habit.goalId == null).toList();

    final userName = prefs?.name ?? '';
    final greeting = _computeGreeting();
    final pageTitle = userName.isEmpty ? greeting : '$greeting, $userName';
    final formattedDate = DateFormat('EEEE, MMMM d').format(selectedDate);

    final isLoading = habitsAsync.isLoading || goalsAsync.isLoading;
    final hasNoContent = habits.isEmpty;

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
            ? const _HomeLoadingBody()
            : hasNoContent
                ? _EmptyState(onAddHabit: () => _showAddHabitSheet(context))
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenHorizontal,
                            AppSpacing.contentTop,
                            AppSpacing.screenHorizontal,
                            AppSpacing.md,
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
                      const SliverToBoxAdapter(child: DateStrip()),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.md),
                      ),
                      const SliverToBoxAdapter(child: MoodSelector()),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.md),
                      ),
                      const SliverToBoxAdapter(child: ProgressRing()),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.md),
                      ),
                      if (goals.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: goals.map((goal) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: GoalBlock(
                                  key: ValueKey(goal.id),
                                  goal: goal,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      if (generalHabits.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final habit = generalHabits[index];
                              return HabitRow(
                                key: ValueKey(habit.habit.id),
                                habitWithStatus: habit,
                              );
                            },
                            childCount: generalHabits.length,
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.xl),
                      ),
                    ],
                  ),
      ),
    );
  }

  String _computeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showAddHabitSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AddHabitSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading body
// ---------------------------------------------------------------------------

class _HomeLoadingBody extends StatelessWidget {
  const _HomeLoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.sage,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddHabit});

  final VoidCallback onAddHabit;

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
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.paper2,
                borderRadius: AppBorderRadius.regular,
              ),
              child: const Icon(
                Icons.self_improvement,
                size: 56,
                color: AppColors.ink3,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Start by adding your first habit',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: onAddHabit,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: AppBorderRadius.small,
                ),
                child: Text(
                  'Add Habit',
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
