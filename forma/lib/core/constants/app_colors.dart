import 'package:flutter/material.dart';

/// Color tokens for the Forma design system.
/// 
/// All colors are defined as static const to allow compile-time optimization
/// and ensure consistency across the app.
/// 
/// See DESIGN_SYSTEM.md §2 for the complete color palette specification.
class AppColors {
  AppColors._();

  // Base (Paper tones)
  /// Primary background, card surfaces
  static const Color paper = Color(0xFFF5F0E8);
  
  /// Secondary surface, input fields
  static const Color paper2 = Color(0xFFEDE8DF);
  
  /// Tertiary surface, dividers, app bg
  static const Color paper3 = Color(0xFFE4DDD2);

  // Ink (Text hierarchy)
  /// Primary text, icons
  static const Color ink = Color(0xFF1C1914);
  
  /// Secondary text, body
  static const Color ink2 = Color(0xFF5C5649);
  
  /// Tertiary text, placeholders, labels
  static const Color ink3 = Color(0xFF9B9488);
  
  /// Disabled state, subtle borders
  static const Color ink4 = Color(0xFFC4BEB4);

  // Accent (Sparingly)
  /// Primary brand, CTAs, destructive/alert
  static const Color terra = Color(0xFFB85C38);
  
  /// Success, completed, positive
  static const Color sage = Color(0xFF5A7A5C);
  
  /// Secondary goals, reading goal color
  static const Color gold = Color(0xFFA07830);
  
  /// Neutral accent, progress bars
  static const Color dust = Color(0xFF8C7B6A);

  // Activity Graph (4 shades + empty)
  /// No habits or 0% completion
  static const Color graphNone = Color(0xFFE4DDD2);
  
  /// > 0%, ≤ 25% done
  static const Color graphLight = Color(0xFFB8D4B8);
  
  /// > 25%, ≤ 60% done
  static const Color graphMedium = Color(0xFF7AAD7A);
  
  /// > 60%, < 100% done
  static const Color graphDark = Color(0xFF4A8C4A);
  
  /// 100% done — all habits
  static const Color graphFull = Color(0xFF2D6E2D);

  // Semantic
  /// Default dividers — rgba(28,25,20,0.08)
  static const Color line = Color(0x141C1914);
  
  /// Stronger borders — rgba(28,25,20,0.14)
  static const Color line2 = Color(0x241C1914);
  
  /// Terra background tint — rgba(184,92,56,0.10)
  static const Color terraDim = Color(0x1AB85C38);
  
  /// Terra border tint — rgba(184,92,56,0.25)
  static const Color terraMid = Color(0x40B85C38);
  
  /// Sage background tint — rgba(90,122,92,0.10)
  static const Color sageDim = Color(0x1A5A7A5C);
  
  /// Sage border tint — rgba(90,122,92,0.20)
  static const Color sageMid = Color(0x335A7A5C);

  /// Returns all colors defined in this class.
  /// Used for testing to verify no duplicates.
  static List<Color> get allColors => const [
    paper,
    paper2,
    paper3,
    ink,
    ink2,
    ink3,
    ink4,
    terra,
    sage,
    gold,
    dust,
    graphNone,
    graphLight,
    graphMedium,
    graphDark,
    graphFull,
    line,
    line2,
    terraDim,
    terraMid,
    sageDim,
    sageMid,
  ];
}