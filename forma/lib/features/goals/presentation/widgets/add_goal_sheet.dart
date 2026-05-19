import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/goals/data/repositories/goal_repository_provider.dart';
import 'package:forma/features/goals/domain/entities/goal.dart';
import 'package:forma/features/goals/domain/repositories/goal_repository.dart';
import 'package:forma/features/goals/presentation/providers/goals_provider.dart';
import 'package:forma/shared/widgets/forma_modal_sheet.dart';
import 'package:forma/shared/widgets/forma_text_field.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// Color options
// ---------------------------------------------------------------------------

class _ColorOption {
  const _ColorOption({required this.color, required this.hex});

  final Color color;
  final String hex;
}

const List<_ColorOption> _colorOptions = [
  _ColorOption(color: AppColors.sage, hex: '#5A7A5C'),
  _ColorOption(color: AppColors.gold, hex: '#A07830'),
  _ColorOption(color: AppColors.terra, hex: '#B85C38'),
  _ColorOption(color: AppColors.ink, hex: '#1C1914'),
  _ColorOption(color: AppColors.dust, hex: '#8C7B6A'),
  _ColorOption(color: AppColors.paper3, hex: '#E4DDD2'),
];

// ---------------------------------------------------------------------------
// AddGoalSheet
// ---------------------------------------------------------------------------

/// A bottom sheet for adding a new goal.
///
/// Wraps its content in [FormaModalSheet] and provides fields for goal name
/// and color selection.
///
/// Pops with the created [Goal] so callers can continue into a follow-up flow.
///
/// Call via [showModalBottomSheet] or [showFormaModalSheet]:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   backgroundColor: Colors.transparent,
///   isScrollControlled: true,
///   builder: (_) => const AddGoalSheet(),
/// );
/// ```
class AddGoalSheet extends ConsumerStatefulWidget {
  const AddGoalSheet({super.key});

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  static final _logger = Logger('AddGoalSheet');

  final TextEditingController _nameController = TextEditingController();
  String? _selectedColorHex;
  String? _nameError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedColorHex = _colorOptions.first.hex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onColorSelected(String hex) {
    setState(() => _selectedColorHex = hex);
  }

  void _onNameChanged(String value) {
    if (_nameError != null) {
      setState(() => _nameError = null);
    }
  }

  Future<void> _onSubmit() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _nameError = 'Goal name cannot be empty');
      return;
    }

    final color = _selectedColorHex ?? _colorOptions.first.hex;

    setState(() => _isSubmitting = true);

    try {
      final GoalRepository repo = ref.read(goalRepositoryProvider);
      const uuid = Uuid();
      final id = uuid.v4();

      final goal = Goal(
        id: id,
        name: name,
        color: color,
        sortOrder: 0,
        createdAt: DateTime.now(),
      );

      await repo.save(goal);

      ref.invalidate(goalsProvider);

      if (mounted) {
        Navigator.of(context).pop(goal);
      }
    } catch (e) {
      _logger.warning('Failed to add goal', e);
      setState(() => _nameError = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = _selectedColorHex;
    final isSubmitting = _isSubmitting;

    return FormaModalSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New Goal',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          FormaTextField(
            controller: _nameController,
            placeholder: 'Goal name',
            error: _nameError,
            onChanged: _onNameChanged,
            autofocus: true,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Color',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.ink2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ColorPicker(
            selectedColor: selectedColor,
            onColorSelected: _onColorSelected,
          ),
          const SizedBox(height: AppSpacing.lg),
          _SubmitButton(
            onPressed: isSubmitting ? null : _onSubmit,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Color Picker
// ---------------------------------------------------------------------------

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.selectedColor,
    required this.onColorSelected,
  });

  final String? selectedColor;
  final ValueChanged<String> onColorSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _colorOptions.map((option) {
        final isSelected = option.hex == selectedColor;
        return GestureDetector(
          onTap: () => onColorSelected(option.hex),
          child: Transform.scale(
            scale: isSelected ? 1.1 : 1.0,
            child: AnimatedContainer(
              duration: AppDurations.fast,
              curve: Curves.easeInOut,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: option.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.ink : AppColors.line2,
                  width: isSelected ? 2 : 1,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Submit Button
// ---------------------------------------------------------------------------

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed});

  final VoidCallback? onPressed;

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
        child: Text(
          'Create Goal',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.paper,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
