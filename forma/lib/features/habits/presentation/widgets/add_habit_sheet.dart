import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/goals/domain/entities/goal.dart';
import 'package:forma/features/goals/presentation/providers/goals_provider.dart';
import 'package:forma/features/habits/data/repositories/habit_repository_provider.dart';
import 'package:forma/features/habits/domain/usecases/add_habit.dart';
import 'package:forma/features/habits/presentation/providers/habits_provider.dart';
import 'package:forma/features/home/presentation/providers/selected_date_provider.dart';
import 'package:forma/shared/widgets/emoji_picker.dart';
import 'package:forma/shared/widgets/forma_text_field.dart';
import 'package:logging/logging.dart';

// ---------------------------------------------------------------------------
// AddHabitSheet
// ---------------------------------------------------------------------------

/// A bottom sheet for adding a new habit.
///
/// Fully scrollable so it doesn't overflow when the keyboard is open.
class AddHabitSheet extends ConsumerStatefulWidget {
  const AddHabitSheet({super.key, this.goalId});

  /// Optional pre-selected goal ID.
  final String? goalId;

  @override
  ConsumerState<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<AddHabitSheet> {
  static final _logger = Logger('AddHabitSheet');

  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  String? _selectedEmoji;
  String _selectedTimeOfDay = 'Anytime';
  String? _selectedGoalId;
  String? _nameError;
  bool _isSubmitting = false;

  static const Map<String, String?> _timeToReminder = {
    'Morning': '08:00',
    'Afternoon': '14:00',
    'Evening': '20:00',
    'Anytime': null,
  };

  @override
  void initState() {
    super.initState();
    _selectedGoalId = widget.goalId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _onEmojiSelected(String emoji) {
    setState(() => _selectedEmoji = emoji);
  }

  void _onTimeSelected(String time) {
    setState(() => _selectedTimeOfDay = time);
  }

  void _onGoalSelected(String? goalId) {
    setState(() => _selectedGoalId = goalId);
  }

  void _onNameChanged(String value) {
    if (_nameError != null) {
      setState(() => _nameError = null);
    }
  }

  Future<void> _onSubmit() async {
    // Dismiss keyboard first
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _nameError = 'Habit name cannot be empty');
      return;
    }

    final emoji = _selectedEmoji ?? kEmojis.first;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(habitRepositoryProvider);
      final addHabit = AddHabit(repo);
      final reminderTime = _timeToReminder[_selectedTimeOfDay];

      await addHabit(
        name: name,
        icon: emoji,
        goalId: _selectedGoalId,
        reminderTime: reminderTime,
      );

      final selectedDate = ref.read(selectedDateProvider);
      ref.invalidate(habitsForDateProvider(selectedDate));
      ref.invalidate(goalsProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on ArgumentError catch (e) {
      _logger.warning('Validation failed when adding habit', e);
      setState(() => _nameError = e.message.toString());
    } catch (e) {
      _logger.warning('Failed to add habit', e);
      setState(() => _nameError = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsProvider);
    final goals = goalsAsync.when(
      data: (g) => g,
      loading: () => const <Goal>[],
      error: (error, _) {
        _logger.warning('Failed to load goals for dropdown', error);
        return const <Goal>[];
      },
    );

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.rLg),
          topRight: Radius.circular(AppBorderRadius.rLg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            20,
            AppSpacing.screenHorizontal,
            bottomInset + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
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
                'New Habit',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.ink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FormaTextField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                placeholder: 'e.g. Drink 8 glasses of water',
                error: _nameError,
                onChanged: _onNameChanged,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onSubmit(),
              ),
              const SizedBox(height: AppSpacing.md),
              EmojiPicker(
                selectedEmoji: _selectedEmoji,
                onEmojiSelected: _onEmojiSelected,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Time of day',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.ink2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _TimeOfDayChips(
                selectedTime: _selectedTimeOfDay,
                onSelected: _onTimeSelected,
              ),
              if (goals.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _GoalDropdown(
                  goals: goals,
                  selectedGoalId: _selectedGoalId,
                  onChanged: _onGoalSelected,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _SubmitButton(
                isSubmitting: _isSubmitting,
                onPressed: _isSubmitting ? null : _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Time of Day Chips
// ---------------------------------------------------------------------------

class _TimeOfDayChips extends StatelessWidget {
  const _TimeOfDayChips({
    required this.selectedTime,
    required this.onSelected,
  });

  final String selectedTime;
  final ValueChanged<String> onSelected;

  static const List<String> _options = [
    'Morning',
    'Afternoon',
    'Evening',
    'Anytime',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _options.map((time) {
        final isSelected = time == selectedTime;
        return _TimeChip(
          label: time,
          isSelected: isSelected,
          onTap: () => onSelected(time),
        );
      }).toList(),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ink : AppColors.paper2,
          borderRadius: AppBorderRadius.full,
          border: Border.all(
            color: isSelected ? AppColors.ink : AppColors.line2,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: isSelected ? AppColors.paper : AppColors.ink2,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Goal Dropdown
// ---------------------------------------------------------------------------

class _GoalDropdown extends StatelessWidget {
  const _GoalDropdown({
    required this.goals,
    required this.selectedGoalId,
    required this.onChanged,
  });

  final List<Goal> goals;
  final String? selectedGoalId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDropdown(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.paper,
          border: Border.all(color: AppColors.line2, width: 1),
          borderRadius: AppBorderRadius.small,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getDisplayLabel(),
              style: AppTextStyles.bodyLarge.copyWith(
                color: selectedGoalId == null ? AppColors.ink3 : AppColors.ink,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }

  String _getDisplayLabel() {
    if (selectedGoalId == null) return 'Assign to goal (optional)';
    return goals.firstWhere((g) => g.id == selectedGoalId).name;
  }

  void _openDropdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.rLg),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 3,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.line2,
                borderRadius: BorderRadius.circular(AppBorderRadius.rFull),
              ),
            ),
            ListTile(
              title: Text(
                'No goal',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink3),
              ),
              onTap: () {
                onChanged(null);
                Navigator.pop(context);
              },
            ),
            ...goals.map((goal) {
              return ListTile(
                title: Text(
                  goal.name,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink),
                ),
                onTap: () {
                  onChanged(goal.id);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Submit Button
// ---------------------------------------------------------------------------

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.onPressed,
    this.isSubmitting = false,
  });

  final VoidCallback? onPressed;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: onPressed == null ? AppColors.ink4 : AppColors.ink,
          borderRadius: AppBorderRadius.small,
        ),
        child: isSubmitting
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.paper,
                  ),
                ),
              )
            : Text(
                'Create Habit',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.paper,
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
