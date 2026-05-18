import 'package:forma/features/habits/data/repositories/habit_repository_provider.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_completion_rates_provider.g.dart';

/// Computes per-habit completion percentage over the last 30 days.
///
/// Returns a map of habitId -> percentage (0.0 to 1.0).
@riverpod
Future<Map<String, double>> habitCompletionRates(
  HabitCompletionRatesRef ref,
) async {
  final HabitRepository repo = ref.watch(habitRepositoryProvider);

  final allHabits = await repo.getAll();
  final activeHabits = allHabits.where((h) => !h.isArchived).toList();
  final allLogs = await repo.getAllLogs();

  final now = DateTime.now();
  final today = DateTime.utc(now.year, now.month, now.day);
  final start = today.subtract(const Duration(days: 29));

  final recentLogs = allLogs.where((log) {
    final logDate = DateTime.utc(log.date.year, log.date.month, log.date.day);
    return !logDate.isBefore(start) && !logDate.isAfter(today);
  }).toList();

  final logsByHabit = <String, Set<DateTime>>{};
  for (final log in recentLogs) {
    final logDate = DateTime.utc(log.date.year, log.date.month, log.date.day);
    logsByHabit.putIfAbsent(log.habitId, () => <DateTime>{});
    logsByHabit[log.habitId]!.add(logDate);
  }

  final result = <String, double>{};
  for (final habit in activeHabits) {
    final completedDays = logsByHabit[habit.id]?.length ?? 0;
    result[habit.id] = (completedDays / 30).clamp(0.0, 1.0);
  }

  return result;
}
