import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/habits/data/models/habit_model.dart';
import 'package:forma/features/habits/domain/entities/habit.dart';

void main() {
  group('HabitModel', () {
    final testHabit = Habit(
      id: 'test-id-123',
      name: 'Morning Meditation',
      icon: '🧘',
      goalId: 'goal-456',
      color: '#5A7A5C',
      sortOrder: 1,
      reminderTime: '08:00',
      reminderMessage: 'Time to meditate!',
      createdAt: DateTime(2024, 1, 15, 10, 30),
      isArchived: false,
    );

    final testModel = HabitModel(
      id: 'test-id-123',
      name: 'Morning Meditation',
      icon: '🧘',
      goalId: 'goal-456',
      color: '#5A7A5C',
      sortOrder: 1,
      reminderTime: '08:00',
      reminderMessage: 'Time to meditate!',
      createdAt: DateTime(2024, 1, 15, 10, 30),
      isArchived: false,
    );

    group('toEntity', () {
      test('should convert HabitModel to Habit entity', () {
        final entity = testModel.toEntity();

        expect(entity.id, equals(testModel.id));
        expect(entity.name, equals(testModel.name));
        expect(entity.icon, equals(testModel.icon));
        expect(entity.goalId, equals(testModel.goalId));
        expect(entity.color, equals(testModel.color));
        expect(entity.sortOrder, equals(testModel.sortOrder));
        expect(entity.reminderTime, equals(testModel.reminderTime));
        expect(entity.reminderMessage, equals(testModel.reminderMessage));
        expect(entity.createdAt, equals(testModel.createdAt));
        expect(entity.isArchived, equals(testModel.isArchived));
      });
    });

    group('fromEntity', () {
      test('should create HabitModel from Habit entity', () {
        final model = HabitModel.fromEntity(testHabit);

        expect(model.id, equals(testHabit.id));
        expect(model.name, equals(testHabit.name));
        expect(model.icon, equals(testHabit.icon));
        expect(model.goalId, equals(testHabit.goalId));
        expect(model.color, equals(testHabit.color));
        expect(model.sortOrder, equals(testHabit.sortOrder));
        expect(model.reminderTime, equals(testHabit.reminderTime));
        expect(model.reminderMessage, equals(testHabit.reminderMessage));
        expect(model.createdAt, equals(testHabit.createdAt));
        expect(model.isArchived, equals(testHabit.isArchived));
      });
    });

    group('roundtrip', () {
      test('should preserve all fields through model → entity → model conversion', () {
        final entity = testModel.toEntity();
        final roundtripModel = HabitModel.fromEntity(entity);

        expect(roundtripModel.id, equals(testModel.id));
        expect(roundtripModel.name, equals(testModel.name));
        expect(roundtripModel.icon, equals(testModel.icon));
        expect(roundtripModel.goalId, equals(testModel.goalId));
        expect(roundtripModel.color, equals(testModel.color));
        expect(roundtripModel.sortOrder, equals(testModel.sortOrder));
        expect(roundtripModel.reminderTime, equals(testModel.reminderTime));
        expect(roundtripModel.reminderMessage, equals(testModel.reminderMessage));
        expect(roundtripModel.createdAt, equals(testModel.createdAt));
        expect(roundtripModel.isArchived, equals(testModel.isArchived));
      });

      test('should preserve all fields through entity → model → entity conversion', () {
        final model = HabitModel.fromEntity(testHabit);
        final roundtripEntity = model.toEntity();

        expect(roundtripEntity, equals(testHabit));
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        final copied = testModel.copyWith(
          name: 'Evening Meditation',
          sortOrder: 2,
        );

        expect(copied.id, equals(testModel.id));
        expect(copied.name, equals('Evening Meditation'));
        expect(copied.sortOrder, equals(2));
        expect(copied.icon, equals(testModel.icon));
      });

      test('should keep original values when null is passed', () {
        final copied = testModel.copyWith();

        expect(copied.id, equals(testModel.id));
        expect(copied.name, equals(testModel.name));
        expect(copied.icon, equals(testModel.icon));
      });
    });

    group('null fields', () {
      test('should handle null goalId, reminderTime, and reminderMessage', () {
        final modelWithNulls = HabitModel(
          id: 'test-id',
          name: 'Simple Habit',
          icon: '📝',
          goalId: null,
          color: '#B85C38',
          sortOrder: 0,
          reminderTime: null,
          reminderMessage: null,
          createdAt: DateTime.now(),
          isArchived: false,
        );

        final entity = modelWithNulls.toEntity();
        expect(entity.goalId, isNull);
        expect(entity.reminderTime, isNull);
        expect(entity.reminderMessage, isNull);

        final roundtrip = HabitModel.fromEntity(entity);
        expect(roundtrip.goalId, isNull);
        expect(roundtrip.reminderTime, isNull);
        expect(roundtrip.reminderMessage, isNull);
      });
    });
  });
}