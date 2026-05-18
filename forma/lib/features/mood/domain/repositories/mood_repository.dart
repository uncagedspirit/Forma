import 'package:forma/features/mood/domain/entities/mood_entry.dart';

/// Abstract interface for mood entry data operations.
///
/// This interface defines all CRUD operations for mood entries.
/// Implementations should handle data persistence (e.g., Hive, Firebase, etc.).
abstract class MoodRepository {
  /// Gets all mood entries.
  Future<List<MoodEntry>> getAll();

  /// Gets a mood entry by its date.
  Future<MoodEntry?> getByDate(DateTime date);

  /// Gets mood entries within a date range.
  Future<List<MoodEntry>> getByDateRange(DateTime start, DateTime end);

  /// Saves a mood entry (creates or updates).
  Future<void> save(MoodEntry entry);

  /// Deletes a mood entry by its date.
  Future<void> delete(DateTime date);
}
