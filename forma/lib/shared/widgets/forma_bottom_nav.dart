import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/shared/widgets/add_flow_sheet.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Tab definitions
// ---------------------------------------------------------------------------

class _Tab {
  const _Tab({
    required this.label,
    required this.route,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final String route;
  final IconData icon;
  final IconData activeIcon;
}

const List<_Tab> _tabs = [
  _Tab(
    label: 'Today',
    route: '/',
    icon: Icons.wb_sunny_outlined,
    activeIcon: Icons.wb_sunny,
  ),
  _Tab(
    label: 'Goals',
    route: '/goals',
    icon: Icons.flag_outlined,
    activeIcon: Icons.flag,
  ),
  _Tab(
    label: 'Calendar',
    route: '/calendar',
    icon: Icons.calendar_month_outlined,
    activeIcon: Icons.calendar_month,
  ),
  _Tab(
    label: 'Insights',
    route: '/insights',
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart,
  ),
  _Tab(
    label: 'Profile',
    route: '/profile',
    icon: Icons.person_outline,
    activeIcon: Icons.person,
  ),
];

// ---------------------------------------------------------------------------
// FormaBottomNav
// ---------------------------------------------------------------------------

/// Persistent 5-tab shell navigation bar.
/// Wraps [ShellRoute] child. FAB is owned here so it stays above the nav bar.
class FormaBottomNav extends StatelessWidget {
  const FormaBottomNav({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    int activeIndex = 0;
    if (location.startsWith('/goals')) {
      activeIndex = 1;
    } else if (location.startsWith('/calendar')) {
      activeIndex = 2;
    } else if (location.startsWith('/insights')) {
      activeIndex = 3;
    } else if (location.startsWith('/profile')) {
      activeIndex = 4;
    }

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: isKeyboardOpen
          ? null
          : SafeArea(
              top: false,
              child: SizedBox(
                height: 56,
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
                          for (int i = 0; i < _tabs.length; i++)
                            Expanded(
                              child: _NavItem(
                                tab: _tabs[i],
                                isActive: activeIndex == i,
                                onTap: () {
                                  if (activeIndex != i) {
                                    context.go(_tabs[i].route);
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: isKeyboardOpen
          ? null
          : FloatingActionButton(
              heroTag: 'forma_add_fab',
              onPressed: () => showAddFlowSheet(context),
              backgroundColor: AppColors.ink,
              foregroundColor: AppColors.paper,
              elevation: 2,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 24),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ---------------------------------------------------------------------------
// Nav item
// ---------------------------------------------------------------------------

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final _Tab tab;
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                isActive ? tab.activeIcon : tab.icon,
                key: ValueKey(isActive),
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              tab.label,
              style: AppTextStyles.labelSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
