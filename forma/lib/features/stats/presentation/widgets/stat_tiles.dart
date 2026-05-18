import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/stats/presentation/providers/stats_provider.dart';
import 'package:forma/shared/widgets/skeleton_loader.dart';

/// A 2×2 grid of stat tiles showing key habit metrics.
///
/// Watches [statsProvider] for aggregate statistics.
class StatTiles extends ConsumerWidget {
  const StatTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return statsAsync.when(
      data: (stats) => _StatTilesGrid(
        bestStreak: stats.bestStreak,
        completionPercentage: stats.completionPercentage,
        checkInCount: stats.checkInCount,
        bestWeekday: stats.bestWeekday,
      ),
      loading: () => const _LoadingGrid(),
      error: (error, stackTrace) => const _ErrorGrid(),
    );
  }
}

class _StatTilesGrid extends StatelessWidget {
  const _StatTilesGrid({
    required this.bestStreak,
    required this.completionPercentage,
    required this.checkInCount,
    required this.bestWeekday,
  });

  final int bestStreak;
  final double completionPercentage;
  final int checkInCount;
  final String bestWeekday;

  @override
  Widget build(BuildContext context) {
    final percentageLabel = '${(completionPercentage * 100).round()}%';
    final streakLabel = bestStreak == 1 ? '1 day' : '$bestStreak days';

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatTile(
          icon: '🔥',
          value: streakLabel,
          label: 'Best streak',
        ),
        _StatTile(
          icon: '📊',
          value: percentageLabel,
          label: 'Completion rate',
        ),
        _StatTile(
          icon: '✅',
          value: '$checkInCount',
          label: 'Total check-ins',
        ),
        _StatTile(
          icon: '📅',
          value: bestWeekday,
          label: 'Best day',
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paper2,
          borderRadius: AppBorderRadius.regular,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SkeletonLoader(
          height: 100,
          borderRadius: AppBorderRadius.regular,
        ),
        SkeletonLoader(
          height: 100,
          borderRadius: AppBorderRadius.regular,
        ),
        SkeletonLoader(
          height: 100,
          borderRadius: AppBorderRadius.regular,
        ),
        SkeletonLoader(
          height: 100,
          borderRadius: AppBorderRadius.regular,
        ),
      ],
    );
  }
}

class _ErrorGrid extends StatelessWidget {
  const _ErrorGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _ErrorTile(),
        _ErrorTile(),
        _ErrorTile(),
        _ErrorTile(),
      ],
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper2,
        borderRadius: AppBorderRadius.regular,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.terra,
            size: 20,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '--',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Unavailable',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.ink3,
            ),
          ),
        ],
      ),
    );
  }
}
