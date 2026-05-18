import 'package:forma/features/habits/data/repositories/habit_repository_provider.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_completion_rates_provider.g.dart';

/// Per-habit completion rate over the last 30 days.
class HabitCompletionRate {
  /// Creates a [HabitCompletionRate] with the given properties.
  const HabitCompletionRate({
    required this.id,
    required this.name,
    required this.icon,
    required this.rate,
  });

  /// Unique identifier for the habit.
  final String id;

  /// Display name of the habit.
  final String name;

  /// Emoji icon representing the habit.
  final String icon;

  /// Completion percentage over the last 30 days (0.0 to 1.0).
  final double rate;
}

/// Computes per-habit completion percentage over the last 30 days.
///
/// Returns a list of [HabitCompletionRate] sorted by rate descending,
/// then by habit name alphabetically.
@riverpod
Future<List<HabitCompletionRate>> habitCompletionRates(
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

  final result = <HabitCompletionRate>[];
  for (final habit in activeHabits) {
    final completedDays = logsByHabit[habit.id]?.length ?? 0;
    result.add(
      HabitCompletionRate(
        id: habit.id,
        name: habit.name,
        icon: habit.icon,
        rate: (completedDays / 30).clamp(0.0, 1.0),
      ),
    );
  }

  result.sort((a, b) {
    final rateCompare = b.rate.compareTo(a.rate);
    if (rateCompare != 0) return rateCompare;
    return a.name.compareTo(b.name);
  });

  return result;
}
