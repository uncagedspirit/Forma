import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';

/// A reusable inline error widget used inside scroll views and columns.
///
/// Displays a warning icon, an error message, and an optional retry button
/// styled with the Terra accent color.
class InlineError extends StatelessWidget {
  const InlineError({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.terraDim,
        borderRadius: AppBorderRadius.regular,
        border: Border.all(color: AppColors.terraMid),
      ),
      child: Row(
        children: [
          const Text(
            '⚠️',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.terra,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.terra,
                  borderRadius: AppBorderRadius.small,
                ),
                child: Text(
                  'Retry',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.paper,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
