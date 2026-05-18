import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:forma/features/habits/domain/entities/habit_log.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:forma/features/habits/domain/usecases/get_habits_for_date.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late GetHabitsForDate useCase;
  late MockHabitRepository mockRepository;

  setUp(() {
    mockRepository = MockHabitRepository();
    useCase = GetHabitsForDate(mockRepository);
  });

  group('GetHabitsForDate', () {
    final testDate = DateTime(2024, 1, 15);
    final normalizedDate = DateTime.utc(2024, 1, 15);

    final habit1 = Habit(
      id: 'habit-1',
      name: 'Habit One',
      icon: '1️⃣',
      color: '#5A7A5C',
      sortOrder: 2,
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
      sortOrder: 3,
      createdAt: DateTime(2024, 1, 3),
      isArchived: true, // Archived
    );

    test('should return empty list when no habits exist', () async {
      // Arrange
      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getLogsForDate(normalizedDate))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.call(testDate);

      // Assert
      expect(result, isEmpty);
    });

    test('should return habits with correct completion status', () async {
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

      // Assert - Results are sorted by sortOrder (habit2 has sortOrder 1, habit1 has sortOrder 2)
      expect(result.length, equals(2));
      expect(result[0].habit.id, equals('habit-2'));
      expect(result[0].isCompleted, isFalse);
      expect(result[1].habit.id, equals('habit-1'));
      expect(result[1].isCompleted, isTrue);
    });

    test('should exclude archived habits', () async {
      // Arrange
      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenAnswer((_) async => [habit1, habit2, habit3]);
      when(() => mockRepository.getLogsForDate(normalizedDate))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.call(testDate);

      // Assert
      expect(result.length, equals(2));
      expect(result.any((h) => h.habit.id == 'habit-3'), isFalse);
    });

    test('should sort habits by sortOrder', () async {
      // Arrange
      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenAnswer((_) async => [habit1, habit2]);
      when(() => mockRepository.getLogsForDate(normalizedDate))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.call(testDate);

      // Assert - Should be sorted by sortOrder (1, 2)
      expect(result[0].habit.sortOrder, equals(1));
      expect(result[0].habit.id, equals('habit-2'));
      expect(result[1].habit.sortOrder, equals(2));
      expect(result[1].habit.id, equals('habit-1'));
    });

    test('should normalize date to midnight UTC', () async {
      // Arrange
      final dateWithTime = DateTime(2024, 1, 15, 14, 30, 45);
      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getLogsForDate(normalizedDate))
          .thenAnswer((_) async => []);

      // Act
      await useCase.call(dateWithTime);

      // Assert
      verify(() => mockRepository.getHabitsForDate(normalizedDate)).called(1);
      verify(() => mockRepository.getLogsForDate(normalizedDate)).called(1);
    });

    test('should handle all habits completed', () async {
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
      expect(result.every((h) => h.isCompleted), isTrue);
    });

    test('should handle no habits completed', () async {
      // Arrange
      when(() => mockRepository.getHabitsForDate(normalizedDate))
          .thenAnswer((_) async => [habit1, habit2]);
      when(() => mockRepository.getLogsForDate(normalizedDate))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.call(testDate);

      // Assert
      expect(result.every((h) => !h.isCompleted), isTrue);
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
