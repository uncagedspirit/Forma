import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_text_styles.dart';

/// Creates the Forma TextTheme for use in ThemeData.
///
/// Maps Material Design text theme slots to Forma-specific styles.
/// See DESIGN_SYSTEM.md §3 for the complete typography specification.
class AppTypography {
  AppTypography._();

  /// Returns the light theme TextTheme.
  static TextTheme get textTheme => const TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displayMedium: AppTextStyles.displayMedium,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    titleLarge: AppTextStyles.titleLarge,
    titleMedium: AppTextStyles.titleMedium,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    labelLarge: AppTextStyles.labelLarge,
    labelSmall: AppTextStyles.labelSmall,
  );

  /// Returns the dark theme TextTheme.
  /// 
  /// Currently identical to light theme; colors are applied via ColorScheme.
  static TextTheme get darkTextTheme => textTheme;
}