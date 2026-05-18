import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:forma/features/habits/domain/entities/habit_log.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:forma/features/habits/domain/usecases/compute_completion_ratio.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late ComputeCompletionRatio useCase;
  late MockHabitRepository mockRepository;

  setUp(() {
    mockRepository = MockHabitRepository();
    useCase = ComputeCompletionRatio(mockRepository);
  });

  group('ComputeCompletionRatio', () {
    final testDate = DateTime(2024, 1, 15);
    final normalizedDate = DateTime.utc(2024, 1, 15);

    final habit1 = Habit(
      id: 'habit-1',
      name: 'Habit One',
      icon: '1️⃣',
      color: '#5A7A5C',
      sortOrder: 0,
      createdAt: DateTime(2024, 1, 1),
      isArchived: false,
    );

    final habit2 = Habit(
      id: 'habit-2',
      name: 'Habit Two',
      icon: '2️⃣',
      color: '#B85C38',
      sortOrder: 1,
      createdAt: DateTime(2024, 1, 2),
      isArchived: false,
    );

    final habit3 = Habit(
      id: 'habit-3',
      name: 'Habit Three',
      icon: '3️⃣',
      color: '#A07830',
      sortOrder: 2,
      createdAt: DateTime(2024, 1, 3),
      isArchived: true, // Archived
    );

    test('should return 0.0 when no active habits exist', () async {
      // Arrange
      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.call(testDate);

      // Assert
      expect(result, equals(0.0));
      verify(() => mockRepository.getHabitsForDate(normalizedDate)).called(1);
      verifyNever(() => mockRepository.getLogsForDate(any()));
    });

    test('should return 0.0 when all habits are archived', () async {
      // Arrange
      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenAnswer((_) async => [habit3]);

      // Act
      final result = await useCase.call(testDate);

      // Assert
      expect(result, equals(0.0));
    });

    test('should return 0.0 when no habits completed', () async {
      // Arrange
      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenAnswer((_) async => [habit1, habit2]);
      when(() => mockRepository.getLogsForDate(normalizedDate))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.call(testDate);

      // Assert
      expect(result, equals(0.0));
    });

    test('should return 1.0 when all habits completed', () async {
      // Arrange
      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenAnswer((_) async => [habit1, habit2]);
      when(() => mockRepository.getLogsForDate(normalizedDate)).thenAnswer(
        (_) async => [
          HabitLog(
            id: 'log-1',
            habitId: 'habit-1',
            date: normalizedDate,
            completedAt: DateTime(2024, 1, 15, 10, 0),
          ),
          HabitLog(
            id: 'log-2',
            habitId: 'habit-2',
            date: normalizedDate,
            completedAt: DateTime(2024, 1, 15, 11, 0),
          ),
        ],
      );

      // Act
      final result = await useCase.call(testDate);

      // Assert
      expect(result, equals(1.0));
    });

    test('should return 0.5 when half of habits completed', () async {
      // Arrange
      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenAnswer((_) async => [habit1, habit2]);
      when(() => mockRepository.getLogsForDate(normalizedDate)).thenAnswer(
        (_) async => [
          HabitLog(
            id: 'log-1',
            habitId: 'habit-1',
            date: normalizedDate,
            completedAt: DateTime(2024, 1, 15, 10, 0),
          ),
        ],
      );

      // Act
      final result = await useCase.call(testDate);

      // Assert
      expect(result, equals(0.5));
    });

    test('should exclude archived habits from calculation', () async {
      // Arrange
      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenAnswer((_) async => [habit1, habit2, habit3]);
      when(() => mockRepository.getLogsForDate(normalizedDate)).thenAnswer(
        (_) async => [
          HabitLog(
            id: 'log-1',
            habitId: 'habit-1',
            date: normalizedDate,
            completedAt: DateTime(2024, 1, 15, 10, 0),
          ),
        ],
      );

      // Act
      final result = await useCase.call(testDate);

      // Assert - Only 2 active habits, 1 completed = 0.5
      expect(result, equals(0.5));
    });

    test('should normalize date to midnight UTC', () async {
      // Arrange
      final dateWithTime = DateTime(2024, 1, 15, 14, 30, 45);
      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenAnswer((_) async => []);

      // Act
      await useCase.call(dateWithTime);

      // Assert
      verify(() => mockRepository.getHabitsForDate(normalizedDate)).called(1);
    });

    test('should return correct ratio for 3 habits with 1 completed', () async {
      // Arrange
      final habit4 = Habit(
        id: 'habit-4',
        name: 'Habit Four',
        icon: '4️⃣',
        color: '#8C7B6A',
        sortOrder: 3,
        createdAt: DateTime(2024, 1, 4),
        isArchived: false,
      );

      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenAnswer((_) async => [habit1, habit2, habit4]);
      when(() => mockRepository.getLogsForDate(normalizedDate)).thenAnswer(
        (_) async => [
          HabitLog(
            id: 'log-1',
            habitId: 'habit-1',
            date: normalizedDate,
            completedAt: DateTime(2024, 1, 15, 10, 0),
          ),
        ],
      );

      // Act
      final result = await useCase.call(testDate);

      // Assert - 1 out of 3 = 0.333...
      expect(result, closeTo(0.333, 0.001));
    });

    test('should handle logs for non-existent habits', () async {
      // Arrange
      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenAnswer((_) async => [habit1]);
      when(() => mockRepository.getLogsForDate(normalizedDate)).thenAnswer(
        (_) async => [
          HabitLog(
            id: 'log-1',
            habitId: 'non-existent-habit',
            date: normalizedDate,
            completedAt: DateTime(2024, 1, 15, 10, 0),
          ),
        ],
      );

      // Act
      final result = await useCase.call(testDate);

      // Assert - 0 out of 1 = 0.0 (log for non-existent habit ignored)
      expect(result, equals(0.0));
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenThrow(Exception('DB error'));

      // Act & Assert
      expect(
        () => useCase.call(testDate),
        throwsA(isA<Exception>()),
      );
    });
  });
}
