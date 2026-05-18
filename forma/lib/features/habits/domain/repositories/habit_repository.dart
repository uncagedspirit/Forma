import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:forma/features/habits/domain/entities/habit_log.dart';

/// Abstract interface for habit data operations.
///
/// This interface defines all CRUD operations for habits and their logs.
/// Implementations should handle data persistence (e.g., Hive, Firebase, etc.).
abstract class HabitRepository {
  /// Gets all habits.
  Future<List<Habit>> getAll();

  /// Gets a habit by its ID.
  Future<Habit?> getById(String id);

  /// Gets habits for a specific date.
  Future<List<Habit>> getHabitsForDate(DateTime date);

  /// Saves a habit (creates or updates).
  Future<void> save(Habit habit);

  /// Deletes a habit by its ID.
  Future<void> delete(String id);

  /// Reorders habits based on the given list of IDs.
  Future<void> reorder(List<String> orderedIds);

  /// Gets all habit logs.
  Future<List<HabitLog>> getAllLogs();

  /// Gets logs for a specific habit.
  Future<List<HabitLog>> getLogsForHabit(String habitId);

  /// Gets logs for a specific date.
  Future<List<HabitLog>> getLogsForDate(DateTime date);

  /// Saves a habit log (creates or updates).
  Future<void> saveLog(HabitLog log);

  /// Deletes a habit log by its ID.
  Future<void> deleteLog(String id);
}
