import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/habits/data/models/habit_log_model.dart';
import 'package:forma/features/habits/domain/entities/habit_log.dart';

void main() {
  group('HabitLogModel', () {
    final testDate = DateTime(2024, 1, 15);
    final testCompletedAt = DateTime(2024, 1, 15, 8, 30, 45);
    
    final testLog = HabitLog(
      id: 'log-id-123',
      habitId: 'habit-id-456',
      date: testDate,
      completedAt: testCompletedAt,
      photoPath: '/photos/habit_123.jpg',
      note: 'Felt great today!',
    );

    final testModel = HabitLogModel(
      id: 'log-id-123',
      habitId: 'habit-id-456',
      date: testDate,
      completedAt: testCompletedAt,
      photoPath: '/photos/habit_123.jpg',
      note: 'Felt great today!',
    );

    group('toEntity', () {
      test('should convert HabitLogModel to HabitLog entity', () {
        final entity = testModel.toEntity();

        expect(entity.id, equals(testModel.id));
        expect(entity.habitId, equals(testModel.habitId));
        expect(entity.date, equals(testModel.date));
        expect(entity.completedAt, equals(testModel.completedAt));
        expect(entity.photoPath, equals(testModel.photoPath));
        expect(entity.note, equals(testModel.note));
      });
    });

    group('fromEntity', () {
      test('should create HabitLogModel from HabitLog entity', () {
        final model = HabitLogModel.fromEntity(testLog);

        expect(model.id, equals(testLog.id));
        expect(model.habitId, equals(testLog.habitId));
        expect(model.date, equals(testLog.date));
        expect(model.completedAt, equals(testLog.completedAt));
        expect(model.photoPath, equals(testLog.photoPath));
        expect(model.note, equals(testLog.note));
      });
    });

    group('roundtrip', () {
      test('should preserve all fields through model → entity → model conversion', () {
        final entity = testModel.toEntity();
        final roundtripModel = HabitLogModel.fromEntity(entity);

        expect(roundtripModel.id, equals(testModel.id));
        expect(roundtripModel.habitId, equals(testModel.habitId));
        expect(roundtripModel.date, equals(testModel.date));
        expect(roundtripModel.completedAt, equals(testModel.completedAt));
        expect(roundtripModel.photoPath, equals(testModel.photoPath));
        expect(roundtripModel.note, equals(testModel.note));
      });

      test('should preserve all fields through entity → model → entity conversion', () {
        final model = HabitLogModel.fromEntity(testLog);
        final roundtripEntity = model.toEntity();

        expect(roundtripEntity, equals(testLog));
      });
    });

    group('date serialization edge cases', () {
      test('should handle midnight UTC date', () {
        final midnightUtc = DateTime.utc(2024, 1, 15);
        final model = HabitLogModel(
          id: 'test',
          habitId: 'habit',
          date: midnightUtc,
          completedAt: midnightUtc,
        );

        final entity = model.toEntity();
        final roundtrip = HabitLogModel.fromEntity(entity);

        expect(roundtrip.date, equals(midnightUtc));
        expect(roundtrip.completedAt, equals(midnightUtc));
      });

      test('should handle local timezone dates', () {
        final localDate = DateTime(2024, 6, 21, 23, 59, 59);
        final model = HabitLogModel(
          id: 'test',
          habitId: 'habit',
          date: localDate,
          completedAt: localDate,
        );

        final entity = model.toEntity();
        final roundtrip = HabitLogModel.fromEntity(entity);

        expect(roundtrip.date, equals(localDate));
        expect(roundtrip.completedAt, equals(localDate));
      });

      test('should handle dates at year boundaries', () {
        final yearEnd = DateTime(2023, 12, 31, 23, 59, 59);
        final yearStart = DateTime(2024, 1, 1, 0, 0, 0);
        
        final model1 = HabitLogModel(
          id: 'test1',
          habitId: 'habit',
          date: yearEnd,
          completedAt: yearEnd,
        );
        final model2 = HabitLogModel(
          id: 'test2',
          habitId: 'habit',
          date: yearStart,
          completedAt: yearStart,
        );

        expect(HabitLogModel.fromEntity(model1.toEntity()).date, equals(yearEnd));
        expect(HabitLogModel.fromEntity(model2.toEntity()).date, equals(yearStart));
      });
    });

    group('null fields', () {
      test('should handle null photoPath and note', () {
        final modelWithNulls = HabitLogModel(
          id: 'test',
          habitId: 'habit',
          date: DateTime.now(),
          completedAt: DateTime.now(),
          photoPath: null,
          note: null,
        );

        final entity = modelWithNulls.toEntity();
        expect(entity.photoPath, isNull);
        expect(entity.note, isNull);

        final roundtrip = HabitLogModel.fromEntity(entity);
        expect(roundtrip.photoPath, isNull);
        expect(roundtrip.note, isNull);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        final copied = testModel.copyWith(
          note: 'Updated note',
          photoPath: '/new/path.jpg',
        );

        expect(copied.id, equals(testModel.id));
        expect(copied.note, equals('Updated note'));
        expect(copied.photoPath, equals('/new/path.jpg'));
        expect(copied.habitId, equals(testModel.habitId));
      });

      test('should keep original values when null is passed', () {
        final copied = testModel.copyWith();

        expect(copied.id, equals(testModel.id));
        expect(copied.note, equals(testModel.note));
        expect(copied.photoPath, equals(testModel.photoPath));
      });
    });
  });
}