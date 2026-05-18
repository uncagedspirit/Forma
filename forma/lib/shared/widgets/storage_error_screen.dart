import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';

/// A full-screen error shown when Hive storage fails to open on launch.
///
/// Displays a Terra-colored error indicator, a fixed title and subtitle,
/// and an optional retry button.
class StorageErrorScreen extends StatelessWidget {
  const StorageErrorScreen({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.terraDim,
                  borderRadius: AppBorderRadius.regular,
                ),
                child: const Icon(
                  Icons.storage_outlined,
                  size: 40,
                  color: AppColors.terra,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Storage unavailable',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.ink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "We couldn't access your data. Please try again.",
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.ink2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (onRetry != null)
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
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
          ),
        ),
      ),
    );
  }
}
