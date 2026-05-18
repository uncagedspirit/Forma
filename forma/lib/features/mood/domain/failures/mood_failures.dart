/// Base class for all mood-related failures.
sealed class MoodFailure implements Exception {
  const MoodFailure();
}

/// Thrown when a mood entry is not found.
class MoodNotFoundFailure extends MoodFailure {
  const MoodNotFoundFailure(this.date);
  final DateTime date;

  @override
  String toString() => 'MoodNotFoundFailure: Mood entry for date $date not found';
}

/// Thrown when there's a storage error.
class MoodStorageFailure extends MoodFailure {
  const MoodStorageFailure(this.message);
  final String message;

  @override
  String toString() => 'MoodStorageFailure: $message';
}
