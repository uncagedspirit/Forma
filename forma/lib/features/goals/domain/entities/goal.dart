import 'package:equatable/equatable.dart';

/// Goal entity representing a user's goal.
///
/// This is a pure Dart class with no Flutter or Hive dependencies.
class Goal extends Equatable {
  const Goal({
    required this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    required this.createdAt,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final String color;
  final int sortOrder;
  final DateTime createdAt;
  final bool isArchived;

  Goal copyWith({
    String? id,
    String? name,
    String? color,
    int? sortOrder,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    color,
    sortOrder,
    createdAt,
    isArchived,
  ];
}