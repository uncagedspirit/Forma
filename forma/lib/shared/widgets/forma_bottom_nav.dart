import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/features/habits/presentation/widgets/add_habit_sheet.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation bar for the Forma app.
///
/// Works with GoRouter's [ShellRoute] to provide persistent navigation
/// across the Home, Stats, and Profile tabs. Includes a center FAB that
/// opens the [AddHabitSheet] modal.
///
/// Layout note: `FloatingActionButtonLocation.centerDocked` requires a
/// `BottomAppBar` to dock into. Since Forma uses a custom blurred nav bar
/// in `bottomNavigationBar`, we use `centerFloat` instead — the FAB floats
/// above the nav bar at its natural height without distorting it.
class FormaBottomNav extends StatelessWidget {
  const FormaBottomNav({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isHomeActive = location == '/' || location.startsWith('/?');
    final isStatsActive = location.startsWith('/stats');
    final isProfileActive = location.startsWith('/profile');

    // Height of the nav bar content (icon + label + vertical padding).
    // Used to ensure the FAB clears the nav bar visually.
    const double navBarContentHeight = 56;

    return Scaffold(
      // extendBody lets the scrollable body render behind the translucent nav bar.
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        // top: false so SafeArea only pads the system bottom inset, not the top.
        top: false,
        child: SizedBox(
          height: navBarContentHeight,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.paper.withValues(alpha: 0.92),
                  border: const Border(
                    top: BorderSide(color: AppColors.line2),
                  ),
                ),
                child: Row(
                  children: [
                    // Left side: Home + Stats
                    Expanded(
                      child: _NavItem(
                        icon: '▣',
                        label: 'Home',
                        isActive: isHomeActive,
                        onTap: () => context.go('/'),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: '◈',
                        label: 'Stats',
                        isActive: isStatsActive,
                        onTap: () => context.go('/stats'),
                      ),
                    ),
                    // Centre gap reserved for the floating FAB.
                    const SizedBox(width: 64),
                    // Right side: Profile
                    Expanded(
                      child: _NavItem(
                        icon: '○',
                        label: 'Profile',
                        isActive: isProfileActive,
                        onTap: () => context.go('/profile'),
                      ),
                    ),
                    // Mirror of left side to keep Profile aligned right.
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: const _AddFab(),
      // centerFloat positions the FAB at the horizontal centre of the screen,
      // floating above the bottom nav bar. It does NOT require a BottomAppBar.
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// The central add-habit FAB.
class _AddFab extends StatelessWidget {
  const _AddFab();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: FloatingActionButton(
        heroTag: 'add_habit_fab',
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          // Prevents the keyboard from covering the sheet on Android.
          useSafeArea: true,
          builder: (_) => const AddHabitSheet(),
        ),
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.paper,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Text(
          '✚',
          style: TextStyle(
            color: AppColors.paper,
            fontSize: 22,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.ink : AppColors.ink4;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox.expand(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(
                color: color,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
