import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/mood/data/models/mood_model.dart';
import 'package:forma/features/mood/data/repositories/mood_repository_impl.dart';
import 'package:forma/features/mood/domain/entities/mood_entry.dart';
import 'package:forma/features/mood/domain/failures/mood_failures.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('MoodRepositoryImpl', () {
    late Directory tempDir;
    late Box<MoodModel> box;
    late MoodRepositoryImpl repository;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_test_');
      Hive.init(tempDir.path);

      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(MoodModelAdapter());
      }
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    setUp(() async {
      box = await Hive.openBox<MoodModel>('test_moods_${DateTime.now().millisecondsSinceEpoch}');
      repository = MoodRepositoryImpl(box);
    });

    tearDown(() async {
      await box.close();
    });

    group('save and roundtrip', () {
      test('should save a mood entry and retrieve it', () async {
        final entry = MoodEntry(
          date: DateTime(2024, 3, 15),
          value: 4,
          note: 'Had a productive day at work!',
        );

        await repository.save(entry);
        final retrieved = await repository.getByDate(DateTime(2024, 3, 15));

        expect(retrieved, isNotNull);
        expect(retrieved!.date, equals(entry.date));
        expect(retrieved.value, equals(entry.value));
        expect(retrieved.note, equals(entry.note));
      });

      test('should save a mood entry without note', () async {
        final entry = MoodEntry(
          date: DateTime(2024, 3, 15),
          value: 3,
        );

        await repository.save(entry);
        final retrieved = await repository.getByDate(DateTime(2024, 3, 15));

        expect(retrieved, isNotNull);
        expect(retrieved!.value, equals(3));
        expect(retrieved.note, isNull);
      });

      test('should normalize date to midnight UTC when saving', () async {
        final entryWithTime = MoodEntry(
          date: DateTime(2024, 3, 15, 14, 30, 45),
          value: 5,
          note: 'Great day!',
        );

        await repository.save(entryWithTime);

        // Should be retrievable with just the date (no time)
        final retrieved = await repository.getByDate(DateTime(2024, 3, 15));
        expect(retrieved, isNotNull);
        expect(retrieved!.value, equals(5));
      });
    });

    group('upsert behavior', () {
      test('should overwrite existing entry with same date', () async {
        final date = DateTime(2024, 3, 15);
        final entry1 = MoodEntry(
          date: date,
          value: 3,
          note: 'First entry',
        );

        await repository.save(entry1);

        final entry2 = MoodEntry(
          date: date,
          value: 5,
          note: 'Updated entry',
        );

        await repository.save(entry2);

        final allEntries = await repository.getAll();
        expect(allEntries.length, equals(1));

        final retrieved = await repository.getByDate(date);
        expect(retrieved!.value, equals(5));
        expect(retrieved.note, equals('Updated entry'));
      });

      test('should treat same calendar date as same key regardless of time', () async {
        final morning = DateTime(2024, 3, 15, 8, 0, 0);
        final afternoon = DateTime(2024, 3, 15, 14, 30, 0);
        final evening = DateTime(2024, 3, 15, 20, 0, 0);

        await repository.save(MoodEntry(
          date: morning,
          value: 3,
          note: 'Morning mood',
        ));

        await repository.save(MoodEntry(
          date: afternoon,
          value: 4,
          note: 'Afternoon mood',
        ));

        await repository.save(MoodEntry(
          date: evening,
          value: 5,
          note: 'Evening mood',
        ));

        final allEntries = await repository.getAll();
        expect(allEntries.length, equals(1));
        expect(allEntries.first.value, equals(5));
        expect(allEntries.first.note, equals('Evening mood'));
      });
    });

    group('getAll', () {
      test('should return empty list when no entries exist', () async {
        final entries = await repository.getAll();
        expect(entries, isEmpty);
      });

      test('should return all saved mood entries', () async {
        final entry1 = MoodEntry(
          date: DateTime(2024, 3, 15),
          value: 4,
          note: 'Good day',
        );
        final entry2 = MoodEntry(
          date: DateTime(2024, 3, 16),
          value: 5,
          note: 'Great day',
        );
        final entry3 = MoodEntry(
          date: DateTime(2024, 3, 17),
          value: 3,
        );

        await repository.save(entry1);
        await repository.save(entry2);
        await repository.save(entry3);

        final entries = await repository.getAll();
        expect(entries.length, equals(3));
      });
    });

    group('getByDate', () {
      test('should return null for non-existent date', () async {
        final entry = await repository.getByDate(DateTime(2024, 3, 15));
        expect(entry, isNull);
      });

      test('should return correct entry for existing date', () async {
        final entry = MoodEntry(
          date: DateTime(2024, 3, 15),
          value: 4,
          note: 'Good day',
        );

        await repository.save(entry);
        final retrieved = await repository.getByDate(DateTime(2024, 3, 15));

        expect(retrieved, isNotNull);
        expect(retrieved!.date, equals(entry.date));
        expect(retrieved.value, equals(entry.value));
      });

      test('should normalize input date for lookup', () async {
        await repository.save(MoodEntry(
          date: DateTime(2024, 3, 15),
          value: 4,
        ));

        // Should find entry even with different time components
        final retrieved = await repository.getByDate(DateTime(2024, 3, 15, 14, 30, 45));
        expect(retrieved, isNotNull);
        expect(retrieved!.value, equals(4));
      });
    });

    group('getByDateRange', () {
      test('should return entries within date range (inclusive)', () async {
        final entry1 = MoodEntry(
          date: DateTime(2024, 3, 14),
          value: 3,
        );
        final entry2 = MoodEntry(
          date: DateTime(2024, 3, 15),
          value: 4,
        );
        final entry3 = MoodEntry(
          date: DateTime(2024, 3, 16),
          value: 5,
        );
        final entry4 = MoodEntry(
          date: DateTime(2024, 3, 17),
          value: 3,
        );

        await repository.save(entry1);
        await repository.save(entry2);
        await repository.save(entry3);
        await repository.save(entry4);

        final entries = await repository.getByDateRange(
          DateTime(2024, 3, 15),
          DateTime(2024, 3, 16),
        );

        expect(entries.length, equals(2));
        expect(entries.map((e) => e.value).toSet(), equals({4, 5}));
      });

      test('should return empty list when no entries in range', () async {
        final entry = MoodEntry(
          date: DateTime(2024, 3, 15),
          value: 4,
        );

        await repository.save(entry);

        final entries = await repository.getByDateRange(
          DateTime(2024, 3, 20),
          DateTime(2024, 3, 25),
        );

        expect(entries, isEmpty);
      });

      test('should include entries at exact start and end dates', () async {
        final entry = MoodEntry(
          date: DateTime(2024, 3, 15),
          value: 4,
        );

        await repository.save(entry);

        final entries = await repository.getByDateRange(
          DateTime(2024, 3, 15),
          DateTime(2024, 3, 15),
        );

        expect(entries.length, equals(1));
        expect(entries.first.value, equals(4));
      });
    });

    group('delete', () {
      test('should delete a mood entry', () async {
        final entry = MoodEntry(
          date: DateTime(2024, 3, 15),
          value: 4,
        );

        await repository.save(entry);
        expect(await repository.getByDate(DateTime(2024, 3, 15)), isNotNull);

        await repository.delete(DateTime(2024, 3, 15));
        expect(await repository.getByDate(DateTime(2024, 3, 15)), isNull);
      });

      test('should normalize date for deletion', () async {
        await repository.save(MoodEntry(
          date: DateTime(2024, 3, 15),
          value: 4,
        ));

        // Delete using date with time component
        await repository.delete(DateTime(2024, 3, 15, 14, 30, 45));
        expect(await repository.getByDate(DateTime(2024, 3, 15)), isNull);
      });

      test('should not throw when deleting non-existent entry', () async {
        expect(
          () => repository.delete(DateTime(2024, 3, 15)),
          returnsNormally,
        );
      });
    });

    group('edge cases', () {
      test('should handle mood values at boundaries', () async {
        final minEntry = MoodEntry(
          date: DateTime(2024, 3, 15),
          value: 1,
        );
        final maxEntry = MoodEntry(
          date: DateTime(2024, 3, 16),
          value: 5,
        );

        await repository.save(minEntry);
        await repository.save(maxEntry);

        final retrievedMin = await repository.getByDate(DateTime(2024, 3, 15));
        final retrievedMax = await repository.getByDate(DateTime(2024, 3, 16));

        expect(retrievedMin!.value, equals(1));
        expect(retrievedMax!.value, equals(5));
      });

      test('should handle entries across different months and years', () async {
        final entry1 = MoodEntry(
          date: DateTime(2023, 12, 31),
          value: 4,
        );
        final entry2 = MoodEntry(
          date: DateTime(2024, 1, 1),
          value: 5,
        );

        await repository.save(entry1);
        await repository.save(entry2);

        final entries = await repository.getAll();
        expect(entries.length, equals(2));
      });
    });

    group('error handling', () {
      test('should throw MoodStorageFailure when box is closed', () async {
        await box.close();

        expect(
          () => repository.getAll(),
          throwsA(isA<MoodStorageFailure>()),
        );
      });

      test('should throw MoodStorageFailure when saving to closed box', () async {
        final entry = MoodEntry(
          date: DateTime(2024, 3, 15),
          value: 4,
        );

        await box.close();

        expect(
          () => repository.save(entry),
          throwsA(isA<MoodStorageFailure>()),
        );
      });

      test('should throw MoodStorageFailure when getting by date from closed box', () async {
        await box.close();

        expect(
          () => repository.getByDate(DateTime(2024, 3, 15)),
          throwsA(isA<MoodStorageFailure>()),
        );
      });

      test('should throw MoodStorageFailure when getting by date range from closed box', () async {
        await box.close();

        expect(
          () => repository.getByDateRange(
            DateTime(2024, 3, 15),
            DateTime(2024, 3, 20),
          ),
          throwsA(isA<MoodStorageFailure>()),
        );
      });

      test('should throw MoodStorageFailure when deleting from closed box', () async {
        await box.close();

        expect(
          () => repository.delete(DateTime(2024, 3, 15)),
          throwsA(isA<MoodStorageFailure>()),
        );
      });
    });
  });
}
