import 'package:forma/features/habits/data/repositories/habit_repository_provider.dart';
import 'package:forma/features/habits/domain/usecases/complete_habit.dart';
import 'package:forma/features/habits/presentation/providers/habit_logs_provider.dart';
import 'package:forma/features/habits/presentation/providers/habits_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_completion_provider.g.dart';

@riverpod
class HabitCompletion extends _$HabitCompletion {
  @override
  Future<void> build() async {}

  /// Marks a habit as complete for the given date (idempotent).
  Future<void> complete(String habitId, DateTime date) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final habitRepo = ref.read(habitRepositoryProvider);
      final useCase = CompleteHabit(habitRepo);
      await useCase.call(habitId: habitId, date: date);
      ref.invalidate(habitsForDateProvider(date));
      ref.invalidate(habitLogsProvider(habitId));
    });
  }

  /// Removes the completion log for a habit on the given date (uncomplete).
  Future<void> uncomplete(String habitId, DateTime date) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final habitRepo = ref.read(habitRepositoryProvider);
      final normalizedDate = DateTime.utc(date.year, date.month, date.day);
      final logs = await habitRepo.getLogsForDate(normalizedDate);
      final matching = logs.where((l) => l.habitId == habitId);
      if (matching.isNotEmpty) {
        await habitRepo.deleteLog(matching.first.id);
      }
      ref.invalidate(habitsForDateProvider(date));
      ref.invalidate(habitLogsProvider(habitId));
    });
  }

  /// Toggles completion — completes if not done, uncompletes if done.
  Future<void> toggle(
    String habitId,
    DateTime date, {
    required bool isCompleted,
  }) async {
    if (isCompleted) {
      await uncomplete(habitId, date);
    } else {
      await complete(habitId, date);
    }
  }
}
