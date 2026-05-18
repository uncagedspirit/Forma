import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/core/router/app_router.dart';
import 'package:forma/features/premium/presentation/providers/premium_status_provider.dart';
import 'package:forma/features/profile/presentation/providers/user_preferences_provider.dart';
import 'package:forma/features/stats/presentation/providers/stats_provider.dart';
import 'package:forma/shared/widgets/forma_modal_sheet.dart';
import 'package:forma/shared/widgets/inline_error.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// The profile screen for the Forma habit tracker app.
///
/// Displays the user's avatar, name, membership date, streak,
/// a premium upsell block, and settings rows.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final isPremium = ref.watch(premiumStatusProvider);
    final statsAsync = ref.watch(statsProvider);

    final hasStatsError = statsAsync.hasError;
    final statsErrorMessage =
        statsAsync.error?.toString() ?? 'Failed to load stats';

    final name = prefs?.name ?? '';
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final joinDate = prefs?.joinDate;
    final memberSince = joinDate != null
        ? 'Member since ${DateFormat('MMMM yyyy').format(joinDate)}'
        : 'Member since recently';
    final streak = statsAsync.valueOrNull?.bestStreak ?? 0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.contentTop),
              _ProfileHeader(
                firstLetter: firstLetter,
                name: name,
                memberSince: memberSince,
                streak: streak,
              ),
              const SizedBox(height: AppSpacing.xl),
              isPremium ? const _PremiumBadge() : const _PremiumCard(),
              const SizedBox(height: AppSpacing.xl),
              if (hasStatsError) ...[
                InlineError(
                  message: statsErrorMessage,
                  onRetry: () => ref.invalidate(statsProvider),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              _SettingsSection(
                onRemindersTap: () => _showNotificationSettingsSheet(context),
                onAppearanceTap: () {},
                onExportTap: () {},
                onBackupTap: () {},
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationSettingsSheet(BuildContext context) {
    showFormaModalSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return const _NotificationSettingsSheet();
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Profile header
// ---------------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.firstLetter,
    required this.name,
    required this.memberSince,
    required this.streak,
  });

  final String firstLetter;
  final String name;
  final String memberSince;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.ink,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              firstLetter,
              style: const TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: AppColors.paper,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          name.isEmpty ? 'Guest' : name,
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          memberSince,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink3),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '$streak day streak 🔥',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.ink2),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Premium card (non-premium)
// ---------------------------------------------------------------------------

class _PremiumCard extends StatelessWidget {
  const _PremiumCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.paper2,
        borderRadius: AppBorderRadius.regular,
        border: Border.all(color: AppColors.gold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unlock premium features',
            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Get insights, backups, and more',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink2),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => context.push(paywallRoute),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.terra,
                borderRadius: AppBorderRadius.small,
              ),
              child: Center(
                child: Text(
                  'Upgrade',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.paper,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Premium badge (premium)
// ---------------------------------------------------------------------------

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.sageDim,
        borderRadius: AppBorderRadius.regular,
        border: Border.all(color: AppColors.sageMid),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '◈',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.sage,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Premium member',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.sage),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings section
// ---------------------------------------------------------------------------

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.onRemindersTap,
    required this.onAppearanceTap,
    required this.onExportTap,
    required this.onBackupTap,
  });

  final VoidCallback onRemindersTap;
  final VoidCallback onAppearanceTap;
  final VoidCallback onExportTap;
  final VoidCallback onBackupTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingsRow(
          icon: '⏰',
          title: 'Reminders',
          onTap: onRemindersTap,
        ),
        const Divider(height: 1, color: AppColors.line),
        _SettingsRow(
          icon: '◈',
          title: 'Appearance',
          onTap: onAppearanceTap,
        ),
        const Divider(height: 1, color: AppColors.line),
        _SettingsRow(
          icon: '⤓',
          title: 'Export',
          onTap: onExportTap,
        ),
        const Divider(height: 1, color: AppColors.line),
        _SettingsRow(
          icon: '▣',
          title: 'Backup',
          onTap: onBackupTap,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Settings row
// ---------------------------------------------------------------------------

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.ink,
                ),
              ),
            ),
            const Text(
              '›',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notification settings sheet (v2 placeholder)
// ---------------------------------------------------------------------------

class _NotificationSettingsSheet extends StatelessWidget {
  const _NotificationSettingsSheet();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Settings',
          style: AppTextStyles.headlineLarge.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Coming in v2',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink3),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
