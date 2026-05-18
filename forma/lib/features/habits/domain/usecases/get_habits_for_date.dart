import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:logging/logging.dart';

/// A habit with its completion status for a specific date.
class HabitWithStatus {
  const HabitWithStatus({
    required this.habit,
    required this.isCompleted,
  });

  final Habit habit;
  final bool isCompleted;
}

/// Use case for retrieving habits with their completion status for a date.
///
/// Returns a sorted list of active (non-archived) habits with completion
/// status for the specified date.
class GetHabitsForDate {
  const GetHabitsForDate(this._repository);

  final HabitRepository _repository;

  static final _logger = Logger('GetHabitsForDate');

  /// Gets all active habits with their completion status for the given date.
  ///
  /// [date] - The date for which to retrieve habits and completion status.
  ///
  /// Returns a list of [HabitWithStatus] sorted by `sortOrder`.
  Future<List<HabitWithStatus>> call(DateTime date) async {
    _logger.fine('Getting habits for date: $date');

    // Normalize date to midnight UTC
    final normalizedDate = DateTime.utc(date.year, date.month, date.day);

    // Get all habits for the date (excludes archived)
    final habits = await _repository.getHabitsForDate(normalizedDate);

    // Get all logs for the date to determine completion status
    final logs = await _repository.getLogsForDate(normalizedDate);
    final completedHabitIds = logs.map((log) => log.habitId).toSet();

    // Create HabitWithStatus for each habit
    final habitsWithStatus = habits
        .where((habit) => !habit.isArchived)
        .map((habit) {
          return HabitWithStatus(
            habit: habit,
            isCompleted: completedHabitIds.contains(habit.id),
          );
        })
        .toList();

    // Sort by sortOrder
    habitsWithStatus.sort((a, b) => a.habit.sortOrder.compareTo(b.habit.sortOrder));

    _logger.fine(
      'Retrieved ${habitsWithStatus.length} habits for date: $normalizedDate',
    );

    return habitsWithStatus;
  }
}
