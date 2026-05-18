import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:logging/logging.dart';

/// Use case for computing daily completion scores over a date range.
///
/// Returns a map of dates to their corresponding completion ratios.
class ComputeDailyCompletionScores {
  const ComputeDailyCompletionScores(this._repository);

  final HabitRepository _repository;

  static final _logger = Logger('ComputeDailyCompletionScores');

  /// Computes completion scores for each day in the given date range.
  ///
  /// [start] - The start date of the range (inclusive).
  /// [end] - The end date of the range (inclusive).
  ///
  /// Returns a map where keys are dates (normalized to midnight UTC) and
  /// values are completion ratios (0.0 to 1.0).
  ///
  /// Throws [ArgumentError] if start date is after end date.
  Future<Map<DateTime, double>> call(DateTime start, DateTime end) async {
    _logger.fine('Computing daily completion scores from $start to $end');

    // Normalize dates to midnight UTC
    final normalizedStart = DateTime.utc(start.year, start.month, start.day);
    final normalizedEnd = DateTime.utc(end.year, end.month, end.day);

    // Validate date range
    if (normalizedStart.isAfter(normalizedEnd)) {
      _logger.warning('Start date is after end date');
      throw ArgumentError('Start date must not be after end date');
    }

    // Get all active habits
    final allHabits = await _repository.getAll();
    final activeHabits = allHabits.where((h) => !h.isArchived).toList();

    if (activeHabits.isEmpty) {
      _logger.fine('No active habits found, returning empty map');
      return {};
    }

    // Get all logs
    final allLogs = await _repository.getAllLogs();

    // Build map of date -> set of completed habit IDs
    final logsByDate = <DateTime, Set<String>>{};
    for (final log in allLogs) {
      final logDate = DateTime.utc(log.date.year, log.date.month, log.date.day);
      logsByDate.putIfAbsent(logDate, () => <String>{});
      logsByDate[logDate]!.add(log.habitId);
    }

    // Calculate completion ratio for each day in range
    final scores = <DateTime, double>{};
    var currentDate = normalizedStart;

    while (!currentDate.isAfter(normalizedEnd)) {
      final completedHabits = logsByDate[currentDate] ?? <String>{};
      final completedCount = activeHabits
          .where((habit) => completedHabits.contains(habit.id))
          .length;

      scores[currentDate] = completedCount / activeHabits.length;

      // Move to next day
      currentDate = currentDate.add(const Duration(days: 1));
    }

    _logger.fine('Computed completion scores for ${scores.length} days');

    return scores;
  }
}
