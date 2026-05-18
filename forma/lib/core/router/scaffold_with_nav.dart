import 'package:flutter/material.dart';

/// Scaffold wrapper for shell routes that displays the bottom navigation.
///
/// This is used by GoRouter's ShellRoute to provide a persistent
/// navigation shell across tab routes (home, stats, profile).
///
/// The FormaBottomNav widget will be integrated in T-031.
class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      // FormaBottomNav will be added here in T-031.
    );
  }
}
