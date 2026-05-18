import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/habits/domain/entities/habit.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:forma/features/habits/domain/usecases/add_habit.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

class FakeHabit extends Fake implements Habit {}

void main() {
  late AddHabit useCase;
  late MockHabitRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeHabit());
  });

  setUp(() {
    mockRepository = MockHabitRepository();
    useCase = AddHabit(mockRepository);
  });

  group('AddHabit', () {
    const testName = 'Drink Water';
    const testIcon = '💧';

    test('should save habit with valid name and icon', () async {
      // Arrange
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(name: testName, icon: testIcon);

      // Assert
      verify(() => mockRepository.save(any(that: isA<Habit>()))).called(1);
    });

    test('should save habit with custom color', () async {
      // Arrange
      const customColor = '#FF0000';
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(
        name: testName,
        icon: testIcon,
        color: customColor,
      );

      // Assert
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as Habit;
      expect(captured.color, equals(customColor));
    });

    test('should use default sage color when color is not provided', () async {
      // Arrange
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(name: testName, icon: testIcon);

      // Assert
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as Habit;
      expect(captured.color, equals('#5A7A5C'));
    });

    test('should trim whitespace from name', () async {
      // Arrange
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(name: '  Drink Water  ', icon: testIcon);

      // Assert
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as Habit;
      expect(captured.name, equals('Drink Water'));
    });

    test('should trim whitespace from icon', () async {
      // Arrange
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(name: testName, icon: '  💧  ');

      // Assert
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as Habit;
      expect(captured.icon, equals('💧'));
    });

    test('should generate unique UUID for habit', () async {
      // Arrange
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(name: testName, icon: testIcon);

      // Assert
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as Habit;
      expect(captured.id, isNotEmpty);
      expect(captured.id.length, equals(36)); // UUID v4 length
    });

    test('should set isArchived to false', () async {
      // Arrange
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(name: testName, icon: testIcon);

      // Assert
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as Habit;
      expect(captured.isArchived, isFalse);
    });

    test('should set createdAt to current time', () async {
      // Arrange
      final before = DateTime.now();
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(name: testName, icon: testIcon);
      final after = DateTime.now();

      // Assert
      final captured =
          verify(() => mockRepository.save(captureAny())).captured.single
              as Habit;
      expect(
        captured.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        captured.createdAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('should throw ArgumentError when name is empty', () async {
      // Act & Assert
      expect(
        () => useCase.call(name: '', icon: testIcon),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => mockRepository.save(any()));
    });

    test('should throw ArgumentError when name contains only whitespace',
        () async {
      // Act & Assert
      expect(
        () => useCase.call(name: '   ', icon: testIcon),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => mockRepository.save(any()));
    });

    test('should throw ArgumentError when icon is empty', () async {
      // Act & Assert
      expect(
        () => useCase.call(name: testName, icon: ''),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => mockRepository.save(any()));
    });

    test('should throw ArgumentError when icon contains only whitespace',
        () async {
      // Act & Assert
      expect(
        () => useCase.call(name: testName, icon: '   '),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => mockRepository.save(any()));
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.save(any())).thenThrow(Exception('DB error'));

      // Act & Assert
      expect(
        () => useCase.call(name: testName, icon: testIcon),
        throwsA(isA<Exception>()),
      );
    });
  });
}
