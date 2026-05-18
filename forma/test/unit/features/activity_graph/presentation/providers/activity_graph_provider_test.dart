import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/activity_graph/domain/entities/activity_level.dart';
import 'package:forma/features/activity_graph/presentation/providers/activity_graph_provider.dart';
import 'package:forma/features/habits/data/repositories/habit_repository_provider.dart';
import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:forma/features/habits/domain/entities/habit_log.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late MockHabitRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockHabitRepository();
    container = ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('activityGraphProvider', () {
    final start = DateTime(2024, 1, 1);
    final end = DateTime(2024, 1, 1);

    List<Habit> generateHabits(int count) {
      return List.generate(
        count,
        (i) => Habit(
          id: 'habit-$i',
          name: 'Habit $i',
          icon: '✅',
          color: '#5A7A5C',
          sortOrder: i,
          createdAt: DateTime(2024, 1, 1),
          isArchived: false,
        ),
      );
    }

    List<HabitLog> generateLogs(int count, DateTime date) {
      return List.generate(
        count,
        (i) => HabitLog(
          id: 'log-$i',
          habitId: 'habit-$i',
          date: date,
          completedAt: DateTime(2024, 1, 1, 10, 0),
        ),
      );
    }

    test('maps 0% to none', () async {
      final habits = generateHabits(1);
      when(() => mockRepository.getAll()).thenAnswer((_) async => habits);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => []);

      final result =
          await container.read(activityGraphProvider(start, end).future);
      expect(result[DateTime.utc(2024, 1, 1)], ActivityLevel.none);
    });

    test('maps 1% to light', () async {
      final habits = generateHabits(100);
      final logs = generateLogs(1, DateTime.utc(2024, 1, 1));
      when(() => mockRepository.getAll()).thenAnswer((_) async => habits);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => logs);

      final result =
          await container.read(activityGraphProvider(start, end).future);
      expect(result[DateTime.utc(2024, 1, 1)], ActivityLevel.light);
    });

    test('maps 25% to light', () async {
      final habits = generateHabits(4);
      final logs = generateLogs(1, DateTime.utc(2024, 1, 1));
      when(() => mockRepository.getAll()).thenAnswer((_) async => habits);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => logs);

      final result =
          await container.read(activityGraphProvider(start, end).future);
      expect(result[DateTime.utc(2024, 1, 1)], ActivityLevel.light);
    });

    test('maps 26% to medium', () async {
      final habits = generateHabits(50);
      final logs = generateLogs(13, DateTime.utc(2024, 1, 1));
      when(() => mockRepository.getAll()).thenAnswer((_) async => habits);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => logs);

      final result =
          await container.read(activityGraphProvider(start, end).future);
      expect(result[DateTime.utc(2024, 1, 1)], ActivityLevel.medium);
    });

    test('maps 60% to medium', () async {
      final habits = generateHabits(5);
      final logs = generateLogs(3, DateTime.utc(2024, 1, 1));
      when(() => mockRepository.getAll()).thenAnswer((_) async => habits);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => logs);

      final result =
          await container.read(activityGraphProvider(start, end).future);
      expect(result[DateTime.utc(2024, 1, 1)], ActivityLevel.medium);
    });

    test('maps 61% to dark', () async {
      final habits = generateHabits(100);
      final logs = generateLogs(61, DateTime.utc(2024, 1, 1));
      when(() => mockRepository.getAll()).thenAnswer((_) async => habits);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => logs);

      final result =
          await container.read(activityGraphProvider(start, end).future);
      expect(result[DateTime.utc(2024, 1, 1)], ActivityLevel.dark);
    });

    test('maps 100% to full', () async {
      final habits = generateHabits(1);
      final logs = generateLogs(1, DateTime.utc(2024, 1, 1));
      when(() => mockRepository.getAll()).thenAnswer((_) async => habits);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => logs);

      final result =
          await container.read(activityGraphProvider(start, end).future);
      expect(result[DateTime.utc(2024, 1, 1)], ActivityLevel.full);
    });

    test('returns empty map when no active habits exist', () async {
      when(() => mockRepository.getAll()).thenAnswer((_) async => []);

      final result =
          await container.read(activityGraphProvider(start, end).future);
      expect(result, isEmpty);
    });

    test('maps multiple days in range independently', () async {
      final startRange = DateTime(2024, 1, 1);
      final endRange = DateTime(2024, 1, 3);
      final habits = generateHabits(4);

      final logs = [
        HabitLog(
          id: 'log-1',
          habitId: 'habit-0',
          date: DateTime.utc(2024, 1, 1),
          completedAt: DateTime(2024, 1, 1, 10, 0),
        ),
        HabitLog(
          id: 'log-2',
          habitId: 'habit-0',
          date: DateTime.utc(2024, 1, 2),
          completedAt: DateTime(2024, 1, 2, 10, 0),
        ),
        HabitLog(
          id: 'log-3',
          habitId: 'habit-1',
          date: DateTime.utc(2024, 1, 2),
          completedAt: DateTime(2024, 1, 2, 10, 0),
        ),
        HabitLog(
          id: 'log-4',
          habitId: 'habit-0',
          date: DateTime.utc(2024, 1, 3),
          completedAt: DateTime(2024, 1, 3, 10, 0),
        ),
        HabitLog(
          id: 'log-5',
          habitId: 'habit-1',
          date: DateTime.utc(2024, 1, 3),
          completedAt: DateTime(2024, 1, 3, 10, 0),
        ),
        HabitLog(
          id: 'log-6',
          habitId: 'habit-2',
          date: DateTime.utc(2024, 1, 3),
          completedAt: DateTime(2024, 1, 3, 10, 0),
        ),
        HabitLog(
          id: 'log-7',
          habitId: 'habit-3',
          date: DateTime.utc(2024, 1, 3),
          completedAt: DateTime(2024, 1, 3, 10, 0),
        ),
      ];

      when(() => mockRepository.getAll()).thenAnswer((_) async => habits);
      when(() => mockRepository.getAllLogs()).thenAnswer((_) async => logs);

      final result = await container.read(
        activityGraphProvider(startRange, endRange).future,
      );

      // Jan 1: 1/4 = 25% → light
      expect(result[DateTime.utc(2024, 1, 1)], ActivityLevel.light);
      // Jan 2: 2/4 = 50% → medium
      expect(result[DateTime.utc(2024, 1, 2)], ActivityLevel.medium);
      // Jan 3: 4/4 = 100% → full
      expect(result[DateTime.utc(2024, 1, 3)], ActivityLevel.full);
    });
  });
}
