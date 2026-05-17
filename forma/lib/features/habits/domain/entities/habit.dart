import 'package:equatable/equatable.dart';

/// Habit entity representing a user's habit.
///
/// This is a pure Dart class with no Flutter or Hive dependencies.
/// Used throughout the domain and presentation layers.
class Habit extends Equatable {
  const Habit({
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

  final String id;
  final String name;
  final String icon;
  final String? goalId;
  final String color;
  final int sortOrder;
  final String? reminderTime;
  final String? reminderMessage;
  final DateTime createdAt;
  final bool isArchived;

  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    String? goalId,
    String? color,
    int? sortOrder,
    String? reminderTime,
    String? reminderMessage,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      goalId: goalId ?? this.goalId,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderMessage: reminderMessage ?? this.reminderMessage,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    goalId,
    color,
    sortOrder,
    reminderTime,
    reminderMessage,
    createdAt,
    isArchived,
  ];
}