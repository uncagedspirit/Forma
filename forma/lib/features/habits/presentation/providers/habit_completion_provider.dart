import 'package:forma/features/habits/data/repositories/habit_repository_provider.dart';
import 'package:forma/features/habits/domain/usecases/complete_habit.dart';
import 'package:forma/features/habits/presentation/providers/habits_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_completion_provider.g.dart';

@riverpod
class HabitCompletion extends _$HabitCompletion {
  @override
  Future<void> build() async {}

  Future<void> complete(String habitId, DateTime date) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final habitRepo = ref.read(habitRepositoryProvider);
      final useCase = CompleteHabit(habitRepo, habitRepo);
      await useCase.call(habitId: habitId, date: date);
      ref.invalidate(habitsForDateProvider(date));
    });
  }
}
