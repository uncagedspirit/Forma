/// MoodEntry entity representing a user's mood log for a specific date.
///
/// This is a pure Dart class with no Flutter or Hive dependencies.
class MoodEntry {
  const MoodEntry({
    required this.date,
    required this.value,
    this.note,
  });

  final DateTime date;
  final int value;
  final String? note;

  MoodEntry copyWith({
    DateTime? date,
    int? value,
    String? note,
  }) {
    return MoodEntry(
      date: date ?? this.date,
      value: value ?? this.value,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntry &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          value == other.value &&
          note == other.note;

  @override
  int get hashCode => Object.hash(date, value, note);
}