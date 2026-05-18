import 'package:forma/features/mood/data/repositories/mood_repository_provider.dart';
import 'package:forma/features/mood/domain/usecases/log_mood.dart';
import 'package:forma/features/mood/presentation/providers/mood_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'log_mood_provider.g.dart';

@riverpod
class LogMoodNotifier extends _$LogMoodNotifier {
  @override
  Future<void> build() async {}

  Future<void> log(DateTime date, int value, String? note) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(moodRepositoryProvider);
      final useCase = LogMood(repo);
      await useCase.call(date: date, value: value, note: note);
      ref.invalidate(moodForDateProvider(date));
    });
  }
}
