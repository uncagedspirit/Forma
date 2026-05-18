import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/mood/domain/entities/mood_entry.dart';
import 'package:forma/features/stats/presentation/providers/mood_week_provider.dart';
import 'package:forma/shared/widgets/skeleton_loader.dart';

/// A 7-day mood chart showing vertical bars for Mon–Sun.
///
/// Height is proportional to mood value (1–5). Watches [moodWeekProvider].
class MoodWeekChart extends ConsumerWidget {
  const MoodWeekChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodWeekAsync = ref.watch(moodWeekProvider);

    return moodWeekAsync.when(
      data: (List<MoodEntry?> entries) => _MoodWeekChartContent(entries: entries),
      loading: () => const _MoodWeekChartLoading(),
      error: (Object error, StackTrace stackTrace) => const _MoodWeekChartError(),
    );
  }
}

class _MoodWeekChartContent extends StatelessWidget {
  const _MoodWeekChartContent({required this.entries});

  final List<MoodEntry?> entries;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));

    final List<_DayBarData> bars = <_DayBarData>[];
    for (int i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      final MoodEntry? entry = entries[i];
      bars.add(_DayBarData(
        label: _weekdayLabel(date.weekday),
        moodValue: entry?.value,
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: bars.map((_DayBarData bar) => _MoodBar(data: bar)).toList(),
    );
  }

  String _weekdayLabel(int weekday) {
    const List<String> labels = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[weekday - 1];
  }
}

class _DayBarData {
  const _DayBarData({required this.label, this.moodValue});

  final String label;
  final int? moodValue;
}

class _MoodBar extends StatelessWidget {
  const _MoodBar({required this.data});

  final _DayBarData data;

  @override
  Widget build(BuildContext context) {
    final int? value = data.moodValue;

    final double targetHeight;
    if (value == null) {
      targetHeight = 0;
    } else {
      targetHeight = (value / 5) * 100;
    }

    final Color barColor;
    if (value == null) {
      barColor = AppColors.paper3;
    } else if (value <= 2) {
      barColor = AppColors.terra;
    } else if (value == 3) {
      barColor = AppColors.gold;
    } else {
      barColor = AppColors.sage;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 24,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.paper2,
            borderRadius: BorderRadius.circular(AppBorderRadius.rSm),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              duration: AppDurations.normal,
              tween: Tween<double>(begin: 0, end: targetHeight),
              builder: (BuildContext context, double height, Widget? child) {
                return Container(
                  width: 24,
                  height: height,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppBorderRadius.rSm),
                      topRight: Radius.circular(AppBorderRadius.rSm),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          data.label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.ink3,
          ),
        ),
      ],
    );
  }
}

class _MoodWeekChartLoading extends StatelessWidget {
  const _MoodWeekChartLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List<Widget>.generate(7, (_) => const _LoadingBar()),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SkeletonLoader(
          width: 24,
          height: 100,
          borderRadius: BorderRadius.all(Radius.circular(AppBorderRadius.rSm)),
        ),
        SizedBox(height: AppSpacing.sm),
        SkeletonLoader(
          width: 24,
          height: 12,
          borderRadius: BorderRadius.all(Radius.circular(AppBorderRadius.rSm)),
        ),
      ],
    );
  }
}

class _MoodWeekChartError extends StatelessWidget {
  const _MoodWeekChartError();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List<Widget>.generate(
        7,
        (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 24,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.paper2,
                borderRadius: BorderRadius.circular(AppBorderRadius.rSm),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '--',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
