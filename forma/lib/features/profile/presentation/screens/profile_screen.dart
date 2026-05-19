import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/core/storage/hive_service.dart';
import 'package:forma/core/storage/user_preferences_model.dart';
import 'package:forma/features/profile/presentation/providers/user_preferences_provider.dart';
import 'package:forma/features/stats/presentation/providers/stats_provider.dart';
import 'package:forma/shared/widgets/forma_modal_sheet.dart';
import 'package:forma/shared/widgets/forma_text_field.dart';
import 'package:forma/shared/widgets/inline_error.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

/// Clean profile screen — name, streak, member since, reminders toggle.
/// Premium and other clutter removed.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final statsAsync = ref.watch(statsProvider);

    final name = prefs?.name ?? '';
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final joinDate = prefs?.joinDate;
    final memberSince = joinDate != null
        ? 'Member since ${DateFormat('MMMM yyyy').format(joinDate)}'
        : '';
    final streak = statsAsync.valueOrNull?.bestStreak ?? 0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.contentTop),

              // ── Header ──
              _ProfileHeader(
                firstLetter: firstLetter,
                name: name.isEmpty ? 'You' : name,
                memberSince: memberSince,
                streak: streak,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Stats error (non-fatal) ──
              if (statsAsync.hasError) ...[
                InlineError(
                  message:
                      statsAsync.error?.toString() ?? 'Failed to load stats',
                  onRetry: () => ref.invalidate(statsProvider),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // ── Settings ──
              const _SectionLabel(label: 'Settings'),
              const SizedBox(height: AppSpacing.sm),
              _SettingsRow(
                icon: Icons.person_outline,
                title: 'Edit name',
                onTap: () => _showEditNameSheet(context, ref, name),
              ),
              const Divider(height: 1, color: AppColors.line),
              _SettingsRow(
                icon: Icons.notifications_none,
                title: 'Reminders',
                onTap: () => _showRemindersSheet(context),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNameSheet(
      BuildContext context, WidgetRef ref, String currentName) {
    showFormaModalSheet<void>(
      context: context,
      builder: (context) => _EditNameSheet(currentName: currentName, ref: ref),
    );
  }

  void _showRemindersSheet(BuildContext context) {
    showFormaModalSheet<void>(
      context: context,
      builder: (context) => const _RemindersSheet(),
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
          name,
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.ink),
        ),
        if (memberSince.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            memberSince,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink3),
          ),
        ],
        if (streak > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.sageDim,
              borderRadius: AppBorderRadius.full,
            ),
            child: Text(
              '🔥 $streak day streak',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.sage),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.ink3,
        letterSpacing: 1.2,
      ),
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

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.ink2),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.ink),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit name sheet
// ---------------------------------------------------------------------------

class _EditNameSheet extends StatefulWidget {
  const _EditNameSheet({required this.currentName, required this.ref});
  final String currentName;
  final WidgetRef ref;

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  static final _logger = Logger('_EditNameSheet');
  late final TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.currentName == 'You' ? '' : widget.currentName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final prefs = HiveService.prefsBox.get('user');
      final updated = (prefs ?? UserPreferencesModel(joinDate: DateTime.now()))
          .copyWith(name: _ctrl.text.trim());
      await HiveService.prefsBox.put('user', updated);
      widget.ref.invalidate(userPreferencesProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e, st) {
      _logger.severe('Failed to save name', e, st);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Your name',
          style: AppTextStyles.headlineLarge.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppSpacing.lg),
        FormaTextField(
          controller: _ctrl,
          placeholder: 'Enter your name',
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ink,
            foregroundColor: AppColors.paper,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.small,
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.paper,
                  ),
                )
              : Text(
                  'Save',
                  style:
                      AppTextStyles.labelLarge.copyWith(color: AppColors.paper),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reminders sheet (placeholder for v2)
// ---------------------------------------------------------------------------

class _RemindersSheet extends StatelessWidget {
  const _RemindersSheet();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminders',
          style: AppTextStyles.headlineLarge.copyWith(color: AppColors.ink),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Per-habit reminder times can be set when creating or editing each habit.',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink2),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
