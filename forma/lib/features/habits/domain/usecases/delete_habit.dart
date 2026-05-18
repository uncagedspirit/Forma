import 'package:forma/features/habits/domain/failures/habit_failures.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:logging/logging.dart';

/// Use case for deleting (soft-deleting) a habit.
///
/// Performs a soft-delete by setting `isArchived` to true instead of
/// permanently removing the habit from storage.
class DeleteHabit {
  const DeleteHabit(this._repository);

  final HabitRepository _repository;

  static final _logger = Logger('DeleteHabit');

  /// Soft-deletes a habit by setting its `isArchived` flag to true.
  ///
  /// [id] - The unique identifier of the habit to delete.
  ///
  /// Throws [HabitNotFoundFailure] if the habit does not exist.
  Future<void> call(String id) async {
    _logger.fine('Attempting to soft-delete habit: $id');

    // Fetch the habit to ensure it exists
    final habit = await _repository.getById(id);

    if (habit == null) {
      _logger.warning('Cannot delete habit: habit not found (id: $id)');
      throw HabitNotFoundFailure(id);
    }

    // Perform soft-delete by setting isArchived to true
    final archivedHabit = habit.copyWith(isArchived: true);
    await _repository.save(archivedHabit);

    _logger.info('Successfully soft-deleted habit: ${habit.name} (id: $id)');
  }
}
