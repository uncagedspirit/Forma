import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/habits/domain/usecases/get_habits_for_date.dart';
import 'package:forma/features/habits/presentation/providers/habits_provider.dart';
import 'package:forma/features/mood/presentation/providers/mood_provider.dart';
import 'package:forma/shared/widgets/forma_modal_sheet.dart';
import 'package:intl/intl.dart';

/// Calendar tab — shows a month grid. Tap a day to see stats.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();

  DateTime get _firstDayOfMonth =>
      DateTime(_focusedMonth.year, _focusedMonth.month, 1);

  DateTime get _lastDayOfMonth =>
      DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _onDayTap(DateTime date) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DayStatsSheet(date: date),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final firstDow = _firstDayOfMonth.weekday % 7; // 0=Sun
    final daysInMonth = _lastDayOfMonth.day;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.contentTop,
                AppSpacing.screenHorizontal,
                AppSpacing.md,
              ),
              child: Text(
                'Calendar',
                style: AppTextStyles.displayLarge.copyWith(color: AppColors.ink),
              ),
            ),

            // Month header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _prevMonth,
                    child: const Icon(Icons.chevron_left, color: AppColors.ink2),
                  ),
                  Expanded(
                    child: Text(
                      DateFormat('MMMM yyyy').format(_focusedMonth),
                      style: AppTextStyles.titleLarge.copyWith(color: AppColors.ink),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: _nextMonth,
                    child: const Icon(Icons.chevron_right, color: AppColors.ink2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Day-of-week headers
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Row(
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                    .map(
                      (d) => Expanded(
                        child: Text(
                          d,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.ink3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Calendar grid
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: firstDow + daysInMonth,
                itemBuilder: (context, index) {
                  if (index < firstDow) return const SizedBox.shrink();
                  final day = index - firstDow + 1;
                  final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                  final isToday = date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;
                  final isFuture = date.isAfter(today);

                  return GestureDetector(
                    onTap: isFuture ? null : () => _onDayTap(date),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.ink : AppColors.paper2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isFuture
                                ? AppColors.ink4
                                : isToday
                                    ? AppColors.paper
                                    : AppColors.ink,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day stats bottom sheet
// ---------------------------------------------------------------------------

class _DayStatsSheet extends ConsumerWidget {
  const _DayStatsSheet({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsForDateProvider(date));
    final moodAsync = ref.watch(moodForDateProvider(date));

    final habits = habitsAsync.valueOrNull ?? const <HabitWithStatus>[];
    final doneCount = habits.where((h) => h.isCompleted).length;
    final totalCount = habits.length;
    final mood = moodAsync.valueOrNull;

    final moodEmoji = switch (mood?.value) {
      1 => '😔',
      2 => '😐',
      3 => '🙂',
      4 => '😊',
      5 => '😄',
      _ => null,
    };

    return FormaModalSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMMM d').format(date),
                  style: AppTextStyles.headlineLarge.copyWith(color: AppColors.ink),
                ),
              ),
              if (moodEmoji != null)
                Text(moodEmoji, style: const TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (totalCount == 0)
            Text(
              'No habits tracked this day.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink3),
            )
          else ...[
            // Progress bar
            Text(
              '$doneCount of $totalCount habits completed',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink2),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: AppBorderRadius.full,
              child: LinearProgressIndicator(
                value: totalCount > 0 ? doneCount / totalCount : 0,
                minHeight: 8,
                backgroundColor: AppColors.paper2,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sage),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Habit list
            ...habits.map((h) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text(h.habit.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          h.habit.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: h.isCompleted ? AppColors.ink : AppColors.ink3,
                            decoration: h.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      Icon(
                        h.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 18,
                        color: h.isCompleted ? AppColors.sage : AppColors.line2,
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
