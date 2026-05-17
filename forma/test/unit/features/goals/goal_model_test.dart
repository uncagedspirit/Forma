import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/goals/data/models/goal_model.dart';
import 'package:forma/features/goals/domain/entities/goal.dart';

void main() {
  group('GoalModel', () {
    final testGoal = Goal(
      id: 'goal-id-123',
      name: 'Read More Books',
      color: '#A07830',
      sortOrder: 2,
      createdAt: DateTime(2024, 2, 10, 14, 30),
      isArchived: false,
    );

    final testModel = GoalModel(
      id: 'goal-id-123',
      name: 'Read More Books',
      color: '#A07830',
      sortOrder: 2,
      createdAt: DateTime(2024, 2, 10, 14, 30),
      isArchived: false,
    );

    group('toEntity', () {
      test('should convert GoalModel to Goal entity', () {
        final entity = testModel.toEntity();

        expect(entity.id, equals(testModel.id));
        expect(entity.name, equals(testModel.name));
        expect(entity.color, equals(testModel.color));
        expect(entity.sortOrder, equals(testModel.sortOrder));
        expect(entity.createdAt, equals(testModel.createdAt));
        expect(entity.isArchived, equals(testModel.isArchived));
      });
    });

    group('fromEntity', () {
      test('should create GoalModel from Goal entity', () {
        final model = GoalModel.fromEntity(testGoal);

        expect(model.id, equals(testGoal.id));
        expect(model.name, equals(testGoal.name));
        expect(model.color, equals(testGoal.color));
        expect(model.sortOrder, equals(testGoal.sortOrder));
        expect(model.createdAt, equals(testGoal.createdAt));
        expect(model.isArchived, equals(testGoal.isArchived));
      });
    });

    group('roundtrip', () {
      test('should preserve all fields through model → entity → model conversion', () {
        final entity = testModel.toEntity();
        final roundtripModel = GoalModel.fromEntity(entity);

        expect(roundtripModel.id, equals(testModel.id));
        expect(roundtripModel.name, equals(testModel.name));
        expect(roundtripModel.color, equals(testModel.color));
        expect(roundtripModel.sortOrder, equals(testModel.sortOrder));
        expect(roundtripModel.createdAt, equals(testModel.createdAt));
        expect(roundtripModel.isArchived, equals(testModel.isArchived));
      });

      test('should preserve all fields through entity → model → entity conversion', () {
        final model = GoalModel.fromEntity(testGoal);
        final roundtripEntity = model.toEntity();

        expect(roundtripEntity, equals(testGoal));
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        final copied = testModel.copyWith(
          name: 'Read Even More Books',
          sortOrder: 3,
          isArchived: true,
        );

        expect(copied.id, equals(testModel.id));
        expect(copied.name, equals('Read Even More Books'));
        expect(copied.sortOrder, equals(3));
        expect(copied.isArchived, isTrue);
        expect(copied.color, equals(testModel.color));
      });

      test('should keep original values when null is passed', () {
        final copied = testModel.copyWith();

        expect(copied.id, equals(testModel.id));
        expect(copied.name, equals(testModel.name));
        expect(copied.color, equals(testModel.color));
        expect(copied.sortOrder, equals(testModel.sortOrder));
        expect(copied.isArchived, equals(testModel.isArchived));
      });
    });

    group('default values', () {
      test('should default isArchived to false', () {
        final model = GoalModel(
          id: 'test',
          name: 'Test Goal',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime.now(),
        );

        expect(model.isArchived, isFalse);
      });
    });
  });
}