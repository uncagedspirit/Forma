/// Base class for all habit-related failures.
sealed class HabitFailure implements Exception {
  const HabitFailure();
}

/// Thrown when a habit is not found.
class HabitNotFoundFailure extends HabitFailure {
  const HabitNotFoundFailure(this.id);
  final String id;

  @override
  String toString() => 'HabitNotFoundFailure: Habit with id $id not found';
}

/// Thrown when there's a storage error.
class HabitStorageFailure extends HabitFailure {
  const HabitStorageFailure(this.message);
  final String message;

  @override
  String toString() => 'HabitStorageFailure: $message';
}
