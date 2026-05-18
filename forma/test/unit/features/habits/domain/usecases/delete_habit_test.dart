import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:forma/features/habits/domain/failures/habit_failures.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:forma/features/habits/domain/usecases/delete_habit.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

class FakeHabit extends Fake implements Habit {}

void main() {
  late DeleteHabit useCase;
  late MockHabitRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeHabit());
  });

  setUp(() {
    mockRepository = MockHabitRepository();
    useCase = DeleteHabit(mockRepository);
  });

  group('DeleteHabit', () {
    const testId = 'test-habit-id';
    final testHabit = Habit(
      id: testId,
      name: 'Test Habit',
      icon: '✅',
      color: '#5A7A5C',
      sortOrder: 0,
      createdAt: DateTime(2024, 1, 1),
      isArchived: false,
    );

    test('should soft-delete habit by setting isArchived to true', () async {
      // Arrange
      when(() => mockRepository.getById(testId))
          .thenAnswer((_) async => testHabit);
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(testId);

      // Assert
      verify(() => mockRepository.getById(testId)).called(1);
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as Habit;
      expect(captured.id, equals(testId));
      expect(captured.isArchived, isTrue);
      expect(captured.name, equals(testHabit.name));
    });

    test('should throw HabitNotFoundFailure when habit does not exist',
        () async {
      // Arrange
      when(() => mockRepository.getById(testId)).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase.call(testId),
        throwsA(isA<HabitNotFoundFailure>()),
      );
      verify(() => mockRepository.getById(testId)).called(1);
      verifyNever(() => mockRepository.save(any()));
    });

    test('should allow soft-deleting already archived habit (idempotent)',
        () async {
      // Arrange
      final archivedHabit = testHabit.copyWith(isArchived: true);
      when(() => mockRepository.getById(testId))
          .thenAnswer((_) async => archivedHabit);
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act - This should still work since we're soft-deleting
      await useCase.call(testId);

      // Assert - Should set isArchived to true (idempotent)
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as Habit;
      expect(captured.isArchived, isTrue);
    });

    test('should preserve all other habit fields when soft-deleting', () async {
      // Arrange
      when(() => mockRepository.getById(testId))
          .thenAnswer((_) async => testHabit);
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(testId);

      // Assert
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as Habit;
      expect(captured.id, equals(testHabit.id));
      expect(captured.name, equals(testHabit.name));
      expect(captured.icon, equals(testHabit.icon));
      expect(captured.color, equals(testHabit.color));
      expect(captured.sortOrder, equals(testHabit.sortOrder));
      expect(captured.createdAt, equals(testHabit.createdAt));
    });

    test('should propagate repository getById errors', () async {
      // Arrange
      when(() => mockRepository.getById(testId))
          .thenThrow(const HabitStorageFailure('DB error'));

      // Act & Assert
      expect(
        () => useCase.call(testId),
        throwsA(isA<HabitStorageFailure>()),
      );
    });

    test('should propagate repository save errors', () async {
      // Arrange
      when(() => mockRepository.getById(testId))
          .thenAnswer((_) async => testHabit);
      when(() => mockRepository.save(any()))
          .thenThrow(const HabitStorageFailure('DB error'));

      // Act & Assert
      expect(
        () => useCase.call(testId),
        throwsA(isA<HabitStorageFailure>()),
      );
    });
  });
}
