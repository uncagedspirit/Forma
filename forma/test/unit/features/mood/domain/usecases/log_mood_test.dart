import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/mood/domain/entities/mood_entry.dart';
import 'package:forma/features/mood/domain/repositories/mood_repository.dart';
import 'package:forma/features/mood/domain/usecases/log_mood.dart';
import 'package:mocktail/mocktail.dart';

class MockMoodRepository extends Mock implements MoodRepository {}

class FakeMoodEntry extends Fake implements MoodEntry {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMoodEntry());
  });
  late LogMood useCase;
  late MockMoodRepository mockRepository;

  setUp(() {
    mockRepository = MockMoodRepository();
    useCase = LogMood(mockRepository);
  });

  group('LogMood', () {
    final testDate = DateTime(2024, 1, 15);
    final normalizedDate = DateTime.utc(2024, 1, 15);

    test('should save mood entry with valid value', () async {
      // Arrange
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(date: testDate, value: 3);

      // Assert
      verify(() => mockRepository.save(any(that: isA<MoodEntry>()))).called(1);
    });

    test('should save mood with all valid values (1-5)', () async {
      // Arrange
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act & Assert
      for (final value in [1, 2, 3, 4, 5]) {
        await useCase.call(date: testDate, value: value);
      }

      verify(() => mockRepository.save(any())).called(5);
    });

    test('should save mood with note', () async {
      // Arrange
      const testNote = 'Feeling great today!';
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(date: testDate, value: 4, note: testNote);

      // Assert
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as MoodEntry;
      expect(captured.note, equals(testNote));
    });

    test('should trim whitespace from note', () async {
      // Arrange
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(
        date: testDate,
        value: 3,
        note: '  Feeling good  ',
      );

      // Assert
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as MoodEntry;
      expect(captured.note, equals('Feeling good'));
    });

    test('should handle null note', () async {
      // Arrange
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(date: testDate, value: 3, note: null);

      // Assert
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as MoodEntry;
      expect(captured.note, isNull);
    });

    test('should normalize date to midnight UTC', () async {
      // Arrange
      final dateWithTime = DateTime(2024, 1, 15, 14, 30, 45);
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(date: dateWithTime, value: 3);

      // Assert
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as MoodEntry;
      expect(captured.date, equals(normalizedDate));
      expect(captured.date.hour, equals(0));
      expect(captured.date.minute, equals(0));
      expect(captured.date.isUtc, isTrue);
    });

    test('should throw ArgumentError when value is less than 1', () async {
      // Act & Assert
      expect(
        () => useCase.call(date: testDate, value: 0),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => mockRepository.save(any()));
    });

    test('should throw ArgumentError when value is greater than 5', () async {
      // Act & Assert
      expect(
        () => useCase.call(date: testDate, value: 6),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => mockRepository.save(any()));
    });

    test('should throw ArgumentError when value is negative', () async {
      // Act & Assert
      expect(
        () => useCase.call(date: testDate, value: -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should set correct value in MoodEntry', () async {
      // Arrange
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(date: testDate, value: 5);

      // Assert
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as MoodEntry;
      expect(captured.value, equals(5));
    });

    test('should upsert (repository handles overwrite)', () async {
      // Arrange - repository.save is called for both insert and update
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act - Call twice for same date
      await useCase.call(date: testDate, value: 3);
      await useCase.call(date: testDate, value: 4);

      // Assert - Both calls should succeed (upsert behavior)
      verify(() => mockRepository.save(any())).called(2);
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.save(any()))
          .thenThrow(Exception('DB error'));

      // Act & Assert
      expect(
        () => useCase.call(date: testDate, value: 3),
        throwsA(isA<Exception>()),
      );
    });
  });
}
