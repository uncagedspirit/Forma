import 'package:forma/features/habits/domain/entities/habit_log.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

/// Use case for completing a habit on a specific date.
///
/// This is idempotent: if a log already exists for the given habit and date,
/// it returns the existing log instead of creating a new one.
class CompleteHabit {
  const CompleteHabit(this._habitRepository, this._logRepository);

  final HabitRepository _habitRepository;
  final HabitRepository _logRepository;

  static final _logger = Logger('CompleteHabit');
  static const _uuid = Uuid();

  /// Completes a habit for the given date.
  ///
  /// [habitId] - The unique identifier of the habit to complete.
  /// [date] - The date for which to mark the habit as complete.
  ///
  /// Returns the [HabitLog] entry (existing or newly created).
  ///
  /// Throws [ArgumentError] if the habit does not exist or is archived.
  Future<HabitLog> call({
    required String habitId,
    required DateTime date,
  }) async {
    _logger.fine('Attempting to complete habit: $habitId for date: $date');

    // Verify habit exists and is not archived
    final habit = await _habitRepository.getById(habitId);
    if (habit == null) {
      _logger.warning('Cannot complete habit: habit not found (id: $habitId)');
      throw ArgumentError('Habit not found: $habitId');
    }

    if (habit.isArchived) {
      _logger.warning(
        'Cannot complete habit: habit is archived (id: $habitId)',
      );
      throw ArgumentError('Cannot complete archived habit: $habitId');
    }

    // Normalize date to midnight UTC for consistent comparison
    final normalizedDate = DateTime.utc(date.year, date.month, date.day);

    // Check if log already exists for this habit and date (idempotent)
    final existingLogs = await _logRepository.getLogsForDate(normalizedDate);
    final existingLog = existingLogs.where((log) => log.habitId == habitId);

    if (existingLog.isNotEmpty) {
      _logger.fine(
        'Habit already completed for this date, returning existing log',
      );
      return existingLog.first;
    }

    // Create new log entry
    final log = HabitLog(
      id: _uuid.v4(),
      habitId: habitId,
      date: normalizedDate,
      completedAt: DateTime.now(),
    );

    // Save the log
    await _logRepository.saveLog(log);
    _logger.info(
      'Successfully completed habit: ${habit.name} (id: $habitId) for date: $normalizedDate',
    );

    return log;
  }
}
