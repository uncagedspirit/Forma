/// A habit entity representing a user's habit.
///
/// This is a pure Dart class with no Flutter or Hive dependencies.
/// It represents the domain concept of a habit that a user wants to track.
class Habit {
  /// Creates a [Habit] with the given properties.
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

  /// Unique identifier for the habit.
  final String id;

  /// Display name of the habit.
  final String name;

  /// Emoji icon representing the habit.
  final String icon;

  /// Optional goal ID this habit belongs to.
  final String? goalId;

  /// Hex color string for the habit's visual representation.
  final String color;

  /// Sort order for displaying habits in lists.
  final int sortOrder;

  /// Optional reminder time in HH:mm format.
  final String? reminderTime;

  /// Optional custom reminder message.
  final String? reminderMessage;

  /// When the habit was created.
  final DateTime createdAt;

  /// Whether the habit is archived (soft-deleted).
  final bool isArchived;

  /// Creates a copy of this habit with the given fields replaced.
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.goalId == goalId &&
        other.color == color &&
        other.sortOrder == sortOrder &&
        other.reminderTime == reminderTime &&
        other.reminderMessage == reminderMessage &&
        other.createdAt == createdAt &&
        other.isArchived == isArchived;
  }

  @override
  int get hashCode {
    return Object.hash(
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
    );
  }

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, icon: $icon, goalId: $goalId, '
        'color: $color, sortOrder: $sortOrder, isArchived: $isArchived)';
  }
}
