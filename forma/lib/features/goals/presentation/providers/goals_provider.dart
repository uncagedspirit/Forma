import 'package:forma/features/goals/data/repositories/goal_repository_provider.dart';
import 'package:forma/features/goals/domain/entities/goal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goals_provider.g.dart';

@riverpod
Future<List<Goal>> goals(GoalsRef ref) async {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.getAll();
}
