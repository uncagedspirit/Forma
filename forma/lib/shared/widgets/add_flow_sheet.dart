import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/goals/data/repositories/goal_repository_provider.dart';
import 'package:forma/features/goals/domain/entities/goal.dart';
import 'package:forma/features/goals/presentation/providers/goals_provider.dart';
import 'package:forma/features/goals/presentation/widgets/add_goal_sheet.dart';
import 'package:forma/features/habits/data/repositories/habit_repository_provider.dart';
import 'package:forma/features/habits/domain/usecases/add_habit.dart';
import 'package:forma/features/habits/presentation/providers/habits_provider.dart';
import 'package:forma/features/habits/presentation/widgets/add_habit_sheet.dart';
import 'package:forma/features/home/presentation/providers/selected_date_provider.dart';
import 'package:forma/shared/widgets/forma_modal_sheet.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// Suggested goal templates
// ---------------------------------------------------------------------------

class _GoalTemplate {
  const _GoalTemplate({
    required this.emoji,
    required this.name,
    required this.colorHex,
    required this.habitSuggestions,
  });

  final String emoji;
  final String name;
  final String colorHex;
  final List<String> habitSuggestions;
}

const List<_GoalTemplate> _goalTemplates = [
  _GoalTemplate(
    emoji: '💪',
    name: 'Gain Weight',
    colorHex: '#5A7A5C',
    habitSuggestions: ['Eat protein-rich breakfast', 'Gym workout', 'Drink 3L water', 'Sleep 8 hours', 'Track calories'],
  ),
  _GoalTemplate(
    emoji: '📚',
    name: 'Read More',
    colorHex: '#A07830',
    habitSuggestions: ['Read 20 pages', 'No phone in bed', 'Visit library weekly', 'Book notes'],
  ),
  _GoalTemplate(
    emoji: '🧘',
    name: 'Better Mental Health',
    colorHex: '#B85C38',
    habitSuggestions: ['Morning meditation', 'Journal', 'Evening walk', 'Gratitude practice', 'No doom scrolling'],
  ),
  _GoalTemplate(
    emoji: '💻',
    name: 'Crack Interviews',
    colorHex: '#1C1914',
    habitSuggestions: ['Solve 1 DSA problem', 'System design study', 'Mock interview practice', 'Resume update'],
  ),
  _GoalTemplate(
    emoji: '😴',
    name: 'Better Sleep',
    colorHex: '#5A7A5C',
    habitSuggestions: ['In bed by 10:30 PM', 'No screens after 9 PM', 'Magnesium supplement', 'Wake up at 6 AM'],
  ),
  _GoalTemplate(
    emoji: '🏃',
    name: 'Get Fit',
    colorHex: '#B85C38',
    habitSuggestions: ['Run 5K', 'No junk food', 'Step count 8000', 'Stretch 10 min', 'Weekly weigh-in'],
  ),
  _GoalTemplate(
    emoji: '💰',
    name: 'Save Money',
    colorHex: '#A07830',
    habitSuggestions: ['Track expenses', 'No impulse buys', 'Cook at home', 'Monthly savings review'],
  ),
];

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

Future<void> showAddFlowSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _MainAddSheet(),
  );
}

Future<void> showAddHabitSheet(BuildContext context, {String? goalId}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => AddHabitSheet(goalId: goalId),
  );
}

// ---------------------------------------------------------------------------
// Main sheet — pick "goal" or "general habit"
// ---------------------------------------------------------------------------

class _MainAddSheet extends StatelessWidget {
  const _MainAddSheet();

