import 'package:forma/core/storage/hive_service.dart';
import 'package:forma/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:forma/features/goals/domain/repositories/goal_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_repository_provider.g.dart';

@riverpod
GoalRepository goalRepository(GoalRepositoryRef ref) {
  return GoalRepositoryImpl(HiveService.goalsBox);
}
