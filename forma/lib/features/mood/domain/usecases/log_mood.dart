import 'package:forma/features/mood/domain/entities/mood_entry.dart';
import 'package:forma/features/mood/domain/repositories/mood_repository.dart';
import 'package:logging/logging.dart';

/// Use case for logging a mood entry.
///
/// Validates the mood value and upserts a mood entry for the given date.
class LogMood {
  const LogMood(this._repository);

  final MoodRepository _repository;

  static final _logger = Logger('LogMood');

  /// Logs a mood entry for the given date.
  ///
  /// [date] - The date for which to log the mood.
  /// [value] - The mood value, must be between 1 and 5 (inclusive).
  /// [note] - Optional note or journal entry associated with the mood.
  ///
  /// Throws [ArgumentError] if value is not between 1 and 5.
  Future<void> call({
    required DateTime date,
    required int value,
    String? note,
  }) async {
    _logger.fine('Logging mood for date: $date with value: $value');

    // Validate value is 1-5
    if (value < 1 || value > 5) {
      _logger.warning('Invalid mood value: $value (must be 1-5)');
      throw ArgumentError('Mood value must be between 1 and 5');
    }

    // Normalize date to midnight UTC
    final normalizedDate = DateTime.utc(date.year, date.month, date.day);

    // Create mood entry
    final entry = MoodEntry(
      date: normalizedDate,
      value: value,
      note: note?.trim(),
    );

    // Save (upsert) - repository handles overwrite
    await _repository.save(entry);

    _logger.info(
      'Successfully logged mood: $value for date: $normalizedDate',
    );
  }
}
