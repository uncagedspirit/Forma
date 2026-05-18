import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

/// Use case for adding a new habit.
///
/// Validates the habit name, assigns a UUID, creates the habit entity,
/// and saves it to the repository.
class AddHabit {
  const AddHabit(this._repository);

  final HabitRepository _repository;

  static final _logger = Logger('AddHabit');
  static const _uuid = Uuid();

  /// Adds a new habit with the given properties.
  ///
  /// [name] - The display name of the habit (required, non-empty).
  /// [icon] - The emoji icon representing the habit (required).
  /// [color] - Optional hex color string. Defaults to sage color if not provided.
  /// [goalId] - Optional goal ID to assign the habit to.
  /// [reminderTime] - Optional reminder time in HH:mm format.
  ///
  /// Throws [ArgumentError] if name is empty or icon is empty.
  Future<void> call({
    required String name,
    required String icon,
    String? color,
    String? goalId,
    String? reminderTime,
  }) async {
    // Validate name is not empty
    if (name.trim().isEmpty) {
      _logger.warning('Cannot add habit: name is empty');
      throw ArgumentError('Habit name cannot be empty');
    }

    // Validate icon is not empty
    if (icon.trim().isEmpty) {
      _logger.warning('Cannot add habit: icon is empty');
      throw ArgumentError('Habit icon cannot be empty');
    }

    // Generate UUID
    final id = _uuid.v4();
    _logger.fine('Generated habit ID: $id');

    // Create habit entity
    final habit = Habit(
      id: id,
      name: name.trim(),
      icon: icon.trim(),
      goalId: goalId,
      color: color?.trim() ?? '#5A7A5C', // Default sage color
      sortOrder: 0, // Will be set properly by repository or reorder use case
      reminderTime: reminderTime?.trim(),
      createdAt: DateTime.now(),
      isArchived: false,
    );

    // Save to repository
    _logger.fine('Saving habit: ${habit.name}');
    await _repository.save(habit);
    _logger.info('Successfully added habit: ${habit.name} (id: $id)');
  }
}
