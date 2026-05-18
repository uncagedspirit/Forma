import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';
import 'package:forma/core/constants/app_spacing.dart';

/// The set of emoji icons available for habit selection.
const List<String> kEmojis = [
  '💧', '🏃', '📚', '🧘', '🍎', '💪', '🌙', '☀️',
  '🎨', '🎵', '💊', '🧹', '💰', '📵', '🥗', '💤',
  '🚰', '🦷', '✍️', '🌱',
];

/// A grid picker for selecting a single emoji icon.
///
/// Displays [kEmojis] in a 5-column grid. Tapping an emoji invokes
/// [onEmojiSelected] with the chosen value. The selected emoji scales
/// up and shows an ink-coloured background circle.
class EmojiPicker extends StatelessWidget {
  const EmojiPicker({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
  });

  final String? selectedEmoji;
  final ValueChanged<String> onEmojiSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 5,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      children: kEmojis.map((emoji) {
        final isSelected = emoji == selectedEmoji;

        return _EmojiCell(
          emoji: emoji,
          isSelected: isSelected,
          onTap: () => onEmojiSelected(emoji),
        );
      }).toList(),
    );
  }
}

class _EmojiCell extends StatelessWidget {
  const _EmojiCell({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ink : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      )
          .animate(target: isSelected ? 1 : 0)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.2, 1.2),
            duration: AppDurations.normal,
            curve: Curves.easeOut,
          ),
    );
  }
}
