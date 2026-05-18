import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';

/// A mini heat-map row showing completion status for the last 7 days.
///
/// Each cell is 5×5 dp with a 2 dp gap.
/// Sage fill for completed days, [AppColors.paper3] for incomplete.
class MiniHeatRow extends StatelessWidget {
  const MiniHeatRow({
    super.key,
    required this.completionStatus,
  });

  /// List of 7 booleans representing completion for each day.
  /// Typically ordered from oldest (left) to newest (right).
  final List<bool> completionStatus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
        completionStatus.length,
        (index) {
          final isDone = completionStatus[index];
          return Container(
            width: 5,
            height: 5,
            margin: EdgeInsets.only(
              right: index < completionStatus.length - 1 ? 2 : 0,
            ),
            decoration: BoxDecoration(
              color: isDone ? AppColors.sage : AppColors.paper3,
              borderRadius: BorderRadius.circular(AppBorderRadius.rSm),
            ),
          );
        },
      ),
    );
  }
}
