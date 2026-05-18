/// A log entry representing a completed habit instance.
///
/// This is a pure Dart class with no Flutter or Hive dependencies.
/// It records when a habit was completed and any associated metadata.
class HabitLog {
  /// Creates a [HabitLog] with the given properties.
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completedAt,
    this.photoPath,
    this.note,
  });

  /// Unique identifier for the log entry.
  final String id;

  /// ID of the habit that was completed.
  final String habitId;

  /// The date this log represents (normalized to midnight UTC).
  final DateTime date;

  /// Exact timestamp when the habit was marked complete.
  final DateTime completedAt;

  /// Optional path to a photo taken during completion.
  final String? photoPath;

  /// Optional note entered by the user.
  final String? note;

  /// Creates a copy of this log with the given fields replaced.
  HabitLog copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    DateTime? completedAt,
    String? photoPath,
    String? note,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completedAt: completedAt ?? this.completedAt,
      photoPath: photoPath ?? this.photoPath,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitLog &&
        other.id == id &&
        other.habitId == habitId &&
        other.date == date &&
        other.completedAt == completedAt &&
        other.photoPath == photoPath &&
        other.note == note;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      habitId,
      date,
      completedAt,
      photoPath,
      note,
    );
  }

  @override
  String toString() {
    return 'HabitLog(id: $id, habitId: $habitId, date: $date, '
        'completedAt: $completedAt)';
  }
}
