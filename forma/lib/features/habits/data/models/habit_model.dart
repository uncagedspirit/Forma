import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'habit_model.g.dart';

/// Hive model for [Habit] entity.
///
/// This class is used for serializing/deserializing habits to/from local storage.
/// Type ID: 0 (per ARCHITECTURE.md §7)
@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  HabitModel({
    required this.id,
    required this.name,
    required this.icon,
    this.goalId,
    required this.color,
    required this.sortOrder,
    this.reminderTime,
    this.reminderMessage,
    required this.createdAt,
    this.isArchived = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String icon;

  @HiveField(3)
  final String? goalId;

  @HiveField(4)
  final String color;

  @HiveField(5)
  final int sortOrder;

  @HiveField(6)
  final String? reminderTime;

  @HiveField(7)
  final String? reminderMessage;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final bool isArchived;

  /// Converts this model to a [Habit] entity.
  Habit toEntity() {
    return Habit(
      id: id,
      name: name,
      icon: icon,
      goalId: goalId,
      color: color,
      sortOrder: sortOrder,
      reminderTime: reminderTime,
      reminderMessage: reminderMessage,
      createdAt: createdAt,
      isArchived: isArchived,
    );
  }

  /// Creates a [HabitModel] from a [Habit] entity.
  factory HabitModel.fromEntity(Habit entity) {
    return HabitModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      goalId: entity.goalId,
      color: entity.color,
      sortOrder: entity.sortOrder,
      reminderTime: entity.reminderTime,
      reminderMessage: entity.reminderMessage,
      createdAt: entity.createdAt,
      isArchived: entity.isArchived,
    );
  }

  static const Object _sentinel = Object();

  HabitModel copyWith({
    Object? id = _sentinel,
    Object? name = _sentinel,
    Object? icon = _sentinel,
    Object? goalId = _sentinel,
    Object? color = _sentinel,
    Object? sortOrder = _sentinel,
    Object? reminderTime = _sentinel,
    Object? reminderMessage = _sentinel,
    Object? createdAt = _sentinel,
    Object? isArchived = _sentinel,
  }) {
    return HabitModel(
      id: id == _sentinel ? this.id : id as String,
      name: name == _sentinel ? this.name : name as String,
      icon: icon == _sentinel ? this.icon : icon as String,
      goalId: goalId == _sentinel ? this.goalId : goalId as String?,
      color: color == _sentinel ? this.color : color as String,
      sortOrder: sortOrder == _sentinel ? this.sortOrder : sortOrder as int,
      reminderTime: reminderTime == _sentinel
          ? this.reminderTime
          : reminderTime as String?,
      reminderMessage: reminderMessage == _sentinel
          ? this.reminderMessage
          : reminderMessage as String?,
      createdAt:
          createdAt == _sentinel ? this.createdAt : createdAt as DateTime,
      isArchived:
          isArchived == _sentinel ? this.isArchived : isArchived as bool,
    );
  }
}
