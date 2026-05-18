import 'package:forma/core/storage/hive_service.dart';
import 'package:forma/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_repository_provider.g.dart';

@riverpod
HabitRepository habitRepository(HabitRepositoryRef ref) {
  return HabitRepositoryImpl(HiveService.habitsBox, HiveService.logsBox);
}
