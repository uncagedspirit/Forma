import 'package:flutter/material.dart';
import 'package:forma/core/storage/hive_service.dart';
import 'package:forma/features/goals/presentation/screens/add_goal_screen.dart';
import 'package:forma/features/goals/presentation/screens/goal_detail_screen.dart';
import 'package:forma/features/habits/presentation/screens/add_habit_screen.dart';
import 'package:forma/features/habits/presentation/screens/habit_detail_screen.dart';
import 'package:forma/features/home/presentation/screens/home_screen.dart';
import 'package:forma/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:forma/features/premium/presentation/screens/paywall_screen.dart';
import 'package:forma/features/profile/presentation/screens/profile_screen.dart';
import 'package:forma/features/stats/presentation/screens/stats_screen.dart';
import 'package:forma/shared/widgets/forma_bottom_nav.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Route constants
// ---------------------------------------------------------------------------

/// Home tab route.
const String homeRoute = '/';

/// Stats tab route.
const String statsRoute = '/stats';

/// Profile tab route.
const String profileRoute = '/profile';

/// Add habit route.
const String addHabitRoute = '/habits/add';

/// Add goal route.
const String addGoalRoute = '/goals/add';

/// Habit detail route with path parameter `id`.
const String habitDetailRoute = '/habits/:id';

/// Goal detail route with path parameter `id`.
const String goalDetailRoute = '/goals/:id';

/// Onboarding route.
const String onboardingRoute = '/onboarding';

/// Premium / paywall route.
const String paywallRoute = '/premium';

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

/// The global GoRouter instance for Forma.
///
/// Redirects un-onboarded users to `onboardingRoute` regardless of the
  /// requested location. The shell routes (home, stats, profile) are wrapped
  /// in a ShellRoute that provides the persistent bottom navigation via
  /// FormaBottomNav.
final GoRouter appRouter = GoRouter(
  initialLocation: homeRoute,
  redirect: (BuildContext context, GoRouterState state) {
    // Avoid infinite redirect loops when already on onboarding.
    if (state.uri.path == onboardingRoute) {
      return null;
    }

    final prefs = HiveService.prefsBox.get('user');
    final hasCompletedOnboarding = prefs?.hasCompletedOnboarding ?? false;

    if (!hasCompletedOnboarding) {
      return onboardingRoute;
    }

    return null;
  },
  routes: <RouteBase>[
    ShellRoute(
      builder: (
        BuildContext context,
        GoRouterState state,
        Widget child,
      ) {
        return FormaBottomNav(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: homeRoute,
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: statsRoute,
          builder: (BuildContext context, GoRouterState state) {
            return const StatsScreen();
          },
        ),
        GoRoute(
          path: profileRoute,
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: onboardingRoute,
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: paywallRoute,
      builder: (BuildContext context, GoRouterState state) {
        return const PaywallScreen();
      },
    ),
    GoRoute(
      path: addHabitRoute,
      builder: (BuildContext context, GoRouterState state) {
        return const AddHabitScreen();
      },
    ),
    GoRoute(
      path: addGoalRoute,
      builder: (BuildContext context, GoRouterState state) {
        return const AddGoalScreen();
      },
    ),
    GoRoute(
      path: habitDetailRoute,
      builder: (BuildContext context, GoRouterState state) {
        final String id = state.pathParameters['id']!;
        return HabitDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: goalDetailRoute,
      builder: (BuildContext context, GoRouterState state) {
        final String id = state.pathParameters['id']!;
        return GoalDetailScreen(id: id);
      },
    ),
  ],
);
