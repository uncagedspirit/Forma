import 'package:forma/features/habits/data/repositories/habit_repository_provider.dart';
import 'package:forma/features/habits/domain/entities/habit_log.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_logs_provider.g.dart';

/// Fetches all completion logs for a specific habit.
@riverpod
Future<List<HabitLog>> habitLogs(HabitLogsRef ref, String habitId) async {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.getLogsForHabit(habitId);
}
