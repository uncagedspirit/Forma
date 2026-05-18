import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';
import 'package:forma/core/constants/app_spacing.dart';

/// A reusable bottom sheet wrapper for the Forma app.
///
/// Provides a handle bar, consistent padding, rounded top corners,
/// and a spring animation when appearing. Used by AddHabitSheet,
/// AddGoalSheet, and HabitDetailSheet.
///
/// To display, use [showFormaModalSheet]:
/// ```dart
/// showFormaModalSheet(
///   context: context,
///   builder: (context) => const MySheetContent(),
/// );
/// ```
class FormaModalSheet extends StatelessWidget {
  const FormaModalSheet({
    super.key,
    required this.child,
    this.showHandle = true,
  });

  final Widget child;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHandle) const _HandleBar(),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppBorderRadius.rLg),
                  topRight: Radius.circular(AppBorderRadius.rLg),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                20,
                AppSpacing.screenHorizontal,
                40,
              ),
              child: child,
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideY(
          begin: 0.2,
          end: 0,
          duration: AppDurations.normal,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: AppDurations.normal);
  }
}

class _HandleBar extends StatelessWidget {
  const _HandleBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Center(
        child: Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.line2,
            borderRadius: BorderRadius.circular(AppBorderRadius.rFull),
          ),
        ),
      ),
    );
  }
}

/// Displays a [FormaModalSheet] via [showModalBottomSheet].
///
/// The sheet is scroll controlled and has a transparent background so
/// [FormaModalSheet] can render its own [AppColors.paper] surface.
Future<T?> showFormaModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => FormaModalSheet(
      child: builder(context),
    ),
  );
}
