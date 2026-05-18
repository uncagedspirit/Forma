import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:forma/features/habits/domain/entities/habit_log.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:forma/features/habits/domain/usecases/complete_habit.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

class FakeHabitLog extends Fake implements HabitLog {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeHabitLog());
  });
  late CompleteHabit useCase;
  late MockHabitRepository mockHabitRepository;
  late MockHabitRepository mockLogRepository;

  setUp(() {
    mockHabitRepository = MockHabitRepository();
    mockLogRepository = MockHabitRepository();
    useCase = CompleteHabit(mockHabitRepository, mockLogRepository);
  });

  group('CompleteHabit', () {
    const testHabitId = 'test-habit-id';
    final testDate = DateTime(2024, 1, 15);
    final normalizedDate = DateTime.utc(2024, 1, 15);

    final testHabit = Habit(
      id: testHabitId,
      name: 'Test Habit',
      icon: '✅',
      color: '#5A7A5C',
      sortOrder: 0,
      createdAt: DateTime(2024, 1, 1),
      isArchived: false,
    );

    test('should create new log when habit not yet completed for date',
        () async {
      // Arrange
      when(() => mockHabitRepository.getById(testHabitId))
          .thenAnswer((_) async => testHabit);
      when(() => mockLogRepository.getLogsForDate(normalizedDate))
          .thenAnswer((_) async => []);
      when(() => mockLogRepository.saveLog(any())).thenAnswer((_) async {});

      // Act
      final result = await useCase.call(habitId: testHabitId, date: testDate);

      // Assert
      expect(result.habitId, equals(testHabitId));
      expect(result.date, equals(normalizedDate));
      verify(() => mockLogRepository.saveLog(any())).called(1);
    });

    test('should return existing log when habit already completed for date',
        () async {
      // Arrange
      final existingLog = HabitLog(
        id: 'existing-log-id',
        habitId: testHabitId,
        date: normalizedDate,
        completedAt: DateTime(2024, 1, 15, 10, 0),
      );

      when(() => mockHabitRepository.getById(testHabitId))
          .thenAnswer((_) async => testHabit);
      when(() => mockLogRepository.getLogsForDate(normalizedDate))
          .thenAnswer((_) async => [existingLog]);

      // Act
      final result = await useCase.call(habitId: testHabitId, date: testDate);

      // Assert
      expect(result.id, equals('existing-log-id'));
      verifyNever(() => mockLogRepository.saveLog(any()));
    });

    test('should throw ArgumentError when habit does not exist', () async {
      // Arrange
      when(() => mockHabitRepository.getById(testHabitId))
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase.call(habitId: testHabitId, date: testDate),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Habit not found'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when habit is archived', () async {
      // Arrange
      final archivedHabit = testHabit.copyWith(isArchived: true);
      when(() => mockHabitRepository.getById(testHabitId))
          .thenAnswer((_) async => archivedHabit);

      // Act & Assert
      expect(
        () => useCase.call(habitId: testHabitId, date: testDate),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('archived'),
          ),
        ),
      );
    });

    test('should normalize date to midnight UTC', () async {
      // Arrange
      final dateWithTime = DateTime(2024, 1, 15, 14, 30, 45);
      when(() => mockHabitRepository.getById(testHabitId))
          .thenAnswer((_) async => testHabit);
      when(() => mockLogRepository.getLogsForDate(normalizedDate))
          .thenAnswer((_) async => []);
      when(() => mockLogRepository.saveLog(any())).thenAnswer((_) async {});

      // Act
      final result = await useCase.call(
        habitId: testHabitId,
        date: dateWithTime,
      );

      // Assert
      expect(result.date, equals(normalizedDate));
      expect(result.date.hour, equals(0));
      expect(result.date.minute, equals(0));
      expect(result.date.second, equals(0));
      expect(result.date.isUtc, isTrue);
    });

    test('should generate unique log ID', () async {
      // Arrange
      when(() => mockHabitRepository.getById(testHabitId))
          .thenAnswer((_) async => testHabit);
      when(() => mockLogRepository.getLogsForDate(normalizedDate))
          .thenAnswer((_) async => []);
      when(() => mockLogRepository.saveLog(any())).thenAnswer((_) async {});

      // Act
      final result = await useCase.call(habitId: testHabitId, date: testDate);

      // Assert
      expect(result.id, isNotEmpty);
      expect(result.id.length, equals(36)); // UUID v4 length
    });

    test('should set completedAt to current time', () async {
      // Arrange
      final before = DateTime.now();
      when(() => mockHabitRepository.getById(testHabitId))
          .thenAnswer((_) async => testHabit);
      when(() => mockLogRepository.getLogsForDate(normalizedDate))
          .thenAnswer((_) async => []);
      when(() => mockLogRepository.saveLog(any())).thenAnswer((_) async {});

      // Act
      final result = await useCase.call(habitId: testHabitId, date: testDate);
      final after = DateTime.now();

      // Assert
      expect(
        result.completedAt.isAfter(
          before.subtract(const Duration(seconds: 1)),
        ),
        isTrue,
      );
      expect(
        result.completedAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('should differentiate between different habits on same date', () async {
      // Arrange
      const otherHabitId = 'other-habit-id';
      final otherLog = HabitLog(
        id: 'other-log-id',
        habitId: otherHabitId,
        date: normalizedDate,
        completedAt: DateTime(2024, 1, 15, 10, 0),
      );

      when(() => mockHabitRepository.getById(testHabitId))
          .thenAnswer((_) async => testHabit);
      when(() => mockLogRepository.getLogsForDate(normalizedDate))
          .thenAnswer((_) async => [otherLog]);
      when(() => mockLogRepository.saveLog(any())).thenAnswer((_) async {});

      // Act
      final result = await useCase.call(habitId: testHabitId, date: testDate);

      // Assert - Should create new log since it's a different habit
      expect(result.habitId, equals(testHabitId));
      verify(() => mockLogRepository.saveLog(any())).called(1);
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockHabitRepository.getById(testHabitId))
          .thenThrow(Exception('DB error'));

      // Act & Assert
      expect(
        () => useCase.call(habitId: testHabitId, date: testDate),
        throwsA(isA<Exception>()),
      );
    });
  });
}
