import 'package:forma/features/goals/domain/entities/goal.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'goal_model.g.dart';

/// Hive model for [Goal] entity.
///
/// This class is used for serializing/deserializing goals to/from local storage.
/// Type ID: 2 (per ARCHITECTURE.md §7)
@HiveType(typeId: 2)
class GoalModel extends HiveObject {
  GoalModel({
    required this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    required this.createdAt,
    this.isArchived = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String color;

  @HiveField(3)
  final int sortOrder;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final bool isArchived;

  /// Converts this model to a [Goal] entity.
  Goal toEntity() {
    return Goal(
      id: id,
      name: name,
      color: color,
      sortOrder: sortOrder,
      createdAt: createdAt,
      isArchived: isArchived,
    );
  }

  /// Creates a [GoalModel] from a [Goal] entity.
  factory GoalModel.fromEntity(Goal entity) {
    return GoalModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      isArchived: entity.isArchived,
    );
  }

  GoalModel copyWith({
    String? id,
    String? name,
    String? color,
    int? sortOrder,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}