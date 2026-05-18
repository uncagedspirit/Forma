import 'package:forma/features/mood/data/repositories/mood_repository_provider.dart';
import 'package:forma/features/mood/domain/entities/mood_entry.dart';
import 'package:forma/features/mood/domain/repositories/mood_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mood_week_provider.g.dart';

/// Returns the last 7 days of mood entries (including nulls for missing days).
///
/// The list is ordered chronologically from 6 days ago to today.
@riverpod
Future<List<MoodEntry?>> moodWeek(MoodWeekRef ref) async {
  final MoodRepository repo = ref.watch(moodRepositoryProvider);

  final now = DateTime.now();
  final today = DateTime.utc(now.year, now.month, now.day);
  final start = today.subtract(const Duration(days: 6));

  final entries = await repo.getByDateRange(start, today);

  final entriesByDate = <DateTime, MoodEntry>{};
  for (final entry in entries) {
    final date = DateTime.utc(entry.date.year, entry.date.month, entry.date.day);
    entriesByDate[date] = entry;
  }

  final result = <MoodEntry?>[];
  for (var i = 0; i < 7; i++) {
    final date = start.add(Duration(days: i));
    result.add(entriesByDate[date]);
  }

  return result;
}
