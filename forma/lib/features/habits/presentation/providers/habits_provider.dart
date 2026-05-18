import 'package:forma/features/habits/data/repositories/habit_repository_provider.dart';
import 'package:forma/features/habits/domain/usecases/get_habits_for_date.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habits_provider.g.dart';

@riverpod
Future<List<HabitWithStatus>> habitsForDate(
  HabitsForDateRef ref,
  DateTime date,
) async {
  final repo = ref.watch(habitRepositoryProvider);
  final useCase = GetHabitsForDate(repo);
  return useCase.call(date);
}
