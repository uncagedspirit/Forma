import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:logging/logging.dart';

/// Use case for reordering habits.
///
/// Updates the sort order of habits based on the provided ordered list of IDs.
class ReorderHabits {
  const ReorderHabits(this._repository);

  final HabitRepository _repository;

  static final _logger = Logger('ReorderHabits');

  /// Reorders habits based on the given ordered list of habit IDs.
  ///
  /// [orderedIds] - A list of habit IDs in the desired order.
  ///                The index of each ID determines its new sortOrder.
  ///
  /// Throws [ArgumentError] if the orderedIds list is empty.
  Future<void> call(List<String> orderedIds) async {
    _logger.fine('Reordering ${orderedIds.length} habits');

    if (orderedIds.isEmpty) {
      _logger.warning('Cannot reorder: orderedIds list is empty');
      throw ArgumentError('Ordered IDs list cannot be empty');
    }

    await _repository.reorder(orderedIds);

    _logger.info('Successfully reordered ${orderedIds.length} habits');
  }
}
