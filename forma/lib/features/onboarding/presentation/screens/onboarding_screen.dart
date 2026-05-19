import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_durations.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';
import 'package:forma/core/notifications/notification_service.dart';
import 'package:forma/core/router/app_router.dart';
import 'package:forma/core/storage/hive_service.dart';
import 'package:forma/core/storage/user_preferences_model.dart';
import 'package:forma/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:forma/features/habits/domain/usecases/add_habit.dart';
import 'package:forma/shared/widgets/emoji_picker.dart';
import 'package:forma/shared/widgets/forma_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

/// A 3-screen onboarding flow for new Forma users.
///
/// Screen 1: Welcome — animated gradient, headline, subtitle, Next button.
/// Screen 2: Add first habit — name field, emoji picker, Create habit button.
/// Screen 3: Notifications — permission prompt, Enable notifications button.
///
/// On completion, sets [UserPreferencesModel.hasCompletedOnboarding] to true
/// and navigates to the home route.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static final _logger = Logger('OnboardingScreen');

  late final PageController _pageController;
  int _currentPage = 0;

  // Screen 2 state
  final TextEditingController _habitNameController = TextEditingController();
  String? _selectedEmoji;
  bool _isSubmitting = false;
  String? _habitNameError;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: AppDurations.normal,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = HiveService.prefsBox.get('user');
    final updated = (prefs ?? UserPreferencesModel(joinDate: DateTime.now()))
        .copyWith(hasCompletedOnboarding: true);
    await HiveService.prefsBox.put('user', updated);
    _logger.info('Onboarding completed');
  }

  void _finishOnboarding() {
    _completeOnboarding().then((_) {
      if (mounted) {
        context.go(homeRoute);
      }
    });
  }

  Future<void> _createHabit() async {
    final name = _habitNameController.text.trim();
    final icon = _selectedEmoji;

    if (name.isEmpty) {
      setState(() {
        _habitNameError = 'Please enter a habit name';
      });
      return;
    }

    if (icon == null || icon.isEmpty) {
      setState(() {
        _habitNameError = 'Please select an icon';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _habitNameError = null;
    });

    try {
      final repository = HabitRepositoryImpl(
        HiveService.habitsBox,
        HiveService.logsBox,
      );
      final addHabit = AddHabit(repository);
      await addHabit(name: name, icon: icon);
      _goToPage(2);
    } on ArgumentError catch (e) {
      setState(() {
        _habitNameError = e.message.toString();
      });
    } catch (e, st) {
      _logger.severe('Failed to create habit', e, st);
      setState(() {
        _habitNameError = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _onPrimaryButtonPressed() {
    switch (_currentPage) {
      case 0:
        _goToPage(1);
      case 1:
        _createHabit();
      case 2:
        _initializeNotificationsAndFinish();
    }
  }

  Future<void> _initializeNotificationsAndFinish() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = HabitRepositoryImpl(
        HiveService.habitsBox,
        HiveService.logsBox,
      );
      final notificationService = NotificationService(repository: repository);
      await notificationService.init();
      _finishOnboarding();
    } catch (e, st) {
      _logger.severe('Failed to initialize notifications', e, st);
      // Continue to finish onboarding even if notifications fail
      _finishOnboarding();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _onSkipPressed() {
    _finishOnboarding();
  }

  String get _primaryButtonText {
    switch (_currentPage) {
      case 0:
        return 'Next';
      case 1:
        return 'Create habit';
      case 2:
        return 'Enable notifications';
      default:
        return 'Get started';
    }
  }

  bool get _showSkipButton => _currentPage == 1 || _currentPage == 2;

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _habitNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String buttonText = _primaryButtonText;
    final bool showSkip = _showSkipButton;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const _WelcomePage(),
                  _AddHabitPage(
                    nameController: _habitNameController,
                    selectedEmoji: _selectedEmoji,
                    onEmojiSelected: (emoji) {
                      setState(() {
                        _selectedEmoji = emoji;
                        _habitNameError = null;
                      });
                    },
                    error: _habitNameError,
                    onNameChanged: (_) {
                      if (_habitNameError != null) {
                        setState(() {
                          _habitNameError = null;
                        });
                      }
                    },
                  ),
                  const _NotificationsPage(),
                ],
              ),
            ),
            _DotsIndicator(currentPage: _currentPage),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _onPrimaryButtonPressed,
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
                          buttonText,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.paper,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ),
            if (showSkip)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: TextButton(
                  onPressed: _onSkipPressed,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.ink3,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: AppSpacing.md + AppSpacing.sm),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Page 1 — Welcome
// -----------------------------------------------------------------------------

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _AnimatedGradientPlaceholder(),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Build better habits',
            style: AppTextStyles.displayLarge.copyWith(
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Track, reflect, and grow with Forma',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.ink2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AnimatedGradientPlaceholder extends StatefulWidget {
  const _AnimatedGradientPlaceholder();

  @override
  State<_AnimatedGradientPlaceholder> createState() =>
      _AnimatedGradientPlaceholderState();
}

class _AnimatedGradientPlaceholderState
    extends State<_AnimatedGradientPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  AppColors.sageDim,
                  AppColors.terraDim,
                  _controller.value,
                )!,
                Color.lerp(
                  AppColors.gold,
                  AppColors.sage,
                  _controller.value,
                )!,
              ],
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Page 2 — Add first habit
// -----------------------------------------------------------------------------

class _AddHabitPage extends StatelessWidget {
  const _AddHabitPage({
    required this.nameController,
    required this.selectedEmoji,
    required this.onEmojiSelected,
    this.error,
    required this.onNameChanged,
  });

  final TextEditingController nameController;
  final String? selectedEmoji;
  final ValueChanged<String> onEmojiSelected;
  final String? error;
  final ValueChanged<String> onNameChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Text(
            "What's your first habit?",
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.ink,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FormaTextField(
            controller: nameController,
            placeholder: 'e.g. Drink 8 glasses of water',
            error: error,
            onChanged: onNameChanged,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Pick an icon',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.ink2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          EmojiPicker(
            selectedEmoji: selectedEmoji,
            onEmojiSelected: onEmojiSelected,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Page 3 — Notifications
// -----------------------------------------------------------------------------

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.sageDim,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.sageMid, width: 1),
            ),
            child: const Center(
              child: Text(
                '🔔',
                style: TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Stay on track',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.ink,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Get reminders for your habits',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.ink2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Dots indicator
// -----------------------------------------------------------------------------

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final bool isActive = index == currentPage;
          return AnimatedContainer(
            duration: AppDurations.normal,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            width: isActive ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.ink : AppColors.ink4,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
