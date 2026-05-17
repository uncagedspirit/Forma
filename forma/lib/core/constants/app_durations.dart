/// Animation duration constants for the Forma design system.
///
/// See CODING_STYLE.md §8 for animation guidelines.
class AppDurations {
  AppDurations._();

  /// 150 ms — Micro-interactions, quick feedback
  static const Duration fast = Duration(milliseconds: 150);

  /// 300 ms — Standard transitions, most animations
  static const Duration normal = Duration(milliseconds: 300);

  /// 600 ms — Slower emphasis animations
  static const Duration slow = Duration(milliseconds: 600);

  /// 800 ms — Spring animations (progress ring, check button)
  static const Duration spring = Duration(milliseconds: 800);
}