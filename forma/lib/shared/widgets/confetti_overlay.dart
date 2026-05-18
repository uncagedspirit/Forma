import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';

/// A confetti burst overlay that appears at a given screen coordinate.
///
/// Displays [particleCount] colored particles that burst outward and upward
/// from [position], then fade out. Used when a habit is completed.
///
/// To show and auto-dismiss, use [ConfettiOverlay.show]:
/// ```dart
/// ConfettiOverlay.show(context, position: offset);
/// ```
class ConfettiOverlay extends StatelessWidget {
  const ConfettiOverlay({
    super.key,
    required this.position,
    this.particleCount = 20,
  });

  final Offset position;
  final int particleCount;

  static const List<Color> _colors = [
    AppColors.sage,
    AppColors.gold,
    AppColors.terra,
    AppColors.ink,
  ];

  /// Shows a confetti burst at [position] and auto-dismisses after the
  /// animation completes.
  static void show(
    BuildContext context, {
    required Offset position,
    int particleCount = 20,
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => ConfettiOverlay(
        position: position,
        particleCount: particleCount,
      ),
    );
    overlay.insert(entry);
    Future.delayed(
      AppDurations.slow,
      entry.remove,
    );
  }

  @override
  Widget build(BuildContext context) {
    final random = Random(position.hashCode);
    final particles = List<Widget>.generate(particleCount, (index) {
      final size = 4.0 + random.nextDouble() * 4.0;
      final color = _colors[random.nextInt(_colors.length)];
      final angle = random.nextDouble() * 2 * pi;
      final distance = 40.0 + random.nextDouble() * 80.0;
      final dx = cos(angle) * distance;
      final dy = sin(angle) * distance - 40.0;
      final rotation = random.nextDouble() * 4 * pi;

      return Positioned(
        left: position.dx - size / 2,
        top: position.dy - size / 2,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        )
            .animate()
            .moveX(
              end: dx,
              duration: AppDurations.slow,
              curve: Curves.decelerate,
            )
            .moveY(
              end: dy,
              duration: AppDurations.slow,
              curve: Curves.decelerate,
            )
            .rotate(
              end: rotation,
              duration: AppDurations.slow,
            )
            .fadeOut(
              duration: AppDurations.slow * 0.8,
              delay: AppDurations.slow * 0.2,
            )
            .scale(
              end: const Offset(0, 0),
              duration: AppDurations.slow,
              curve: Curves.easeIn,
            ),
      );
    });

    return Stack(children: particles);
  }
}
