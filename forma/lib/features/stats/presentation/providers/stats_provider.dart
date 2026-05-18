import 'package:forma/features/habits/data/repositories/habit_repository_provider.dart';
import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:forma/features/habits/domain/entities/habit_log.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_provider.g.dart';

/// Aggregated statistics for the stats screen.
class Stats {
  const Stats({
    required this.bestStreak,
    required this.completionPercentage,
    required this.checkInCount,
    required this.bestWeekday,
  });

  final int bestStreak;
  final double completionPercentage;
  final int checkInCount;
  final String bestWeekday;
}

/// Computes aggregate statistics across all habits and logs.
@riverpod
Future<Stats> stats(StatsRef ref) async {
  final HabitRepository habitRepo = ref.watch(habitRepositoryProvider);

  final allHabits = await habitRepo.getAll();
  final activeHabits = allHabits.where((h) => !h.isArchived).toList();
  final allLogs = await habitRepo.getAllLogs();

  final bestStreak = _computeBestStreak(allLogs);
  final checkInCount = allLogs.length;
  final completionPercentage = _computeCompletionPercentage(
    activeHabits,
    allLogs,
  );
  final bestWeekday = _computeBestWeekday(allLogs);

  return Stats(
    bestStreak: bestStreak,
    completionPercentage: completionPercentage,
    checkInCount: checkInCount,
    bestWeekday: bestWeekday,
  );
}

int _computeBestStreak(List<HabitLog> logs) {
  if (logs.isEmpty) return 0;

  final uniqueDates = logs
      .map(
        (log) => DateTime.utc(log.date.year, log.date.month, log.date.day),
      )
      .toSet()
      .toList()
    ..sort();

  var bestStreak = 1;
  var currentStreak = 1;

  for (var i = 1; i < uniqueDates.length; i++) {
    final previous = uniqueDates[i - 1];
    final current = uniqueDates[i];
    final difference = current.difference(previous).inDays;

    if (difference == 1) {
      currentStreak++;
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
    } else if (difference > 1) {
      currentStreak = 1;
    }
  }

  return bestStreak;
}

double _computeCompletionPercentage(
  List<Habit> activeHabits,
  List<HabitLog> logs,
) {
  if (activeHabits.isEmpty) return 0.0;

  final now = DateTime.now();
  final today = DateTime.utc(now.year, now.month, now.day);

  var totalPossible = 0;
  for (final habit in activeHabits) {
    final createdDate = DateTime.utc(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );
    final days = today.difference(createdDate).inDays + 1;
    totalPossible += days;
  }

  if (totalPossible == 0) return 0.0;

  return (logs.length / totalPossible).clamp(0.0, 1.0);
}

String _computeBestWeekday(List<HabitLog> logs) {
  if (logs.isEmpty) return '-';

  const weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final counts = List<int>.filled(7, 0);
  for (final log in logs) {
    counts[log.date.weekday - 1]++;
  }

  var maxIndex = 0;
  for (var i = 1; i < 7; i++) {
    if (counts[i] > counts[maxIndex]) {
      maxIndex = i;
    }
  }

  return weekdayNames[maxIndex];
}
