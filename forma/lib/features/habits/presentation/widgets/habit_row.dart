import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/habits/data/repositories/habit_repository_provider.dart';
import 'package:forma/features/habits/domain/entities/habit_log.dart';
import 'package:forma/features/habits/domain/usecases/delete_habit.dart';
import 'package:forma/features/habits/domain/usecases/get_habits_for_date.dart';
import 'package:forma/features/habits/presentation/providers/habit_completion_provider.dart';
import 'package:forma/features/habits/presentation/providers/habit_logs_provider.dart';
import 'package:forma/features/habits/presentation/providers/habits_provider.dart';
import 'package:forma/features/habits/presentation/widgets/mini_heat_row.dart';
import 'package:forma/features/home/presentation/providers/selected_date_provider.dart';
import 'package:forma/shared/widgets/confetti_overlay.dart';
import 'package:forma/shared/widgets/forma_modal_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

int _computeStreak(List<HabitLog> logs, DateTime referenceDate) {
  final normalizedReference = DateTime.utc(
    referenceDate.year,
    referenceDate.month,
    referenceDate.day,
  );
  final completedDates = logs
      .map(
        (l) => DateTime.utc(l.date.year, l.date.month, l.date.day),
      )
      .toSet();

  var streak = 0;
  var current = normalizedReference;

  if (completedDates.contains(current)) {
    streak++;
    current = current.subtract(const Duration(days: 1));
  }

  while (completedDates.contains(current)) {
    streak++;
    current = current.subtract(const Duration(days: 1));
  }

  return streak;
}

bool _isVoid(List<HabitLog> logs, DateTime referenceDate) {
  if (logs.isEmpty) return true;
  final normalizedReference = DateTime.utc(
    referenceDate.year,
    referenceDate.month,
    referenceDate.day,
  );
  final lastLogDate = logs
      .map((l) => DateTime.utc(l.date.year, l.date.month, l.date.day))
      .reduce((a, b) => a.isAfter(b) ? a : b);
  final daysSince = normalizedReference.difference(lastLogDate).inDays;
  return daysSince >= 3;
}

List<bool> _computeHeatMap(List<HabitLog> logs, DateTime referenceDate) {
  final normalizedReference = DateTime.utc(
    referenceDate.year,
    referenceDate.month,
    referenceDate.day,
  );
  final completedDates = logs
      .map((l) => DateTime.utc(l.date.year, l.date.month, l.date.day))
      .toSet();

  return List.generate(7, (i) {
    final date = normalizedReference.subtract(Duration(days: 6 - i));
    return completedDates.contains(date);
  });
}

// ---------------------------------------------------------------------------
// HabitRow
// ---------------------------------------------------------------------------

/// The main habit row widget used in the home screen habit list.
///
/// Displays an emoji icon, habit name, streak + [MiniHeatRow], and a check
/// button. Long-pressing reveals an options bottom sheet.
class HabitRow extends ConsumerWidget {
  const HabitRow({
    super.key,
    required this.habitWithStatus,
  });

  final HabitWithStatus habitWithStatus;

  static final _logger = Logger('HabitRow');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final logsAsync = ref.watch(habitLogsProvider(habitWithStatus.habit.id));

    final logs = logsAsync.when(
      data: (logs) => logs,
      loading: () => const <HabitLog>[],
      error: (error, _) {
        _logger.warning(
          'Failed to load logs for habit ${habitWithStatus.habit.id}',
          error,
        );
        return const <HabitLog>[];
      },
    );
    final streak = _computeStreak(logs, selectedDate);
    final isVoid = _isVoid(logs, selectedDate);
    final heatMap = _computeHeatMap(logs, selectedDate);

