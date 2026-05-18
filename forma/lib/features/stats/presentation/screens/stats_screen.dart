import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/activity_graph/presentation/widgets/activity_graph.dart';
import 'package:forma/features/stats/presentation/widgets/habit_completion_bars.dart';
import 'package:forma/features/stats/presentation/widgets/insights_list.dart';
import 'package:forma/features/stats/presentation/widgets/mood_week_chart.dart';
import 'package:forma/features/stats/presentation/widgets/stat_tiles.dart';

/// The stats screen for the Forma habit tracker app.
///
/// Assembles all stat widgets into a scrollable view with section headers
/// and loading skeletons for each section.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final yearLabel = DateTime.now().year.toString();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // Page title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.contentTop,
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                ),
                child: Text(
                  'Statistics',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
            // Stat tiles
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: StatTiles(),
              ),
            ),
            // Section header: Mood this week
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                ),
                child: Text(
                  'Mood this week',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
            // Mood week chart
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: MoodWeekChart(),
              ),
            ),
            // Section header: Habit completion
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                ),
                child: Text(
                  'Habit completion',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
            // Habit completion bars
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: HabitCompletionBars(),
              ),
            ),
            // Section header: Insights
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                ),
                child: Text(
                  'Insights',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
            // Insights list
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: InsightsList(),
              ),
            ),
            // Section header: Your year
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Your year',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      yearLabel,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.ink3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Activity graph
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: ActivityGraph(),
              ),
            ),
            // Legend row
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _LegendItem(
                      color: AppColors.graphNone,
                      label: 'None',
                    ),
                    SizedBox(width: AppSpacing.md),
                    _LegendItem(
                      color: AppColors.graphLight,
                      label: 'Light',
                    ),
                    SizedBox(width: AppSpacing.md),
                    _LegendItem(
                      color: AppColors.graphMedium,
                      label: 'Medium',
                    ),
                    SizedBox(width: AppSpacing.md),
                    _LegendItem(
                      color: AppColors.graphDark,
                      label: 'Dark',
                    ),
                    SizedBox(width: AppSpacing.md),
                    _LegendItem(
                      color: AppColors.graphFull,
                      label: 'Full',
                    ),
                  ],
                ),
              ),
            ),
            // Bottom breathing room
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xl),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppBorderRadius.rSm),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.labelSmall,
        ),
      ],
    );
  }
}
