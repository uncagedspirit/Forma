import 'package:equatable/equatable.dart';

/// HabitLog entity representing a habit completion record.
///
/// This is a pure Dart class with no Flutter or Hive dependencies.
class HabitLog extends Equatable {
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completedAt,
    this.photoPath,
    this.note,
  });

  final String id;
  final String habitId;
  final DateTime date;
  final DateTime completedAt;
  final String? photoPath;
  final String? note;

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
  List<Object?> get props => [
    id,
    habitId,
    date,
    completedAt,
    photoPath,
    note,
  ];
}