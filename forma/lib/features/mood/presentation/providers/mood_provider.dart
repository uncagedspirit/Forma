import 'package:forma/features/mood/data/repositories/mood_repository_provider.dart';
import 'package:forma/features/mood/domain/entities/mood_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mood_provider.g.dart';

@riverpod
Future<MoodEntry?> moodForDate(MoodForDateRef ref, DateTime date) async {
  final repo = ref.watch(moodRepositoryProvider);
  return repo.getByDate(date);
}
