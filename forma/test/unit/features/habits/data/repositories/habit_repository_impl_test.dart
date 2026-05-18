import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/habits/data/models/habit_log_model.dart';
import 'package:forma/features/habits/data/models/habit_model.dart';
import 'package:forma/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:forma/features/habits/domain/entities/habit_log.dart';
import 'package:forma/features/habits/domain/failures/habit_failures.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('HabitRepositoryImpl', () {
    late Directory tempDir;
    late Box<HabitModel> habitsBox;
    late Box<HabitLogModel> logsBox;
    late HabitRepositoryImpl repository;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_test_');
      Hive.init(tempDir.path);

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HabitModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(HabitLogModelAdapter());
      }
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    setUp(() async {
      habitsBox = await Hive.openBox<HabitModel>('test_habits_${DateTime.now().millisecondsSinceEpoch}');
      logsBox = await Hive.openBox<HabitLogModel>('test_logs_${DateTime.now().millisecondsSinceEpoch}');
      repository = HabitRepositoryImpl(habitsBox, logsBox);
    });

    tearDown(() async {
      await habitsBox.close();
      await logsBox.close();
    });

    group('save and roundtrip', () {
      test('should save a habit and retrieve it', () async {
        final habit = Habit(
          id: 'habit-1',
          name: 'Morning Meditation',
          icon: '🧘',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.save(habit);
        final retrieved = await repository.getById('habit-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(habit.id));
        expect(retrieved.name, equals(habit.name));
        expect(retrieved.icon, equals(habit.icon));
        expect(retrieved.color, equals(habit.color));
        expect(retrieved.sortOrder, equals(habit.sortOrder));
      });

      test('should update an existing habit', () async {
        final habit = Habit(
          id: 'habit-1',
          name: 'Morning Meditation',
          icon: '🧘',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.save(habit);

        final updatedHabit = habit.copyWith(name: 'Evening Meditation');
        await repository.save(updatedHabit);

        final retrieved = await repository.getById('habit-1');
        expect(retrieved!.name, equals('Evening Meditation'));
      });
    });

    group('getAll', () {
      test('should return empty list when no habits exist', () async {
        final habits = await repository.getAll();
        expect(habits, isEmpty);
      });

      test('should return all saved habits', () async {
        final habit1 = Habit(
          id: 'habit-1',
          name: 'Meditation',
          icon: '🧘',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
        );
        final habit2 = Habit(
          id: 'habit-2',
          name: 'Exercise',
          icon: '💪',
          color: '#B85C38',
          sortOrder: 1,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.save(habit1);
        await repository.save(habit2);

        final habits = await repository.getAll();
        expect(habits.length, equals(2));
        expect(habits.map((h) => h.id).toSet(), equals({'habit-1', 'habit-2'}));
      });
    });

    group('getById', () {
      test('should return null for non-existent habit', () async {
        final habit = await repository.getById('non-existent');
        expect(habit, isNull);
      });

      test('should return correct habit for existing id', () async {
        final habit = Habit(
          id: 'habit-1',
          name: 'Meditation',
          icon: '🧘',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.save(habit);
        final retrieved = await repository.getById('habit-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('habit-1'));
      });
    });

    group('delete', () {
      test('should delete a habit', () async {
        final habit = Habit(
          id: 'habit-1',
          name: 'Meditation',
          icon: '🧘',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.save(habit);
        expect(await repository.getById('habit-1'), isNotNull);

        await repository.delete('habit-1');
        expect(await repository.getById('habit-1'), isNull);
      });
    });

    group('getHabitsForDate', () {
      test('should return non-archived habits only', () async {
        final activeHabit = Habit(
          id: 'habit-active',
          name: 'Active Habit',
          icon: '✅',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
          isArchived: false,
        );
        final archivedHabit = Habit(
          id: 'habit-archived',
          name: 'Archived Habit',
          icon: '📦',
          color: '#B85C38',
          sortOrder: 1,
          createdAt: DateTime(2024, 1, 15),
          isArchived: true,
        );

        await repository.save(activeHabit);
        await repository.save(archivedHabit);

        final habits = await repository.getHabitsForDate(DateTime(2024, 1, 15));
        expect(habits.length, equals(1));
        expect(habits.first.id, equals('habit-active'));
      });
    });

    group('getLogsForDate', () {
      test('should return logs for a specific date', () async {
        final date = DateTime(2024, 1, 15);
        final log1 = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          date: date,
          completedAt: DateTime(2024, 1, 15, 8, 30),
        );
        final log2 = HabitLog(
          id: 'log-2',
          habitId: 'habit-2',
          date: date,
          completedAt: DateTime(2024, 1, 15, 9, 0),
        );
        final log3 = HabitLog(
          id: 'log-3',
          habitId: 'habit-1',
          date: DateTime(2024, 1, 16),
          completedAt: DateTime(2024, 1, 16, 8, 30),
        );

        await repository.saveLog(log1);
        await repository.saveLog(log2);
        await repository.saveLog(log3);

        final logs = await repository.getLogsForDate(date);
        expect(logs.length, equals(2));
        expect(logs.map((l) => l.id).toSet(), equals({'log-1', 'log-2'}));
      });

      test('should return empty list when no logs for date', () async {
        final logs = await repository.getLogsForDate(DateTime(2024, 1, 15));
        expect(logs, isEmpty);
      });
    });

    group('saveLog', () {
      test('should save and retrieve a log', () async {
        final log = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          date: DateTime(2024, 1, 15),
          completedAt: DateTime(2024, 1, 15, 8, 30),
          note: 'Felt great!',
        );

        await repository.saveLog(log);
        final logs = await repository.getAllLogs();

        expect(logs.length, equals(1));
        expect(logs.first.id, equals('log-1'));
        expect(logs.first.habitId, equals('habit-1'));
        expect(logs.first.note, equals('Felt great!'));
      });

      test('should update existing log', () async {
        final log = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          date: DateTime(2024, 1, 15),
          completedAt: DateTime(2024, 1, 15, 8, 30),
        );

        await repository.saveLog(log);
        final updatedLog = log.copyWith(note: 'Updated note');
        await repository.saveLog(updatedLog);

        final logs = await repository.getAllLogs();
        expect(logs.length, equals(1));
        expect(logs.first.note, equals('Updated note'));
      });
    });

    group('getAllLogs', () {
      test('should return all logs', () async {
        final log1 = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          date: DateTime(2024, 1, 15),
          completedAt: DateTime(2024, 1, 15, 8, 30),
        );
        final log2 = HabitLog(
          id: 'log-2',
          habitId: 'habit-2',
          date: DateTime(2024, 1, 16),
          completedAt: DateTime(2024, 1, 16, 9, 0),
        );

        await repository.saveLog(log1);
        await repository.saveLog(log2);

        final logs = await repository.getAllLogs();
        expect(logs.length, equals(2));
      });
    });

    group('getLogsForHabit', () {
      test('should return logs for specific habit only', () async {
        final log1 = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          date: DateTime(2024, 1, 15),
          completedAt: DateTime(2024, 1, 15, 8, 30),
        );
        final log2 = HabitLog(
          id: 'log-2',
          habitId: 'habit-1',
          date: DateTime(2024, 1, 16),
          completedAt: DateTime(2024, 1, 16, 8, 30),
        );
        final log3 = HabitLog(
          id: 'log-3',
          habitId: 'habit-2',
          date: DateTime(2024, 1, 15),
          completedAt: DateTime(2024, 1, 15, 9, 0),
        );

        await repository.saveLog(log1);
        await repository.saveLog(log2);
        await repository.saveLog(log3);

        final logs = await repository.getLogsForHabit('habit-1');
        expect(logs.length, equals(2));
        expect(logs.every((l) => l.habitId == 'habit-1'), isTrue);
      });
    });

    group('deleteLog', () {
      test('should delete a log by id', () async {
        final log = HabitLog(
          id: 'log-1',
          habitId: 'habit-1',
          date: DateTime(2024, 1, 15),
          completedAt: DateTime(2024, 1, 15, 8, 30),
        );

        await repository.saveLog(log);
        expect(await repository.getAllLogs(), isNotEmpty);

        await repository.deleteLog('log-1');
        expect(await repository.getAllLogs(), isEmpty);
      });

      test('should throw HabitNotFoundFailure for non-existent log', () async {
        expect(
          () => repository.deleteLog('non-existent'),
          throwsA(isA<HabitNotFoundFailure>()),
        );
      });
    });

    group('reorder', () {
      test('should update sort order of habits', () async {
        final habit1 = Habit(
          id: 'habit-1',
          name: 'Habit 1',
          icon: '1️⃣',
          color: '#5A7A5C',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 15),
        );
        final habit2 = Habit(
          id: 'habit-2',
          name: 'Habit 2',
          icon: '2️⃣',
          color: '#B85C38',
          sortOrder: 1,
          createdAt: DateTime(2024, 1, 15),
        );
        final habit3 = Habit(
          id: 'habit-3',
          name: 'Habit 3',
          icon: '3️⃣',
          color: '#4A5568',
          sortOrder: 2,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.save(habit1);
        await repository.save(habit2);
        await repository.save(habit3);

        // Reorder: habit-3 first, then habit-1, then habit-2
        await repository.reorder(['habit-3', 'habit-1', 'habit-2']);

        final habits = await repository.getAll();
        final habitMap = {for (final h in habits) h.id: h};

        expect(habitMap['habit-3']!.sortOrder, equals(0));
        expect(habitMap['habit-1']!.sortOrder, equals(1));
        expect(habitMap['habit-2']!.sortOrder, equals(2));
      });
    });
  });
}
