import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/habits/domain/usecases/get_habits_for_date.dart';
import 'package:forma/features/habits/presentation/providers/habits_provider.dart';
import 'package:forma/features/home/presentation/providers/selected_date_provider.dart';
import 'package:forma/features/stats/presentation/providers/stats_provider.dart';

/// An animated progress ring showing habit completion progress for the
/// selected date.
///
/// Watches [habitsForDateProvider] for done/total count and [statsProvider]
/// for the streak display.
class ProgressRing extends ConsumerWidget {
  const ProgressRing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final habitsAsync = ref.watch(habitsForDateProvider(selectedDate));
    final statsAsync = ref.watch(statsProvider);

    final habits = habitsAsync.valueOrNull ?? const <HabitWithStatus>[];
    final total = habits.length;
    final completed = habits.where((h) => h.isCompleted).length;
    final remaining = total - completed;
    final progress = total == 0 ? 0.0 : completed / total;
    final streak = statsAsync.valueOrNull?.bestStreak ?? 0;

    return _ProgressRingBody(
      completed: completed,
      total: total,
      remaining: remaining,
      progress: progress,
      streak: streak,
    );
  }
}

class _ProgressRingBody extends StatelessWidget {
  const _ProgressRingBody({
    required this.completed,
    required this.total,
    required this.remaining,
    required this.progress,
    required this.streak,
  });

  final int completed;
  final int total;
  final int remaining;
  final double progress;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Semantics(
      label: '$completed of $total habits completed',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: disableAnimations
                  ? CustomPaint(
                      painter: _ProgressRingPainter(progress: progress),
                      child: _RingCenterText(
                        completed: completed,
                        total: total,
                      ),
                    )
                  : TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: progress),
                      duration: AppDurations.spring,
                      curve: const Cubic(0.34, 1.2, 0.64, 1.0),
                      builder: (context, animatedProgress, child) {
                        return CustomPaint(
                          painter: _ProgressRingPainter(
                            progress: animatedProgress,
                          ),
                          child: _RingCenterText(
                            completed: completed,
                            total: total,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Today's Progress",
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$remaining habits left',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.ink2,
                    ),
                  ),
                  if (streak > 0) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$streak day streak',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.sage,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingCenterText extends StatelessWidget {
  const _RingCenterText({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$completed',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.ink,
            ),
          ),
          Text(
            'OF $total',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.ink3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.progress,
  });

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - _strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = AppColors.paper2
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, _startAngle, _sweepAngle, false, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = AppColors.sage
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        _startAngle,
        _sweepAngle * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }

  static const double _strokeWidth = 8.0;
  static const double _startAngle = -math.pi / 2;
  static const double _sweepAngle = 2 * math.pi;
}
