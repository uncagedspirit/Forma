import 'package:forma/features/mood/data/models/mood_model.dart';
import 'package:forma/features/mood/domain/entities/mood_entry.dart';
import 'package:forma/features/mood/domain/failures/mood_failures.dart';
import 'package:forma/features/mood/domain/repositories/mood_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

/// Hive-backed implementation of [MoodRepository].
class MoodRepositoryImpl implements MoodRepository {
  MoodRepositoryImpl(this._box) : _logger = Logger('MoodRepositoryImpl');

  final Box<MoodModel> _box;
  final Logger _logger;

  /// Normalizes a date to midnight UTC for consistent key generation.
  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  /// Converts a normalized date to an ISO8601 string key.
  String _dateToKey(DateTime date) {
    final normalized = _normalizeDate(date);
    return normalized.toIso8601String();
  }

  @override
  Future<List<MoodEntry>> getAll() async {
    try {
      return _box.values.map((model) => model.toEntity()).toList();
    } catch (e, st) {
      _logger.severe('Failed to get all mood entries', e, st);
      throw MoodStorageFailure(e.toString());
    }
  }

  @override
  Future<MoodEntry?> getByDate(DateTime date) async {
    try {
      final key = _dateToKey(date);
      final model = _box.get(key);
      return model?.toEntity();
    } catch (e, st) {
      _logger.severe('Failed to get mood entry by date: $date', e, st);
      throw MoodStorageFailure(e.toString());
    }
  }

  @override
  Future<List<MoodEntry>> getByDateRange(DateTime start, DateTime end) async {
    try {
      final normalizedStart = _normalizeDate(start);
      final normalizedEnd = _normalizeDate(end);

      return _box.values
          .where((model) {
            final modelDate = _normalizeDate(model.date);
            return !modelDate.isBefore(normalizedStart) && !modelDate.isAfter(normalizedEnd);
          })
          .map((model) => model.toEntity())
          .toList();
    } catch (e, st) {
      _logger.severe('Failed to get mood entries by date range: $start to $end', e, st);
      throw MoodStorageFailure(e.toString());
    }
  }

  @override
  Future<void> save(MoodEntry entry) async {
    try {
      final key = _dateToKey(entry.date);
      final model = MoodModel.fromEntity(entry);
      await _box.put(key, model);
    } catch (e, st) {
      _logger.severe('Failed to save mood entry: ${entry.date}', e, st);
      throw MoodStorageFailure(e.toString());
    }
  }

  @override
  Future<void> delete(DateTime date) async {
    try {
      final key = _dateToKey(date);
      await _box.delete(key);
    } catch (e, st) {
      _logger.severe('Failed to delete mood entry for date: $date', e, st);
      throw MoodStorageFailure(e.toString());
    }
  }
}
