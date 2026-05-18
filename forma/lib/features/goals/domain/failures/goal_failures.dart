/// Base class for all goal-related failures.
sealed class GoalFailure implements Exception {
  const GoalFailure();
}

/// Thrown when a goal is not found.
class GoalNotFoundFailure extends GoalFailure {
  const GoalNotFoundFailure(this.id);
  final String id;

  @override
  String toString() => 'GoalNotFoundFailure: Goal with id $id not found';
}

/// Thrown when there's a storage error.
class GoalStorageFailure extends GoalFailure {
  const GoalStorageFailure(this.message);
  final String message;

  @override
  String toString() => 'GoalStorageFailure: $message';
}
