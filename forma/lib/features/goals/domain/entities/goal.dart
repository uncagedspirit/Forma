/// Goal entity representing a user's goal.
///
/// This is a pure Dart class with no Flutter or Hive dependencies.
class Goal {
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          color == other.color &&
          sortOrder == other.sortOrder &&
          createdAt == other.createdAt &&
          isArchived == other.isArchived;

  @override
  int get hashCode => Object.hash(id, name, color, sortOrder, createdAt, isArchived);
}