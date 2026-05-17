import 'package:forma/features/mood/domain/entities/mood_entry.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'mood_model.g.dart';

/// Hive model for [MoodEntry] entity.
///
/// This class is used for serializing/deserializing mood entries to/from local storage.
/// Type ID: 3 (per ARCHITECTURE.md §7)
@HiveType(typeId: 3)
class MoodModel extends HiveObject {
  MoodModel({
    required this.date,
    required this.value,
    this.note,
  });

  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int value;

  @HiveField(2)
  final String? note;

  /// Converts this model to a [MoodEntry] entity.
  MoodEntry toEntity() {
    return MoodEntry(
      date: date,
      value: value,
      note: note,
    );
  }

  /// Creates a [MoodModel] from a [MoodEntry] entity.
  factory MoodModel.fromEntity(MoodEntry entity) {
    return MoodModel(
      date: entity.date,
      value: entity.value,
      note: entity.note,
    );
  }

  MoodModel copyWith({
    DateTime? date,
    int? value,
    String? note,
  }) {
    return MoodModel(
      date: date ?? this.date,
      value: value ?? this.value,
      note: note ?? this.note,
    );
  }
}