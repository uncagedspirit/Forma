import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/core/router/app_router.dart';
import 'package:forma/features/goals/domain/entities/goal.dart';
import 'package:forma/features/goals/presentation/providers/goals_provider.dart';
import 'package:forma/features/habits/domain/usecases/get_habits_for_date.dart';
import 'package:forma/features/habits/presentation/providers/habit_completion_provider.dart';
import 'package:forma/features/habits/presentation/providers/habits_provider.dart';
import 'package:forma/features/home/presentation/providers/selected_date_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Color _parseHexColor(String hex) {
  try {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) {
      buffer.write('FF');
    }
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (_) {
    return AppColors.dust;
  }
}

// ---------------------------------------------------------------------------
// GoalBlock
// ---------------------------------------------------------------------------

/// A collapsible goal block widget showing goal progress and associated habits.
///
/// Displays a color-coded header with completion stats, a progress bar, and a
/// collapsible list of compact habit rows. Tapping the header expands or
/// collapses the habit list.
class GoalBlock extends ConsumerWidget {
  const GoalBlock({
    super.key,
    required this.goal,
  });

  final Goal goal;

  static final _logger = Logger('GoalBlock');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final habitsAsync = ref.watch(habitsForDateProvider(selectedDate));
    ref.watch(goalsProvider);

    final goalColor = _parseHexColor(goal.color);

    final goalHabits = habitsAsync.when(
      data: (habits) => habits.where((h) => h.habit.goalId == goal.id).toList(),
      loading: () => const <HabitWithStatus>[],
      error: (error, _) {
        _logger.warning('Failed to load habits for goal ${goal.id}', error);
        return const <HabitWithStatus>[];
      },
    );

    final doneCount = goalHabits.where((h) => h.isCompleted).length;
    final totalCount = goalHabits.length;
    final percentage =
        totalCount > 0 ? (doneCount / totalCount * 100).round() : 0;
    final progress = totalCount > 0 ? doneCount / totalCount : 0.0;

    return _GoalBlockBody(
      goal: goal,
      goalColor: goalColor,
      goalHabits: goalHabits,
      doneCount: doneCount,
      totalCount: totalCount,
      percentage: percentage,
      progress: progress,
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _GoalBlockBody extends StatefulWidget {
  const _GoalBlockBody({
    required this.goal,
    required this.goalColor,
    required this.goalHabits,
    required this.doneCount,
    required this.totalCount,
    required this.percentage,
    required this.progress,
  });

  final Goal goal;
  final Color goalColor;
  final List<HabitWithStatus> goalHabits;
  final int doneCount;
  final int totalCount;
  final int percentage;
  final double progress;

  @override
  State<_GoalBlockBody> createState() => _GoalBlockBodyState();
}

class _GoalBlockBodyState extends State<_GoalBlockBody> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: AppBorderRadius.regular,
        border: Border.all(color: AppColors.line2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            label:
                'Goal ${widget.goal.name}, ${widget.percentage}% complete',
            header: true,
            button: true,
            child: InkWell(
              onTap: _toggleExpand,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppBorderRadius.r),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.goalColor,
                        borderRadius: AppBorderRadius.small,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.goal.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${widget.doneCount}/${widget.totalCount}  ${widget.percentage}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.ink3,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.25 : 0,
                      duration: AppDurations.normal,
                      child: const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: AppColors.ink3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: ClipRRect(
              borderRadius: AppBorderRadius.full,
              child: Container(
                height: 4,
                color: AppColors.paper2,
                child: FractionallySizedBox(
                  widthFactor: widget.progress,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    color: widget.goalColor,
                  ),
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: AppDurations.normal,
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Divider(
                          height: 1,
                          color: AppColors.line,
                        ),
                        ...widget.goalHabits.map(
                          (h) => _GoalHabitRow(habitWithStatus: h),
                        ),
                        _AddHabitRow(goalId: widget.goal.id),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Goal Habit Row (compact)
// ---------------------------------------------------------------------------

class _GoalHabitRow extends ConsumerWidget {
  const _GoalHabitRow({required this.habitWithStatus});

  final HabitWithStatus habitWithStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = habitWithStatus.habit;
    final isCompleted = habitWithStatus.isCompleted;
    final selectedDate = ref.watch(selectedDateProvider);

    return InkWell(
      onTap: isCompleted
          ? null
          : () {
              ref.read(habitCompletionProvider.notifier).complete(
                    habit.id,
                    selectedDate,
                  );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Text(
              habit.icon,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                habit.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isCompleted ? AppColors.ink3 : AppColors.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _CompactCheckButton(isCompleted: isCompleted),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compact Check Button
// ---------------------------------------------------------------------------

class _CompactCheckButton extends StatelessWidget {
  const _CompactCheckButton({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isCompleted ? 'Completed' : 'Not completed',
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.sage : AppColors.paper2,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? AppColors.sage : AppColors.line2,
                width: 1.5,
              ),
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: AppColors.paper,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Habit Row
// ---------------------------------------------------------------------------

class _AddHabitRow extends StatelessWidget {
  const _AddHabitRow({required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(addHabitRoute),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.add,
              size: 18,
              color: AppColors.ink3,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Add habit to this goal',
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
