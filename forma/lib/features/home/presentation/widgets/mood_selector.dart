import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/features/home/presentation/providers/selected_date_provider.dart';
import 'package:forma/features/mood/domain/entities/mood_entry.dart';
import 'package:forma/features/mood/presentation/providers/log_mood_provider.dart';
import 'package:forma/features/mood/presentation/providers/mood_provider.dart';
import 'package:forma/shared/widgets/forma_text_field.dart';

/// A mood selector widget with 5 emoji dots and an optional note input.
///
/// Watches moodForDateProvider to restore the selection for the current date.
/// When a mood dot is tapped, a note input appears. On submit or dismiss,
/// the mood is logged via logMoodNotifierProvider.
class MoodSelector extends ConsumerWidget {
  const MoodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final moodAsync = ref.watch(moodForDateProvider(selectedDate));
    final moodEntry = moodAsync.valueOrNull;

    return _MoodSelectorBody(
      selectedDate: selectedDate,
      moodEntry: moodEntry,
      onLogMood: (int value, String? note) {
        ref
            .read(logMoodNotifierProvider.notifier)
            .log(selectedDate, value, note);
      },
    );
  }
}

class _MoodSelectorBody extends StatefulWidget {
  const _MoodSelectorBody({
    required this.selectedDate,
    this.moodEntry,
    required this.onLogMood,
  });

  final DateTime selectedDate;
  final MoodEntry? moodEntry;
  final void Function(int value, String? note) onLogMood;

  @override
  State<_MoodSelectorBody> createState() => _MoodSelectorBodyState();
}

class _MoodSelectorBodyState extends State<_MoodSelectorBody> {
  int? _tappedValue;
  bool _showNoteInput = false;
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _noteFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_MoodSelectorBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      _clearState();
    }
  }

  @override
  void dispose() {
    _noteFocusNode.removeListener(_onFocusChange);
    _noteFocusNode.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_noteFocusNode.hasFocus && _showNoteInput && mounted) {
      // Only submit if the note field has actual content
      final trimmedNote = _noteController.text.trim();
      if (trimmedNote.isNotEmpty) {
        _submitMood();
      } else {
        // Clear the input without submitting if note is empty
        _showNoteInput = false;
      }
    }
  }

  void _clearState() {
    setState(() {
      _tappedValue = null;
      _showNoteInput = false;
      _noteController.clear();
    });
  }

  void _onMoodTap(int value) {
    setState(() {
      _tappedValue = value;
      _showNoteInput = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _noteFocusNode.requestFocus();
      }
    });
  }

  void _submitMood() {
    if (_tappedValue == null) return;
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();
    widget.onLogMood(_tappedValue!, note);
    _clearState();
  }

  @override
  Widget build(BuildContext context) {
    final int? activeValue = _tappedValue ?? widget.moodEntry?.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MoodDot(
              emoji: '😢',
              label: 'Very bad',
              value: 1,
              isSelected: activeValue == 1,
              onTap: () => _onMoodTap(1),
            ),
            const SizedBox(width: AppSpacing.md),
            _MoodDot(
              emoji: '😟',
              label: 'Bad',
              value: 2,
              isSelected: activeValue == 2,
              onTap: () => _onMoodTap(2),
            ),
            const SizedBox(width: AppSpacing.md),
            _MoodDot(
              emoji: '😐',
              label: 'Okay',
              value: 3,
              isSelected: activeValue == 3,
              onTap: () => _onMoodTap(3),
            ),
            const SizedBox(width: AppSpacing.md),
            _MoodDot(
              emoji: '🙂',
              label: 'Good',
              value: 4,
              isSelected: activeValue == 4,
              onTap: () => _onMoodTap(4),
            ),
            const SizedBox(width: AppSpacing.md),
            _MoodDot(
              emoji: '😄',
              label: 'Great',
              value: 5,
              isSelected: activeValue == 5,
              onTap: () => _onMoodTap(5),
            ),
          ],
        ),
        if (_showNoteInput) ...[
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: FormaTextField(
              controller: _noteController,
              placeholder: 'How are you feeling?',
              focusNode: _noteFocusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitMood(),
            ),
          ),
        ],
      ],
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _MoodDot extends StatelessWidget {
  const _MoodDot({
    required this.emoji,
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Mood $value: $label',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppDurations.normal,
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.paper : AppColors.paper2,
            shape: BoxShape.circle,
            border: isSelected ? Border.all(color: AppColors.ink) : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: AppDurations.normal,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
