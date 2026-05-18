import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/goals/data/models/goal_model.dart';
import 'package:forma/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:forma/features/goals/domain/entities/goal.dart';
import 'package:forma/features/goals/domain/failures/goal_failures.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('GoalRepositoryImpl', () {
    late Directory tempDir;
    late Box<GoalModel> goalsBox;
    late GoalRepositoryImpl repository;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_test_');
      Hive.init(tempDir.path);

      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(GoalModelAdapter());
      }
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    setUp(() async {
      goalsBox = await Hive.openBox<GoalModel>('test_goals_${DateTime.now().millisecondsSinceEpoch}');
      repository = GoalRepositoryImpl(goalsBox);
    });

    tearDown(() async {
      await goalsBox.close();
    });

    group('save and roundtrip', () {
      test('should save a goal and retrieve it', () async {
        final goal = Goal(
          id: 'goal-1',
          name: 'Learn Flutter',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.save(goal);
        final retrieved = await repository.getById('goal-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(goal.id));
        expect(retrieved.name, equals(goal.name));
        expect(retrieved.color, equals(goal.color));
        expect(retrieved.sortOrder, equals(goal.sortOrder));
        expect(retrieved.isArchived, equals(goal.isArchived));
      });

      test('should update an existing goal', () async {
        final goal = Goal(
          id: 'goal-1',
          name: 'Learn Flutter',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.save(goal);

        final updatedGoal = goal.copyWith(name: 'Master Flutter');
        await repository.save(updatedGoal);

        final retrieved = await repository.getById('goal-1');
        expect(retrieved!.name, equals('Master Flutter'));
      });

      test('should preserve all goal properties', () async {
        final goal = Goal(
          id: 'goal-1',
          name: 'Learn Dart',
          color: '#0175C2',
          sortOrder: 5,
          createdAt: DateTime(2024, 6, 15),
          isArchived: true,
        );

        await repository.save(goal);
        final retrieved = await repository.getById('goal-1');

        expect(retrieved!.id, equals('goal-1'));
        expect(retrieved.name, equals('Learn Dart'));
        expect(retrieved.color, equals('#0175C2'));
        expect(retrieved.sortOrder, equals(5));
        expect(retrieved.createdAt, equals(DateTime(2024, 6, 15)));
        expect(retrieved.isArchived, isTrue);
      });
    });

    group('getAll', () {
      test('should return empty list when no goals exist', () async {
        final goals = await repository.getAll();
        expect(goals, isEmpty);
      });

      test('should return only non-archived goals', () async {
        final activeGoal = Goal(
          id: 'goal-active',
          name: 'Active Goal',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
          isArchived: false,
        );
        final archivedGoal = Goal(
          id: 'goal-archived',
          name: 'Archived Goal',
          color: '#B85C38',
          sortOrder: 1,
          createdAt: DateTime(2024, 1, 15),
          isArchived: true,
        );

        await repository.save(activeGoal);
        await repository.save(archivedGoal);

        final goals = await repository.getAll();
        expect(goals.length, equals(1));
        expect(goals.first.id, equals('goal-active'));
      });

      test('should return multiple active goals', () async {
        final goal1 = Goal(
          id: 'goal-1',
          name: 'Goal 1',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
        );
        final goal2 = Goal(
          id: 'goal-2',
          name: 'Goal 2',
          color: '#B85C38',
          sortOrder: 1,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.save(goal1);
        await repository.save(goal2);

        final goals = await repository.getAll();
        expect(goals.length, equals(2));
        expect(goals.map((g) => g.id).toSet(), equals({'goal-1', 'goal-2'}));
      });
    });

    group('getById', () {
      test('should return null for non-existent goal', () async {
        final goal = await repository.getById('non-existent');
        expect(goal, isNull);
      });

      test('should return correct goal for existing id', () async {
        final goal = Goal(
          id: 'goal-1',
          name: 'My Goal',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.save(goal);
        final retrieved = await repository.getById('goal-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('goal-1'));
        expect(retrieved.name, equals('My Goal'));
      });
    });

    group('delete', () {
      test('should delete a goal', () async {
        final goal = Goal(
          id: 'goal-1',
          name: 'Goal to Delete',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.save(goal);
        expect(await repository.getById('goal-1'), isNotNull);

        await repository.delete('goal-1');
        expect(await repository.getById('goal-1'), isNull);
      });

      test('should not throw when deleting non-existent goal', () async {
        expect(() => repository.delete('non-existent'), returnsNormally);
      });
    });

    group('reorder', () {
      test('should update sort order of goals', () async {
        final goal1 = Goal(
          id: 'goal-1',
          name: 'Goal 1',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
        );
        final goal2 = Goal(
          id: 'goal-2',
          name: 'Goal 2',
          color: '#B85C38',
          sortOrder: 1,
          createdAt: DateTime(2024, 1, 15),
        );
        final goal3 = Goal(
          id: 'goal-3',
          name: 'Goal 3',
          color: '#4A5568',
          sortOrder: 2,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.save(goal1);
        await repository.save(goal2);
        await repository.save(goal3);

        // Reorder: goal-3 first, then goal-1, then goal-2
        await repository.reorder(['goal-3', 'goal-1', 'goal-2']);

        final goal3Retrieved = await repository.getById('goal-3');
        final goal1Retrieved = await repository.getById('goal-1');
        final goal2Retrieved = await repository.getById('goal-2');

        expect(goal3Retrieved!.sortOrder, equals(0));
        expect(goal1Retrieved!.sortOrder, equals(1));
        expect(goal2Retrieved!.sortOrder, equals(2));
      });

      test('should handle partial reorder with missing ids', () async {
        final goal1 = Goal(
          id: 'goal-1',
          name: 'Goal 1',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.save(goal1);

        // Reorder with non-existent goal
        await repository.reorder(['goal-2', 'goal-1']);

        final goal1Retrieved = await repository.getById('goal-1');
        expect(goal1Retrieved!.sortOrder, equals(1));
      });

      test('should handle empty reorder list', () async {
        expect(() => repository.reorder([]), returnsNormally);
      });
    });

    group('error handling', () {
      test('should throw GoalStorageFailure on save error', () async {
        // Close the box to simulate an error
        await goalsBox.close();

        final goal = Goal(
          id: 'goal-1',
          name: 'Test Goal',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(
          () => repository.save(goal),
          throwsA(isA<GoalStorageFailure>()),
        );
      });

      test('should throw GoalStorageFailure on getAll error', () async {
        // Close the box to simulate an error
        await goalsBox.close();

        expect(
          () => repository.getAll(),
          throwsA(isA<GoalStorageFailure>()),
        );
      });

      test('should throw GoalStorageFailure on getById error', () async {
        // Close the box to simulate an error
        await goalsBox.close();

        expect(
          () => repository.getById('goal-1'),
          throwsA(isA<GoalStorageFailure>()),
        );
      });

      test('should throw GoalStorageFailure on delete error', () async {
        // Close the box to simulate an error
        await goalsBox.close();

        expect(
          () => repository.delete('goal-1'),
          throwsA(isA<GoalStorageFailure>()),
        );
      });

      test('should throw GoalStorageFailure on reorder error', () async {
        // Close the box to simulate an error
        await goalsBox.close();

        expect(
          () => repository.reorder(['goal-1']),
          throwsA(isA<GoalStorageFailure>()),
        );
      });
    });
  });
}
