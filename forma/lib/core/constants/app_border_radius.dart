import 'package:flutter/material.dart';

/// Border radius constants for the Forma design system.
///
/// See DESIGN_SYSTEM.md §6 for the complete border radius specification.
class AppBorderRadius {
  AppBorderRadius._();

  /// 8 dp — Buttons, inputs, small chips
  static const double rSm = 8;

  /// 14 dp — Cards, goal blocks, modals
  static const double r = 14;

  /// 20 dp — Bottom sheet corners
  static const double rLg = 20;

  /// 999 dp — Pills, badges, checkboxes
  static const double rFull = 999;

  // BorderRadius objects for convenience

  /// 8 dp radius — Buttons, inputs, small chips
  static BorderRadius get small => BorderRadius.circular(rSm);

  /// 14 dp radius — Cards, goal blocks, modals
  static BorderRadius get regular => BorderRadius.circular(r);

  /// 20 dp radius — Bottom sheet corners
  static BorderRadius get large => BorderRadius.circular(rLg);

  /// 999 dp radius — Pills, badges, checkboxes
  static BorderRadius get full => BorderRadius.circular(rFull);
}