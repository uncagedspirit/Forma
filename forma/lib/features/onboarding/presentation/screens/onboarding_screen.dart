import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/core/router/app_router.dart';
import 'package:forma/core/storage/hive_service.dart';
import 'package:forma/core/storage/user_preferences_model.dart';
import 'package:forma/shared/widgets/forma_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

/// Single-screen onboarding: just asks for the user's name.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static final _logger = Logger('OnboardingScreen');

  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _isSubmitting = false;
  String? _nameError;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    setState(() {
      _isSubmitting = true;
      _nameError = null;
    });
    try {
      final prefs = HiveService.prefsBox.get('user');
      final updated = (prefs ?? UserPreferencesModel(joinDate: DateTime.now()))
          .copyWith(hasCompletedOnboarding: true, name: name);
      await HiveService.prefsBox.put('user', updated);
      _logger.info('Onboarding complete. name="$name"');
      if (mounted) context.go(homeRoute);
    } catch (e, st) {
      _logger.severe('Onboarding save failed', e, st);
      setState(() {
        _isSubmitting = false;
        _nameError = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  const Center(child: _AnimatedOrb()),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'What should we\ncall you?',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.ink,
                      fontSize: 30,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    "We'll use this to greet you every day.",
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.ink3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FormaTextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    placeholder: 'Your name',
                    error: _nameError,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onContinue(),
                    onChanged: (_) {
                      if (_nameError != null) setState(() => _nameError = null);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: AppColors.paper,
                        disabledBackgroundColor: AppColors.ink4,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.small,
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.paper,
                              ),
                            )
                          : Text(
                              "Let's go →",
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.paper,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            _nameController.clear();
                            _onContinue();
                          },
                    child: Text(
                      'Skip for now',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.ink4,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated orb (simple pulsing gradient circle)
// ---------------------------------------------------------------------------

class _AnimatedOrb extends StatefulWidget {
  const _AnimatedOrb();

  @override
  State<_AnimatedOrb> createState() => _AnimatedOrbState();
}

class _AnimatedOrbState extends State<_AnimatedOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color.lerp(AppColors.sageDim, AppColors.gold, _ctrl.value)!,
                Color.lerp(AppColors.sage, AppColors.terraDim, _ctrl.value)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.sage.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '✦',
              style: TextStyle(fontSize: 32, color: Colors.white70),
            ),
          ),
        );
      },
    );
  }
}
