import 'package:forma/features/habits/data/models/habit_log_model.dart';
import 'package:forma/features/habits/data/models/habit_model.dart';
import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:forma/features/habits/domain/entities/habit_log.dart';
import 'package:forma/features/habits/domain/failures/habit_failures.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

/// Hive-backed implementation of [HabitRepository].
class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl(this._habitsBox, this._logsBox)
      : _logger = Logger('HabitRepositoryImpl');

  final Box<HabitModel> _habitsBox;
  final Box<HabitLogModel> _logsBox;
  final Logger _logger;

  @override
  Future<List<Habit>> getAll() async {
    try {
      return _habitsBox.values
          .where((model) => !model.isArchived)
          .map((model) => model.toEntity())
          .toList();
    } catch (e, st) {
      _logger.severe('Failed to get all habits', e, st);
      throw HabitStorageFailure(e.toString());
    }
  }

  @override
  Future<Habit?> getById(String id) async {
    try {
      final model = _habitsBox.get(id);
      return model?.toEntity();
    } catch (e, st) {
      _logger.severe('Failed to get habit by id: $id', e, st);
      throw HabitStorageFailure(e.toString());
    }
  }

  @override
  Future<List<Habit>> getHabitsForDate(DateTime date) async {
    try {
      return _habitsBox.values
          .where((model) => !model.isArchived)
          .map((model) => model.toEntity())
          .toList();
    } catch (e, st) {
      _logger.severe('Failed to get habits for date: $date', e, st);
      throw HabitStorageFailure(e.toString());
    }
  }

  @override
  Future<void> save(Habit habit) async {
    try {
      final model = HabitModel.fromEntity(habit);
      await _habitsBox.put(habit.id, model);
    } catch (e, st) {
      _logger.severe('Failed to save habit: ${habit.id}', e, st);
      throw HabitStorageFailure(e.toString());
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _habitsBox.delete(id);
    } catch (e, st) {
      _logger.severe('Failed to delete habit: $id', e, st);
      throw HabitStorageFailure(e.toString());
    }
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {
    try {
      for (var i = 0; i < orderedIds.length; i++) {
        final id = orderedIds[i];
        final model = _habitsBox.get(id);
        if (model != null) {
          final updated = model.copyWith(sortOrder: i);
          await _habitsBox.put(id, updated);
        }
      }
    } catch (e, st) {
      _logger.severe('Failed to reorder habits', e, st);
      throw HabitStorageFailure(e.toString());
    }
  }

  @override
  Future<List<HabitLog>> getAllLogs() async {
    try {
      return _logsBox.values.map((model) => model.toEntity()).toList();
    } catch (e, st) {
      _logger.severe('Failed to get all logs', e, st);
      throw HabitStorageFailure(e.toString());
    }
  }

  @override
  Future<List<HabitLog>> getLogsForHabit(String habitId) async {
    try {
      return _logsBox.values
          .where((model) => model.habitId == habitId)
          .map((model) => model.toEntity())
          .toList();
    } catch (e, st) {
      _logger.severe('Failed to get logs for habit: $habitId', e, st);
      throw HabitStorageFailure(e.toString());
    }
  }

  @override
  Future<List<HabitLog>> getLogsForDate(DateTime date) async {
    try {
      final normalizedDate = _normalizeDate(date);
      return _logsBox.values
          .where(
            (model) => _normalizeDate(model.date) == normalizedDate,
          )
          .map((model) => model.toEntity())
          .toList();
    } catch (e, st) {
      _logger.severe('Failed to get logs for date: $date', e, st);
      throw HabitStorageFailure(e.toString());
    }
  }

  @override
  Future<void> saveLog(HabitLog log) async {
    try {
      final model = HabitLogModel.fromEntity(log);
      final key = _logKey(log.date, log.habitId);
      await _logsBox.put(key, model);
    } catch (e, st) {
      _logger.severe('Failed to save log: ${log.id}', e, st);
      throw HabitStorageFailure(e.toString());
    }
  }

  @override
  Future<void> deleteLog(String id) async {
    try {
      // Find the log with the matching ID
      final entry = _logsBox.toMap().entries.firstWhere(
            (entry) => entry.value.id == id,
            orElse: () => throw HabitNotFoundFailure(id),
          );
      await _logsBox.delete(entry.key);
    } on HabitNotFoundFailure {
      rethrow;
    } catch (e, st) {
      _logger.severe('Failed to delete log: $id', e, st);
      throw HabitStorageFailure(e.toString());
    }
  }

  /// Generates a key for a habit log in format `log:{date}:{habitId}`.
  String _logKey(DateTime date, String habitId) {
    final dateStr = _dateToIsoString(date);
    return 'log:$dateStr:$habitId';
  }

  /// Converts date to ISO8601 string without time component.
  String _dateToIsoString(DateTime date) {
    final normalized = _normalizeDate(date);
    return normalized.toIso8601String().split('T').first;
  }

  /// Normalizes a date to midnight UTC.
  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }
}
