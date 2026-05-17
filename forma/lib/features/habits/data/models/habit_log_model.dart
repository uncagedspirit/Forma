import 'package:forma/features/habits/domain/entities/habit_log.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'habit_log_model.g.dart';

/// Hive model for [HabitLog] entity.
///
/// This class is used for serializing/deserializing habit logs to/from local storage.
/// Type ID: 1 (per ARCHITECTURE.md §7)
@HiveType(typeId: 1)
class HabitLogModel extends HiveObject {
  HabitLogModel({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completedAt,
    this.photoPath,
    this.note,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final DateTime completedAt;

  @HiveField(4)
  final String? photoPath;

  @HiveField(5)
  final String? note;

  /// Converts this model to a [HabitLog] entity.
  HabitLog toEntity() {
    return HabitLog(
      id: id,
      habitId: habitId,
      date: date,
      completedAt: completedAt,
      photoPath: photoPath,
      note: note,
    );
  }

  /// Creates a [HabitLogModel] from a [HabitLog] entity.
  factory HabitLogModel.fromEntity(HabitLog entity) {
    return HabitLogModel(
      id: entity.id,
      habitId: entity.habitId,
      date: entity.date,
      completedAt: entity.completedAt,
      photoPath: entity.photoPath,
      note: entity.note,
    );
  }

  HabitLogModel copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    DateTime? completedAt,
    String? photoPath,
    String? note,
  }) {
    return HabitLogModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completedAt: completedAt ?? this.completedAt,
      photoPath: photoPath ?? this.photoPath,
      note: note ?? this.note,
    );
  }
}