    return _HabitRowBody(
      habitWithStatus: habitWithStatus,
      streak: streak,
      isVoid: isVoid,
      heatMap: heatMap,
      onComplete: () => _handleComplete(ref, selectedDate),
      onLongPress: () => _showOptionsBottomSheet(context, ref),
    );
  }

  void _handleComplete(WidgetRef ref, DateTime selectedDate) {
    ref.read(habitCompletionProvider.notifier).complete(
          habitWithStatus.habit.id,
          selectedDate,
        );
  }

  void _showOptionsBottomSheet(BuildContext context, WidgetRef ref) {
    showFormaModalSheet(
      context: context,
      builder: (_) => _HabitOptionsSheet(
        habitId: habitWithStatus.habit.id,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _HabitRowBody extends StatelessWidget {
  const _HabitRowBody({
    required this.habitWithStatus,
    required this.streak,
    required this.isVoid,
    required this.heatMap,
    required this.onComplete,
    required this.onLongPress,
  });

  final HabitWithStatus habitWithStatus;
  final int streak;
  final bool isVoid;
  final List<bool> heatMap;
  final VoidCallback onComplete;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final habit = habitWithStatus.habit;
    final isCompleted = habitWithStatus.isCompleted;

    return InkWell(
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.sm,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.line),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: FittedBox(
                  child: Text(
                    habit.icon,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          habit.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      if (isVoid)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.terraDim,
                            borderRadius: AppBorderRadius.small,
                          ),
                          child: Text(
                            'void',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.terra,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      MiniHeatRow(completionStatus: heatMap),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          '$streak ${streak == 1 ? 'day' : 'days'}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.ink3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Semantics(
              label: isCompleted
                  ? 'Habit ${habit.name} completed'
                  : 'Complete habit ${habit.name}',
              button: true,
              child: _CheckButton(
                isCompleted: isCompleted,
                onTap: isCompleted ? null : onComplete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Check Button
// ---------------------------------------------------------------------------

class _CheckButton extends StatefulWidget {
  const _CheckButton({
    required this.isCompleted,
    this.onTap,
  });

  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  State<_CheckButton> createState() => _CheckButtonState();
}

class _CheckButtonState extends State<_CheckButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.onTap == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final offset = renderBox.localToGlobal(Offset.zero);
      final center = offset.translate(
        renderBox.size.width / 2,
        renderBox.size.height / 2,
      );
      ConfettiOverlay.show(context, position: center);
    }

    _controller.forward(from: 0).then((_) {
      if (mounted) {
        widget.onTap!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.isCompleted;

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              final scale = _controller.status == AnimationStatus.forward
                  ? _scaleAnimation.value
                  : 1.0;
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isDone ? AppColors.sage : AppColors.paper2,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? AppColors.sage : AppColors.line2,
                  width: 1.5,
                ),
              ),
              child: isDone
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.paper,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Options Bottom Sheet
// ---------------------------------------------------------------------------

class _HabitOptionsSheet extends ConsumerWidget {
  const _HabitOptionsSheet({required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Options',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.ink,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        _OptionTile(
          label: 'Skip today',
          onTap: () => Navigator.of(context).pop(),
        ),
        _OptionTile(
          label: 'Edit',
          onTap: () {
            final router = GoRouter.of(context);
            Navigator.of(context).pop();
            router.push('/habits/$habitId');
          },
        ),
        _OptionTile(
          label: 'Delete',
          textColor: AppColors.terra,
          onTap: () async {
            final repo = ref.read(habitRepositoryProvider);
            final selectedDate = ref.read(selectedDateProvider);
            await DeleteHabit(repo).call(habitId);
            if (context.mounted) {
              Navigator.of(context).pop();
              ref.invalidate(habitsForDateProvider(selectedDate));
              ref.invalidate(habitLogsProvider(habitId));
            }
          },
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    this.textColor,
    this.onTap,
  });

  final String label;
  final Color? textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          label,
          style: AppTextStyles.titleMedium.copyWith(
            color: textColor ?? AppColors.ink,
          ),
        ),
      ),
    );
  }
}
