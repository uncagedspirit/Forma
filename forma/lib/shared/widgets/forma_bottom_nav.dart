import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/shared/widgets/add_flow_sheet.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation bar for the Forma app.
///
/// Works with GoRouter's [ShellRoute] to provide persistent navigation
/// across the Home, Stats, and Profile tabs. Includes a center FAB that
/// opens the goal-first add flow.
class FormaBottomNav extends StatelessWidget {
  const FormaBottomNav({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isHomeActive = location == '/' || location.startsWith('/?');
    final isStatsActive = location.startsWith('/stats');
    final isProfileActive = location.startsWith('/profile');
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    const double navBarContentHeight = 56;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: isKeyboardOpen
          ? null
          : SafeArea(
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
                          Expanded(
                            child: _NavItem(
                              icon: '\u25A3',
                              label: 'Home',
                              isActive: isHomeActive,
                              onTap: () => context.go('/'),
                            ),
                          ),
                          Expanded(
                            child: _NavItem(
                              icon: '\u25C8',
                              label: 'Stats',
                              isActive: isStatsActive,
                              onTap: () => context.go('/stats'),
                            ),
                          ),
                          const SizedBox(width: 64),
                          Expanded(
                            child: _NavItem(
                              icon: '\u25CB',
                              label: 'Profile',
                              isActive: isProfileActive,
                              onTap: () => context.go('/profile'),
                            ),
                          ),
                          const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: isKeyboardOpen ? null : const _AddFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _AddFab extends StatelessWidget {
  const _AddFab();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: FloatingActionButton(
        heroTag: 'add_habit_fab',
        onPressed: () => showAddFlowSheet(context),
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.paper,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Text(
          '\u271A',
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
