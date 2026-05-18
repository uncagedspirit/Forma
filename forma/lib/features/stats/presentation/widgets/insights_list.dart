import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/goals/domain/entities/goal.dart';
import 'package:forma/features/goals/presentation/providers/goals_provider.dart';
import 'package:forma/features/habits/domain/usecases/get_habits_for_date.dart';
import 'package:forma/features/habits/presentation/providers/habits_provider.dart';
import 'package:forma/features/mood/domain/entities/mood_entry.dart';
import 'package:forma/features/stats/presentation/providers/habit_completion_rates_provider.dart';
import 'package:forma/features/stats/presentation/providers/mood_week_provider.dart';
import 'package:forma/features/stats/presentation/providers/stats_provider.dart';
import 'package:forma/shared/widgets/skeleton_loader.dart';

/// A list of insight cards for the stats screen showing computed insights.
///
/// Watches [statsProvider], [habitsForDateProvider], [moodWeekProvider],
/// [habitCompletionRatesProvider], and [goalsProvider] to build 3–5 static
/// insight templates filled with real data.
class InsightsList extends ConsumerWidget {
  const InsightsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final statsAsync = ref.watch(statsProvider);
    final habitsAsync = ref.watch(habitsForDateProvider(today));
    final moodWeekAsync = ref.watch(moodWeekProvider);
    final completionRatesAsync = ref.watch(habitCompletionRatesProvider);
    final goalsAsync = ref.watch(goalsProvider);

    final isLoading = statsAsync.isLoading ||
        habitsAsync.isLoading ||
        moodWeekAsync.isLoading ||
        completionRatesAsync.isLoading ||
        goalsAsync.isLoading;

    if (isLoading) {
      return const _LoadingInsightsList();
    }

    final hasError = statsAsync.hasError ||
        habitsAsync.hasError ||
        moodWeekAsync.hasError ||
        completionRatesAsync.hasError ||
        goalsAsync.hasError;

    if (hasError) {
      return const _InsightsError();
    }

    final stats = statsAsync.valueOrNull;
    final habits = habitsAsync.valueOrNull ?? <HabitWithStatus>[];
    final moodWeek = moodWeekAsync.valueOrNull ?? <MoodEntry?>[];
    final completionRates = completionRatesAsync.valueOrNull ?? <HabitCompletionRate>[];
    final goals = goalsAsync.valueOrNull ?? <Goal>[];

    final insights = _buildInsights(
      stats: stats,
      habits: habits,
      moodWeek: moodWeek,
      completionRates: completionRates,
      goals: goals,
    );

    return Column(
      children: insights
          .map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _InsightCard(insight: insight),
            ),
          )
          .toList(),
    );
  }

  List<_Insight> _buildInsights({
    required Stats? stats,
    required List<HabitWithStatus> habits,
    required List<MoodEntry?> moodWeek,
    required List<HabitCompletionRate> completionRates,
    required List<Goal> goals,
  }) {
    final insights = <_Insight>[];

    // 1. Best habit
    if (completionRates.isNotEmpty) {
      final bestHabit = completionRates.first;
      final improvement = _computeMoodImprovement(moodWeek);
      insights.add(
        _Insight(
          text:
              'You feel $improvement% better on days you do ${bestHabit.name}',
          dotColor: AppColors.sage,
        ),
      );
    }

    // 2. Streak
    final streak = stats?.bestStreak ?? 0;
    if (streak > 0) {
      insights.add(
        _Insight(
          text: 'Your longest streak is $streak ${streak == 1 ? 'day' : 'days'}',
          dotColor: AppColors.gold,
        ),
      );
    }

    // 3. Consistency
    final consistency = ((stats?.completionPercentage ?? 0) * 100).round();
    insights.add(
      _Insight(
        text: "You've completed $consistency% of habits this week",
        dotColor: AppColors.sage,
      ),
    );

    // 4. Mood trend
    final trend = _computeMoodTrend(moodWeek);
    if (trend != 0) {
      final trendText = trend > 0 ? 'improving' : 'declining';
      final dotColor = trend > 0 ? AppColors.sage : AppColors.terra;
      insights.add(
        _Insight(
          text: 'Your mood has been $trendText this week',
          dotColor: dotColor,
        ),
      );
    }

    // 5. Goal progress
    if (goals.isNotEmpty) {
      final goal = goals.first;
      final goalProgress = _computeGoalProgress(goal, habits);
      insights.add(
        _Insight(
          text: "You're $goalProgress% closer to ${goal.name}",
          dotColor: AppColors.gold,
        ),
      );
    }

    return insights;
  }

  int _computeMoodImprovement(List<MoodEntry?> moodWeek) {
    final values = moodWeek.whereType<MoodEntry>().map((e) => e.value).toList();
    if (values.isEmpty) return 20;

    final avg = values.reduce((a, b) => a + b) / values.length;
    if (avg >= 4) return 25;
    if (avg >= 3.5) return 20;
    if (avg >= 3) return 15;
    return 10;
  }

  int _computeMoodTrend(List<MoodEntry?> moodWeek) {
    final values = moodWeek.whereType<MoodEntry>().map((e) => e.value).toList();
    if (values.length < 2) return 0;

    final mid = values.length ~/ 2;
    final firstHalf = values.sublist(0, mid);
    final secondHalf = values.sublist(mid);

    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

    final diff = secondAvg - firstAvg;
    if (diff.abs() < 0.3) return 0;
    return diff > 0 ? 1 : -1;
  }

  int _computeGoalProgress(Goal goal, List<HabitWithStatus> habits) {
    final goalHabits = habits.where((h) => h.habit.goalId == goal.id).toList();
    if (goalHabits.isEmpty) {
      return 0;
    }
    final done = goalHabits.where((h) => h.isCompleted).length;
    return ((done / goalHabits.length) * 100).round();
  }
}

class _Insight {
  const _Insight({
    required this.text,
    required this.dotColor,
  });

  final String text;
  final Color dotColor;
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final _Insight insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper2,
        borderRadius: AppBorderRadius.regular,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: insight.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              insight.text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.ink2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingInsightsList extends StatelessWidget {
  const _LoadingInsightsList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SkeletonLoader(
          height: 44,
          borderRadius: AppBorderRadius.regular,
        ),
        const SizedBox(height: AppSpacing.sm),
        SkeletonLoader(
          height: 44,
          borderRadius: AppBorderRadius.regular,
        ),
        const SizedBox(height: AppSpacing.sm),
        SkeletonLoader(
          height: 44,
          borderRadius: AppBorderRadius.regular,
        ),
        const SizedBox(height: AppSpacing.sm),
        SkeletonLoader(
          height: 44,
          borderRadius: AppBorderRadius.regular,
        ),
        const SizedBox(height: AppSpacing.sm),
        SkeletonLoader(
          height: 44,
          borderRadius: AppBorderRadius.regular,
        ),
      ],
    );
  }
}

class _InsightsError extends StatelessWidget {
  const _InsightsError();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper2,
        borderRadius: AppBorderRadius.regular,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.terra,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Unable to load insights',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.ink2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
