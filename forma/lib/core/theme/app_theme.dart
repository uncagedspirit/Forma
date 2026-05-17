import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/theme/app_typography.dart';

/// Forma theme configuration.
///
/// Provides light and dark ThemeData instances using the Forma design system.
class AppTheme {
  AppTheme._();

  /// Light theme using the Forma design system.
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        // Primary colors
        primary: AppColors.terra,
        onPrimary: AppColors.paper,
        primaryContainer: AppColors.terraDim,
        onPrimaryContainer: AppColors.terra,
        
        // Secondary colors (using sage for success/completed states)
        secondary: AppColors.sage,
        onSecondary: AppColors.paper,
        secondaryContainer: AppColors.sageDim,
        onSecondaryContainer: AppColors.sage,
        
        // Tertiary colors (using gold for secondary goals)
        tertiary: AppColors.gold,
        onTertiary: AppColors.paper,
        tertiaryContainer: AppColors.paper2,
        onTertiaryContainer: AppColors.gold,
        
        // Surface colors (paper tones)
        surface: AppColors.paper,
        onSurface: AppColors.ink,
        surfaceContainerHighest: AppColors.paper2,
        onSurfaceVariant: AppColors.ink2,
        
        // Background colors
        surfaceContainerLowest: AppColors.paper,
        surfaceContainerLow: AppColors.paper,
        surfaceContainer: AppColors.paper2,
        surfaceContainerHigh: AppColors.paper3,
        
        // Error colors (using terra for destructive)
        error: AppColors.terra,
        onError: AppColors.paper,
        errorContainer: AppColors.terraDim,
        onErrorContainer: AppColors.terra,
        
        // Outline
        outline: AppColors.line2,
        outlineVariant: AppColors.line,
        
        // Inverse
        inverseSurface: AppColors.ink,
        onInverseSurface: AppColors.paper,
        inversePrimary: AppColors.paper,
        
        // Shadow
        shadow: AppColors.ink,
        scrim: AppColors.ink,
      ),
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.paper,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.paper,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: AppColors.line),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paper2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.ink2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.terra),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terra,
          foregroundColor: AppColors.paper,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Instrument Sans',
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink2,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontFamily: 'Instrument Sans',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.ink,
        size: 24,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.sage;
          }
          return AppColors.paper3;
        }),
        checkColor: const WidgetStatePropertyAll(AppColors.paper),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: AppColors.line2),
      ),
    );
  }

  /// Dark theme using the Forma "parchment night" design system.
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        // Primary colors (same as light)
        primary: AppColors.terra,
        onPrimary: AppColors.paperDark,
        primaryContainer: AppColors.terraDim,
        onPrimaryContainer: AppColors.terra,

        // Secondary colors (same as light)
        secondary: AppColors.sage,
        onSecondary: AppColors.paperDark,
        secondaryContainer: AppColors.sageDim,
        onSecondaryContainer: AppColors.sage,

        // Tertiary colors (same as light)
        tertiary: AppColors.gold,
        onTertiary: AppColors.paperDark,
        tertiaryContainer: AppColors.paper2Dark,
        onTertiaryContainer: AppColors.gold,

        // Surface colors (dark paper tones)
        surface: AppColors.paperDark,
        onSurface: AppColors.inkDark,
        surfaceContainerHighest: AppColors.paper2Dark,
        onSurfaceVariant: AppColors.ink2Dark,

        // Background colors
        surfaceContainerLowest: AppColors.paperDark,
        surfaceContainerLow: AppColors.paperDark,
        surfaceContainer: AppColors.paper2Dark,
        surfaceContainerHigh: AppColors.paper3Dark,

        // Error colors (same as light)
        error: AppColors.terra,
        onError: AppColors.paperDark,
        errorContainer: AppColors.terraDim,
        onErrorContainer: AppColors.terra,

        // Outline (inverted for dark mode)
        outline: AppColors.ink3Dark,
        outlineVariant: Color(0x806A6258), // ink3Dark with 50% opacity

        // Inverse (inverted from light)
        inverseSurface: AppColors.paper,
        onInverseSurface: AppColors.ink,
        inversePrimary: AppColors.terra,

        // Shadow
        shadow: AppColors.inkDark,
        scrim: AppColors.inkDark,
      ),
      textTheme: AppTypography.darkTextTheme,
      scaffoldBackgroundColor: AppColors.paperDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paperDark,
        foregroundColor: AppColors.inkDark,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.paperDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: AppColors.ink3Dark),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.paperDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.ink3Dark.withAlpha(128),
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paper2Dark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.ink3Dark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.ink3Dark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.ink2Dark),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.terra),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terra,
          foregroundColor: AppColors.paperDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Instrument Sans',
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink2Dark,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontFamily: 'Instrument Sans',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.inkDark,
        size: 24,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.sage;
          }
          return AppColors.paper3Dark;
        }),
        checkColor: const WidgetStatePropertyAll(AppColors.paperDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: AppColors.ink3Dark),
      ),
    );
  }
}