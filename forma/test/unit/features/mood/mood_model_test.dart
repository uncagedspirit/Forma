import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/mood/data/models/mood_model.dart';
import 'package:forma/features/mood/domain/entities/mood_entry.dart';

void main() {
  group('MoodModel', () {
    final testDate = DateTime(2024, 3, 15);
    
    final testMood = MoodEntry(
      date: testDate,
      value: 4,
      note: 'Had a productive day at work!',
    );

    final testModel = MoodModel(
      date: testDate,
      value: 4,
      note: 'Had a productive day at work!',
    );

    group('toEntity', () {
      test('should convert MoodModel to MoodEntry entity', () {
        final entity = testModel.toEntity();

        expect(entity.date, equals(testModel.date));
        expect(entity.value, equals(testModel.value));
        expect(entity.note, equals(testModel.note));
      });
    });

    group('fromEntity', () {
      test('should create MoodModel from MoodEntry entity', () {
        final model = MoodModel.fromEntity(testMood);

        expect(model.date, equals(testMood.date));
        expect(model.value, equals(testMood.value));
        expect(model.note, equals(testMood.note));
      });
    });

    group('roundtrip', () {
      test('should preserve all fields through model → entity → model conversion', () {
        final entity = testModel.toEntity();
        final roundtripModel = MoodModel.fromEntity(entity);

        expect(roundtripModel.date, equals(testModel.date));
        expect(roundtripModel.value, equals(testModel.value));
        expect(roundtripModel.note, equals(testModel.note));
      });

      test('should preserve all fields through entity → model → entity conversion', () {
        final model = MoodModel.fromEntity(testMood);
        final roundtripEntity = model.toEntity();

        expect(roundtripEntity, equals(testMood));
      });
    });

    group('value range', () {
      test('should handle minimum mood value (1)', () {
        final model = MoodModel(
          date: DateTime.now(),
          value: 1,
        );
        expect(model.toEntity().value, equals(1));
      });

      test('should handle maximum mood value (5)', () {
        final model = MoodModel(
          date: DateTime.now(),
          value: 5,
        );
        expect(model.toEntity().value, equals(5));
      });

      test('should handle middle mood values', () {
        for (var i = 1; i <= 5; i++) {
          final model = MoodModel(
            date: DateTime.now(),
            value: i,
          );
          expect(model.toEntity().value, equals(i));
        }
      });
    });

    group('date handling', () {
      test('should handle date at midnight', () {
        final midnight = DateTime(2024, 1, 15);
        final model = MoodModel(
          date: midnight,
          value: 3,
        );

        final entity = model.toEntity();
        final roundtrip = MoodModel.fromEntity(entity);

        expect(roundtrip.date, equals(midnight));
      });

      test('should handle date with time component', () {
        final withTime = DateTime(2024, 1, 15, 14, 30, 45);
        final model = MoodModel(
          date: withTime,
          value: 4,
        );

        final entity = model.toEntity();
        final roundtrip = MoodModel.fromEntity(entity);

        expect(roundtrip.date, equals(withTime));
      });
    });

    group('null fields', () {
      test('should handle null note', () {
        final modelWithNullNote = MoodModel(
          date: DateTime.now(),
          value: 3,
          note: null,
        );

        final entity = modelWithNullNote.toEntity();
        expect(entity.note, isNull);

        final roundtrip = MoodModel.fromEntity(entity);
        expect(roundtrip.note, isNull);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        final copied = testModel.copyWith(
          value: 5,
          note: 'Even better than before!',
        );

        expect(copied.date, equals(testModel.date));
        expect(copied.value, equals(5));
        expect(copied.note, equals('Even better than before!'));
      });

      test('should keep original values when null is passed', () {
        final copied = testModel.copyWith();

        expect(copied.date, equals(testModel.date));
        expect(copied.value, equals(testModel.value));
        expect(copied.note, equals(testModel.note));
      });
    });
  });
}