import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/habits/presentation/providers/habits_provider.dart';
import 'package:forma/features/home/presentation/providers/selected_date_provider.dart';
import 'package:intl/intl.dart';

/// A horizontal strip of 7 date chips (3 past + today + 3 future)
/// centered around the currently selected date.
class DateStrip extends ConsumerWidget {
  const DateStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final normalizedSelected = _normalizeDate(selectedDate);
    final today = _normalizeDate(DateTime.now());

    final dates = List.generate(
      7,
      (index) => normalizedSelected.subtract(Duration(days: 3 - index)),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dates.map((date) {
            return _DateChip(
              date: date,
              today: today,
              isSelected: _isSameDay(date, normalizedSelected),
            );
          }).toList(),
        ),
      ),
    );
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DateChip extends ConsumerWidget {
  const _DateChip({
    required this.date,
    required this.today,
    required this.isSelected,
  });

  final DateTime date;
  final DateTime today;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsForDateProvider(date));
    final hasCompletions = habitsAsync.maybeWhen(
      data: (habits) => habits.any((h) => h.isCompleted),
      orElse: () => false,
    );

    final isToday = DateStrip._isSameDay(date, today);
    final isPast = date.isBefore(today);

    final Color backgroundColor;
    final Color textColor;
    final BoxBorder? border;

    if (isToday) {
      backgroundColor = AppColors.ink;
      textColor = AppColors.paper;
      border = null;
    } else if (isPast) {
      backgroundColor = AppColors.paper2;
      textColor = AppColors.ink;
      border = Border.all(color: AppColors.line2);
    } else {
      backgroundColor = Colors.transparent;
      textColor = AppColors.ink;
      border = null;
    }

    final effectiveBorder = isSelected && !isToday
        ? Border.all(color: AppColors.ink)
        : border;

    final dotColor = isToday ? AppColors.paper : AppColors.sage;

    final dayLetter = DateFormat.E().format(date);
    final dayNumber = date.day.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: GestureDetector(
        onTap: () => ref.read(selectedDateProvider.notifier).select(date),
        child: Container(
          width: 48,
          height: 64,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppBorderRadius.small,
            border: effectiveBorder,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayLetter,
                style: AppTextStyles.labelSmall.copyWith(color: textColor),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                dayNumber,
                style: AppTextStyles.titleLarge.copyWith(color: textColor),
              ),
              const SizedBox(height: AppSpacing.xs),
              if (hasCompletions)
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
