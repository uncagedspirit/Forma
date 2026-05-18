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
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.paper,
            border: Border(
              top: BorderSide(color: AppColors.line2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: '▣',
                  label: 'Home',
                  isActive: isHomeActive,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: '◈',
                  label: 'Stats',
                  isActive: isStatsActive,
                  onTap: () => context.go('/stats'),
                ),
                const SizedBox(width: 48),
                _NavItem(
                  icon: '○',
                  label: 'Profile',
                  isActive: isProfileActive,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // TODO(T-043): Replace with AddHabitSheet modal.
        onPressed: () => context.go('/habits/add'),
        backgroundColor: AppColors.ink,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColors.paper),
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
    final color = isActive ? AppColors.ink : AppColors.line2;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
    );
  }
}
