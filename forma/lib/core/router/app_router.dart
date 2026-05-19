import 'package:flutter/material.dart';
import 'package:forma/core/storage/hive_service.dart';
import 'package:forma/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:forma/features/goals/presentation/screens/add_goal_screen.dart';
import 'package:forma/features/goals/presentation/screens/goal_detail_screen.dart';
import 'package:forma/features/goals/presentation/screens/goals_screen.dart';
import 'package:forma/features/habits/presentation/screens/add_habit_screen.dart';
import 'package:forma/features/habits/presentation/screens/habit_detail_screen.dart';
import 'package:forma/features/home/presentation/screens/home_screen.dart';
import 'package:forma/features/insights/presentation/screens/insights_screen.dart';
import 'package:forma/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:forma/features/profile/presentation/screens/profile_screen.dart';
import 'package:forma/shared/widgets/forma_bottom_nav.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Route constants
// ---------------------------------------------------------------------------

const String homeRoute        = '/';
const String goalsRoute       = '/goals';
const String calendarRoute    = '/calendar';
const String insightsRoute    = '/insights';
const String profileRoute     = '/profile';
const String addHabitRoute    = '/habits/add';
const String addGoalRoute     = '/goals/add';
const String habitDetailRoute = '/habits/:id';
const String goalDetailRoute  = '/goals/:id';
const String onboardingRoute  = '/onboarding';

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

final GoRouter appRouter = GoRouter(
  initialLocation: homeRoute,
  redirect: (BuildContext context, GoRouterState state) {
    if (state.uri.path == onboardingRoute) return null;
    final prefs = HiveService.prefsBox.get('user');
    final hasCompletedOnboarding = prefs?.hasCompletedOnboarding ?? false;
    if (!hasCompletedOnboarding) return onboardingRoute;
    return null;
  },
  routes: <RouteBase>[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return FormaBottomNav(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: homeRoute,
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: goalsRoute,
          builder: (_, __) => const GoalsScreen(),
        ),
        GoRoute(
          path: calendarRoute,
          builder: (_, __) => const CalendarScreen(),
        ),
        GoRoute(
          path: insightsRoute,
          builder: (_, __) => const InsightsScreen(),
        ),
        GoRoute(
          path: profileRoute,
          builder: (_, __) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: onboardingRoute,
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: addHabitRoute,
      builder: (_, __) => const AddHabitScreen(),
    ),
    GoRoute(
      path: addGoalRoute,
      builder: (_, __) => const AddGoalScreen(),
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
