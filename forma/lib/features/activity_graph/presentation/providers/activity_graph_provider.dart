import 'package:forma/features/activity_graph/domain/entities/activity_graph_data.dart';
import 'package:forma/features/activity_graph/domain/entities/activity_level.dart';
import 'package:forma/features/habits/data/repositories/habit_repository_provider.dart';
import 'package:forma/features/habits/domain/usecases/compute_daily_completion_scores.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_graph_provider.g.dart';

/// Maps daily completion scores to [ActivityGraphData] for the GitHub-style
/// contribution graph.
///
/// Thresholds per ARCHITECTURE.md §5:
/// - 0% → none
/// - > 0%, ≤ 25% → light
/// - > 25%, ≤ 60% → medium
/// - > 60%, < 100% → dark
/// - 100% → full
@riverpod
Future<Map<DateTime, ActivityGraphData>> activityGraph(
  ActivityGraphRef ref,
  DateTime start,
  DateTime end,
) async {
  final habitRepo = ref.watch(habitRepositoryProvider);
  final useCase = ComputeDailyCompletionScores(habitRepo);
  final scores = await useCase.call(start, end);
  final allHabits = await habitRepo.getAll();
  final total = allHabits.where((h) => !h.isArchived).length;

  return scores.map((date, ratio) {
    final completed = total > 0 ? (ratio * total).round() : 0;
    return MapEntry(
      date,
      ActivityGraphData(
        level: _mapToActivityLevel(ratio),
        completed: completed,
        total: total,
      ),
    );
  });
}

ActivityLevel _mapToActivityLevel(double ratio) {
  if (ratio == 0) return ActivityLevel.none;
  if (ratio <= 0.25) return ActivityLevel.light;
  if (ratio <= 0.60) return ActivityLevel.medium;
  if (ratio < 1.0) return ActivityLevel.dark;
  return ActivityLevel.full;
}
