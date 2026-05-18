import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:forma/features/habits/domain/entities/habit_log.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:forma/features/habits/domain/usecases/compute_daily_completion_scores.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late ComputeDailyCompletionScores useCase;
  late MockHabitRepository mockRepository;

  setUp(() {
    mockRepository = MockHabitRepository();
    useCase = ComputeDailyCompletionScores(mockRepository);
  });

  group('ComputeDailyCompletionScores', () {
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2024, 1, 7);

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

    test('should return empty map when no active habits exist', () async {
      // Arrange
      when(() => mockRepository.getAll()).thenAnswer((_) async => []);

      // Act
      final result = await useCase.call(startDate, endDate);

      // Assert
      expect(result, isEmpty);
    });

    test('should return empty map when all habits are archived', () async {
      // Arrange
      final archivedHabit = habit1.copyWith(isArchived: true);
      when(() => mockRepository.getAll()).thenAnswer((_) async => [archivedHabit]);

      // Act
      final result = await useCase.call(startDate, endDate);

      // Assert
      expect(result, isEmpty);
    });

    test('should compute scores for all days in range', () async {
      // Arrange
      when(() => mockRepository.getAll()).thenAnswer((_) async => [habit1]);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => []);

      // Act
      final result = await useCase.call(startDate, endDate);

      // Assert
      expect(result.length, equals(7));
      expect(result.keys, contains(DateTime.utc(2024, 1, 1)));
      expect(result.keys, contains(DateTime.utc(2024, 1, 7)));
    });

    test('should return 0.0 for days with no completions', () async {
      // Arrange
      when(() => mockRepository.getAll()).thenAnswer((_) async => [habit1]);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => []);

      // Act
      final result = await useCase.call(startDate, endDate);

      // Assert
      expect(result.values.every((score) => score == 0.0), isTrue);
    });

    test('should return 1.0 for days with all habits completed', () async {
      // Arrange
      final logs = [
        HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          date: DateTime.utc(2024, 1, 1),
          completedAt: DateTime(2024, 1, 1, 10, 0),
        ),
      ];

      when(() => mockRepository.getAll()).thenAnswer((_) async => [habit1]);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => logs);

      // Act
      final result = await useCase.call(startDate, endDate);

      // Assert
      expect(result[DateTime.utc(2024, 1, 1)], equals(1.0));
      // Other days should be 0.0
      expect(result[DateTime.utc(2024, 1, 2)], equals(0.0));
    });

    test('should handle partial completions correctly', () async {
      // Arrange
      final logs = [
        HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          date: DateTime.utc(2024, 1, 1),
          completedAt: DateTime(2024, 1, 1, 10, 0),
        ),
      ];

      when(() => mockRepository.getAll())
          .thenAnswer((_) async => [habit1, habit2]);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => logs);

      // Act
      final result = await useCase.call(startDate, endDate);

      // Assert - 1 out of 2 habits completed = 0.5
      expect(result[DateTime.utc(2024, 1, 1)], equals(0.5));
    });

    test('should handle single day range', () async {
      // Arrange
      when(() => mockRepository.getAll()).thenAnswer((_) async => [habit1]);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => []);

      // Act
      final result = await useCase.call(startDate, startDate);

      // Assert
      expect(result.length, equals(1));
      expect(result.keys.first, equals(DateTime.utc(2024, 1, 1)));
    });

    test('should throw ArgumentError when start is after end', () async {
      // Act & Assert
      expect(
        () => useCase.call(endDate, startDate),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should normalize dates to midnight UTC', () async {
      // Arrange
      final startWithTime = DateTime(2024, 1, 1, 14, 30, 45);
      final endWithTime = DateTime(2024, 1, 7, 10, 15, 30);

      when(() => mockRepository.getAll()).thenAnswer((_) async => [habit1]);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => []);

      // Act
      final result = await useCase.call(startWithTime, endWithTime);

      // Assert
      expect(result.keys.first, equals(DateTime.utc(2024, 1, 1)));
      expect(result.keys.last, equals(DateTime.utc(2024, 1, 7)));
    });

    test('should exclude archived habits from calculations', () async {
      // Arrange
      final archivedHabit = Habit(
        id: 'habit-archived',
        name: 'Archived Habit',
        icon: '🗃️',
        color: '#8C7B6A',
        sortOrder: 2,
        createdAt: DateTime(2024, 1, 3),
        isArchived: true,
      );

      final logs = [
        HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          date: DateTime.utc(2024, 1, 1),
          completedAt: DateTime(2024, 1, 1, 10, 0),
        ),
      ];

      when(() => mockRepository.getAll())
          .thenAnswer((_) async => [habit1, archivedHabit]);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => logs);

      // Act
      final result = await useCase.call(startDate, endDate);

      // Assert - Only 1 active habit, completed = 1.0
      expect(result[DateTime.utc(2024, 1, 1)], equals(1.0));
    });

    test('should handle logs outside date range', () async {
      // Arrange
      final logs = [
        HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          date: DateTime.utc(2023, 12, 31), // Before start
          completedAt: DateTime(2023, 12, 31, 10, 0),
        ),
        HabitLog(
          id: 'log-2',
          habitId: 'habit-1',
          date: DateTime.utc(2024, 1, 8), // After end
          completedAt: DateTime(2024, 1, 8, 10, 0),
        ),
      ];

      when(() => mockRepository.getAll()).thenAnswer((_) async => [habit1]);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => logs);

      // Act
      final result = await useCase.call(startDate, endDate);

      // Assert - All days in range should be 0.0
      expect(result.values.every((score) => score == 0.0), isTrue);
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.getAll()).thenThrow(Exception('DB error'));

      // Act & Assert
      expect(
        () => useCase.call(startDate, endDate),
        throwsA(isA<Exception>()),
      );
    });
  });
}
