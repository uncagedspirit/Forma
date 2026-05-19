import 'package:flutter/material.dart';

/// Text style constants for the Forma design system.
///
/// See DESIGN_SYSTEM.md §3 for the complete typography specification.
class AppTextStyles {
  AppTextStyles._();

  // Font families
  static const String _fraunces = 'Fraunces';
  static const String _instrumentSans = 'Instrument Sans';

  // Display styles (Fraunces)
  /// Page titles — Fraunces 300, 32sp
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fraunces,
    fontWeight: FontWeight.w300,
    fontSize: 32,
    height: 1.15,
  );

  /// Modal titles, section headers — Fraunces 400, 22sp
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fraunces,
    fontWeight: FontWeight.w400,
    fontSize: 22,
    height: 1.15,
  );

  /// Card titles — Fraunces 400, 18sp
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fraunces,
    fontWeight: FontWeight.w400,
    fontSize: 18,
    height: 1.15,
  );

  // Title styles (Instrument Sans)
  /// Habit names — Instrument Sans 600, 16sp
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _instrumentSans,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.5,
  );

  /// Settings rows, subtitles — Instrument Sans 500, 14sp
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _instrumentSans,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.5,
  );

  // Body styles (Instrument Sans)
  /// Body copy — Instrument Sans 400, 15sp
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _instrumentSans,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.5,
  );

  /// Secondary body — Instrument Sans 400, 13sp
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _instrumentSans,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.5,
  );

  // Label styles (Instrument Sans)
  /// Buttons, CTAs — Instrument Sans 600, 12sp
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _instrumentSans,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.5,
  );

  /// Eyebrows, badges, caps labels — Instrument Sans 600, 10sp
  /// Letter-spacing: 0.05–0.10 em for caps
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _instrumentSans,
    fontWeight: FontWeight.w600,
    fontSize: 10,
    height: 1.5,
    letterSpacing: 0.5, // ~0.05 em at 10sp
  );
}
