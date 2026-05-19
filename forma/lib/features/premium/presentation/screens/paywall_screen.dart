import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:go_router/go_router.dart';

/// The premium paywall screen for the Forma habit tracker app.
///
/// Displays a feature list, pricing toggle, upgrade CTA, and restore link.
/// IAP integration is not wired up in v1 — taps show a "Coming soon" toast.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: _PaywallBody(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Paywall body
// ---------------------------------------------------------------------------

class _PaywallBody extends StatefulWidget {
  const _PaywallBody();

  @override
  State<_PaywallBody> createState() => _PaywallBodyState();
}

class _PaywallBodyState extends State<_PaywallBody> {
  bool _isAnnual = true;

  void _togglePricing(bool isAnnual) {
    if (_isAnnual != isAnnual) {
      setState(() {
        _isAnnual = isAnnual;
      });
    }
  }

  void _showComingSoonSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon'),
        duration: AppDurations.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.contentTop + AppSpacing.xl),
              Text(
                'Go Premium',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Unlock the full Forma experience',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.ink3,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _FeatureList(),
              const SizedBox(height: AppSpacing.xl),
              _PricingToggle(
                isAnnual: _isAnnual,
                onToggle: _togglePricing,
              ),
              const SizedBox(height: AppSpacing.md),
              _PriceDisplay(isAnnual: _isAnnual),
              const SizedBox(height: AppSpacing.xl),
              _UpgradeButton(onTap: _showComingSoonSnackBar),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: _RestoreLink(onTap: _showComingSoonSnackBar),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        Positioned(
          top: AppSpacing.contentTop,
          right: AppSpacing.screenHorizontal,
          child: GestureDetector(
            onTap: () => context.pop(),
            behavior: HitTestBehavior.opaque,
            child: const Text(
              '✕',
              style: TextStyle(
                fontSize: 22,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Feature list
// ---------------------------------------------------------------------------

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FeatureItem(text: 'Detailed insights & correlations'),
        SizedBox(height: AppSpacing.md),
        _FeatureItem(text: 'Full activity history'),
        SizedBox(height: AppSpacing.md),
        _FeatureItem(text: 'Data export & backup'),
        SizedBox(height: AppSpacing.md),
        _FeatureItem(text: 'Custom reminders'),
        SizedBox(height: AppSpacing.md),
        _FeatureItem(text: 'Priority support'),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '✓',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.sage,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pricing toggle
// ---------------------------------------------------------------------------

class _PricingToggle extends StatelessWidget {
  const _PricingToggle({
    required this.isAnnual,
    required this.onToggle,
  });

  final bool isAnnual;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.paper2,
        borderRadius: AppBorderRadius.small,
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: 'Monthly',
              isSelected: !isAnnual,
              onTap: () => onToggle(false),
            ),
          ),
          Expanded(
            child: _ToggleOption(
              label: 'Annual',
              isSelected: isAnnual,
              onTap: () => onToggle(true),
              badge: 'Save 20%',
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ink : Colors.transparent,
          borderRadius: AppBorderRadius.small,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? AppColors.paper : AppColors.ink2,
              ),
            ),
            if (badge != null && badge!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  badge!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected ? AppColors.paper : AppColors.terra,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Price display
// ---------------------------------------------------------------------------

class _PriceDisplay extends StatelessWidget {
  const _PriceDisplay({required this.isAnnual});

  final bool isAnnual;

  @override
  Widget build(BuildContext context) {
    final price = isAnnual ? '₹999/year' : '₹199/month';

    return Center(
      child: Text(
        price,
        style: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.ink,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CTA button
// ---------------------------------------------------------------------------

class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: AppBorderRadius.regular,
        ),
        child: Center(
          child: Text(
            'Upgrade now',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.paper,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Restore link
// ---------------------------------------------------------------------------

class _RestoreLink extends StatelessWidget {
  const _RestoreLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        'Restore purchases',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.ink3,
        ),
      ),
    );
  }
}
