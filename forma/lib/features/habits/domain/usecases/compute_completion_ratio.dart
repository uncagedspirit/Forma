import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:logging/logging.dart';

/// Use case for computing the completion ratio for a specific date.
///
/// Returns a value between 0.0 and 1.0 representing the percentage of
/// active habits completed on the given date.
class ComputeCompletionRatio {
  const ComputeCompletionRatio(this._repository);

  final HabitRepository _repository;

  static final _logger = Logger('ComputeCompletionRatio');

  /// Computes the completion ratio for the given date.
  ///
  /// [date] - The date for which to compute the completion ratio.
  ///
  /// Returns a double between 0.0 and 1.0:
  /// - 0.0 if no habits are scheduled or no habits exist
  /// - 1.0 if all habits are completed
  /// - A value between 0.0 and 1.0 for partial completion
  Future<double> call(DateTime date) async {
    _logger.fine('Computing completion ratio for date: $date');

    // Normalize date to midnight UTC
    final normalizedDate = DateTime.utc(date.year, date.month, date.day);

    // Get all active habits for the date
    final habits = await _repository.getHabitsForDate(normalizedDate);
    final activeHabits = habits.where((h) => !h.isArchived).toList();

    // Return 0.0 if no active habits
    if (activeHabits.isEmpty) {
      _logger.fine('No active habits found for date: $normalizedDate');
      return 0.0;
    }

    // Get logs for the date
    final logs = await _repository.getLogsForDate(normalizedDate);
    final completedHabitIds = logs.map((log) => log.habitId).toSet();

    // Count completed habits
    final completedCount = activeHabits
        .where((habit) => completedHabitIds.contains(habit.id))
        .length;

    // Calculate ratio
    final ratio = completedCount / activeHabits.length;

    _logger.fine(
      'Completion ratio for $normalizedDate: $completedCount/${activeHabits.length} = $ratio',
    );

    return ratio;
  }
}
