import 'package:forma/features/goals/data/repositories/goal_repository_provider.dart';
import 'package:forma/features/habits/data/repositories/habit_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_completion_provider.g.dart';

@riverpod
Future<double> goalCompletionRatio(
  GoalCompletionRatioRef ref,
  String goalId,
) async {
  final habitRepo = ref.watch(habitRepositoryProvider);
  final goalRepo = ref.watch(goalRepositoryProvider);

  // Verify goal exists
  final goal = await goalRepo.getById(goalId);
  if (goal == null) return 0.0;

  // Get all habits for this goal
  final habits = await habitRepo.getAll();
  final goalHabits = habits.where((h) => h.goalId == goalId && !h.isArchived).toList();

  if (goalHabits.isEmpty) return 0.0;

  // Get today's logs
  final today = DateTime.now();
  final logs = await habitRepo.getLogsForDate(today);
  final completedHabitIds = logs.map((l) => l.habitId).toSet();

  final completedCount = goalHabits.where((h) => completedHabitIds.contains(h.id)).length;
  return completedCount / goalHabits.length;
}
