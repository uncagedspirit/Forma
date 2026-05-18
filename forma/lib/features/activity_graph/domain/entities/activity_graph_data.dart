import 'package:forma/features/activity_graph/domain/entities/activity_level.dart';

/// Data model for a single day in the activity graph.
///
/// Contains the activity level, number of completed habits, and total habits
/// for that day.
class ActivityGraphData {
  const ActivityGraphData({
    required this.level,
    required this.completed,
    required this.total,
  });

  final ActivityLevel level;
  final int completed;
  final int total;
}
