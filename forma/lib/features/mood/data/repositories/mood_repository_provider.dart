import 'package:forma/core/storage/hive_service.dart';
import 'package:forma/features/mood/data/repositories/mood_repository_impl.dart';
import 'package:forma/features/mood/domain/repositories/mood_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mood_repository_provider.g.dart';

@riverpod
MoodRepository moodRepository(MoodRepositoryRef ref) {
  return MoodRepositoryImpl(HiveService.moodBox);
}