  @override
  Widget build(BuildContext context) {
    return FormaModalSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'What would you like to add?',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.lg),
          _OptionCard(
            emoji: '🎯',
            title: 'Add a Goal',
            subtitle: 'Group related habits under one intention.',
            eyebrow: 'Recommended',
            onTap: () async {
              Navigator.of(context).pop();
              await Future.delayed(const Duration(milliseconds: 150));
              if (context.mounted) {
                await showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => const _SuggestedGoalsSheet(),
                );
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _OptionCard(
            emoji: '✅',
            title: 'Add a Habit',
            subtitle: 'A standalone daily habit not tied to a goal.',
            onTap: () async {
              Navigator.of(context).pop();
              await Future.delayed(const Duration(milliseconds: 150));
              if (context.mounted) {
                await showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => const AddHabitSheet(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.eyebrow,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.regular,
      child: Ink(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.paper2,
          borderRadius: AppBorderRadius.regular,
          border: Border.all(color: AppColors.line2),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null)
                    Text(
                      eyebrow!.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.terra),
                    ),
                  Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(color: AppColors.ink),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink2),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.ink3, size: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Suggested Goals sheet
// ---------------------------------------------------------------------------

class _SuggestedGoalsSheet extends ConsumerStatefulWidget {
  const _SuggestedGoalsSheet();

  @override
  ConsumerState<_SuggestedGoalsSheet> createState() => _SuggestedGoalsSheetState();
}

class _SuggestedGoalsSheetState extends ConsumerState<_SuggestedGoalsSheet> {
  _GoalTemplate? _selected;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.rLg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            20,
            AppSpacing.screenHorizontal,
            bottomInset + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.line2,
                    borderRadius: BorderRadius.circular(AppBorderRadius.rFull),
                  ),
                ),
              ),
              Text(
                'Pick a goal to start',
                style: AppTextStyles.headlineLarge.copyWith(color: AppColors.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'We\'ll suggest habits for you — add or skip any.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Template grid
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _goalTemplates.map((t) {
                  final isSelected = _selected == t;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = isSelected ? null : t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.ink : AppColors.paper2,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? AppColors.ink : AppColors.line2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(t.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            t.name,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: isSelected ? AppColors.paper : AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Predefined habits preview
              if (_selected != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Suggested habits',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.ink2),
                ),
                const SizedBox(height: AppSpacing.sm),
                ..._selected!.habitSuggestions.map((h) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 16, color: AppColors.sage),
                          const SizedBox(width: 8),
                          Text(h,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.ink)),
                        ],
                      ),
                    )),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Create with template
              if (_selected != null)
                _CreateButton(
                  label: 'Create "${_selected!.name}"',
                  onTap: () => _createFromTemplate(context, _selected!),
                ),

              // Custom goal
              const SizedBox(height: AppSpacing.sm),
              _CreateButton(
                label: 'Create custom goal',
                outlined: true,
                onTap: () async {
                  Navigator.of(context).pop();
                  await Future.delayed(const Duration(milliseconds: 150));
                  if (context.mounted) {
                    final goal = await showModalBottomSheet<Goal>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => const AddGoalSheet(),
                    );
                    if (!context.mounted || goal == null) return;
                    await showModalBottomSheet<void>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => AddHabitSheet(goalId: goal.id),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createFromTemplate(BuildContext context, _GoalTemplate template) async {
    Navigator.of(context).pop();

    try {
      final goalRepo = ref.read(goalRepositoryProvider);
      const uuid = Uuid();
      final goalId = uuid.v4();
      final goal = Goal(
        id: goalId,
        name: template.name,
        color: template.colorHex,
        sortOrder: 0,
        createdAt: DateTime.now(),
      );
      await goalRepo.save(goal);

      // Create predefined habits
      final habitRepo = ref.read(habitRepositoryProvider);
      final addHabit = AddHabit(habitRepo);
      final emojis = ['✅', '💧', '🏃', '📖', '🧘', '😴', '📝'];
      for (int i = 0; i < template.habitSuggestions.length; i++) {
        await addHabit(
          name: template.habitSuggestions[i],
          icon: emojis[i % emojis.length],
          goalId: goalId,
        );
      }

      ref.invalidate(goalsProvider);
      final selectedDate = ref.read(selectedDateProvider);
      ref.invalidate(habitsForDateProvider(selectedDate));
    } catch (e) {
      Logger('AddFlowSheet').warning('Failed to create from template', e);
    }
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : AppColors.ink,
          borderRadius: AppBorderRadius.small,
          border: outlined ? Border.all(color: AppColors.line2) : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: outlined ? AppColors.ink2 : AppColors.paper,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
