import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/stats/presentation/providers/habit_completion_rates_provider.dart';
import 'package:forma/shared/widgets/skeleton_loader.dart';

/// A vertical list of habit completion bars for the stats screen.
///
/// Each row shows an emoji, habit name, completion percentage, and a
/// progress bar. Data is sorted by completion percentage descending.
/// Watches [habitCompletionRatesProvider].
class HabitCompletionBars extends ConsumerWidget {
  const HabitCompletionBars({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(habitCompletionRatesProvider);

    return ratesAsync.when(
      data: (List<HabitCompletionRate> rates) =>
          _HabitCompletionBarsContent(rates: rates),
      loading: () => const _HabitCompletionBarsLoading(),
      error: (Object error, StackTrace stackTrace) =>
          const _HabitCompletionBarsError(),
    );
  }
}

class _HabitCompletionBarsContent extends StatelessWidget {
  const _HabitCompletionBarsContent({required this.rates});

  final List<HabitCompletionRate> rates;

  @override
  Widget build(BuildContext context) {
    if (rates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rates.asMap().entries.map((entry) {
        final int index = entry.key;
        final HabitCompletionRate rate = entry.value;
        final bool isLast = index == rates.length - 1;

        return Padding(
          padding: EdgeInsets.only(
            bottom: isLast ? 0 : AppSpacing.md,
          ),
          child: _HabitCompletionBarRow(rate: rate),
        );
      }).toList(),
    );
  }
}

class _HabitCompletionBarRow extends StatelessWidget {
  const _HabitCompletionBarRow({required this.rate});

  final HabitCompletionRate rate;

  @override
  Widget build(BuildContext context) {
    final int percentage = (rate.rate * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              width: 24,
              height: 24,
              child: Text(
                rate.icon,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                rate.name,
                style: AppTextStyles.bodyLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$percentage%',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.ink3,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _AnimatedProgressBar(rate: rate.rate),
      ],
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({required this.rate});

  final double rate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.paper2,
        borderRadius: BorderRadius.circular(AppBorderRadius.rFull),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          duration: AppDurations.normal,
          tween: Tween<double>(begin: 0, end: rate),
          builder: (BuildContext context, double value, Widget? child) {
            return FractionallySizedBox(
              widthFactor: value,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.sage,
                  borderRadius: BorderRadius.circular(AppBorderRadius.rFull),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HabitCompletionBarsLoading extends StatelessWidget {
  const _HabitCompletionBarsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
        5,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _LoadingRow(),
        ),
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            SkeletonLoader(width: 24, height: 24),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SkeletonLoader(height: 16),
            ),
            SizedBox(width: AppSpacing.sm),
            SkeletonLoader(width: 32, height: 12),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        SkeletonLoader(height: 4),
      ],
    );
  }
}

class _HabitCompletionBarsError extends StatelessWidget {
  const _HabitCompletionBarsError();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
