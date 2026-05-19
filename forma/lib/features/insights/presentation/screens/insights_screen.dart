import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/activity_graph/presentation/widgets/activity_graph.dart';
import 'package:forma/features/stats/presentation/providers/stats_provider.dart';
import 'package:forma/features/stats/presentation/widgets/habit_completion_bars.dart';
import 'package:forma/features/stats/presentation/widgets/stat_tiles.dart';
import 'package:forma/shared/widgets/inline_error.dart';

/// Insights tab — GitHub-style graph + key stats.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.contentTop,
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                ),
                child: Text(
                  'Insights',
                  style:
                      AppTextStyles.displayLarge.copyWith(color: AppColors.ink),
                ),
              ),
            ),

            // Activity graph
            const SliverToBoxAdapter(
              child: ActivityGraph(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

            // Stats
            statsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.sage),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: InlineError(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(statsProvider),
                  ),
                ),
              ),
              data: (_) => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: StatTiles(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

            // Completion bars
            const SliverToBoxAdapter(
              child: HabitCompletionBars(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }
}
