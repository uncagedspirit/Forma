import 'package:forma/features/goals/domain/entities/goal.dart';

/// Abstract interface for goal data operations.
///
/// This interface defines all CRUD operations for goals.
/// Implementations should handle data persistence (e.g., Hive, Firebase, etc.).
abstract class GoalRepository {
  /// Gets all goals.
  Future<List<Goal>> getAll();

  /// Gets a goal by its ID.
  Future<Goal?> getById(String id);

  /// Saves a goal (creates or updates).
  Future<void> save(Goal goal);

  /// Deletes a goal by its ID.
  Future<void> delete(String id);

  /// Reorders goals based on the given list of IDs.
  Future<void> reorder(List<String> orderedIds);
}
