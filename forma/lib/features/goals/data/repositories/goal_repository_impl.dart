import 'package:forma/features/goals/data/models/goal_model.dart';
import 'package:forma/features/goals/domain/entities/goal.dart';
import 'package:forma/features/goals/domain/failures/goal_failures.dart';
import 'package:forma/features/goals/domain/repositories/goal_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

/// Hive-backed implementation of [GoalRepository].
class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._box) : _logger = Logger('GoalRepositoryImpl');

  final Box<GoalModel> _box;
  final Logger _logger;

  @override
  Future<List<Goal>> getAll() async {
    try {
      // Filter out archived goals
      return _box.values
          .where((model) => !model.isArchived)
          .map((model) => model.toEntity())
          .toList();
    } catch (e, st) {
      _logger.severe('Failed to get all goals', e, st);
      throw GoalStorageFailure(e.toString());
    }
  }

  @override
  Future<Goal?> getById(String id) async {
    try {
      final model = _box.get(id);
      return model?.toEntity();
    } catch (e, st) {
      _logger.severe('Failed to get goal by id: $id', e, st);
      throw GoalStorageFailure(e.toString());
    }
  }

  @override
  Future<void> save(Goal goal) async {
    try {
      final model = GoalModel.fromEntity(goal);
      await _box.put(goal.id, model);
    } catch (e, st) {
      _logger.severe('Failed to save goal: ${goal.id}', e, st);
      throw GoalStorageFailure(e.toString());
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e, st) {
      _logger.severe('Failed to delete goal: $id', e, st);
      throw GoalStorageFailure(e.toString());
    }
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {
    try {
      for (var i = 0; i < orderedIds.length; i++) {
        final id = orderedIds[i];
        final model = _box.get(id);
        if (model != null) {
          final updated = model.copyWith(sortOrder: i);
          await _box.put(id, updated);
        }
      }
    } catch (e, st) {
      _logger.severe('Failed to reorder goals', e, st);
      throw GoalStorageFailure(e.toString());
    }
  }
}
