import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation bar for the Forma app.
///
/// Works with GoRouter's [ShellRoute] to provide persistent navigation
/// across the Home, Stats, and Profile tabs. Includes a center FAB that
/// navigates to the add-habit flow.
class FormaBottomNav extends StatelessWidget {
  const FormaBottomNav({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isHomeActive = location == '/' || location.startsWith('/?');
    final isStatsActive = location.startsWith('/stats');
    final isProfileActive = location.startsWith('/profile');

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
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
                    const SizedBox(width: 50),
                    Expanded(
                      child: _NavItem(
                        icon: '○',
                        label: 'Profile',
                        isActive: isProfileActive,
                        onTap: () => context.go('/profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 50,
        height: 50,
        child: FloatingActionButton(
          // TODO(T-043): Replace with AddHabitSheet modal.
          onPressed: () => context.go('/habits/add'),
          backgroundColor: AppColors.ink,
          shape: const CircleBorder(),
          child: const Text(
            '✚',
            style: TextStyle(
              color: AppColors.paper,
              fontSize: 24,
              height: 1,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
      child: SizedBox(
        height: double.infinity,
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
