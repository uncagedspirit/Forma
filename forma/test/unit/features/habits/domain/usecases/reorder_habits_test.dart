import 'package:flutter_test/flutter_test.dart';
import 'package:forma/features/habits/domain/repositories/habit_repository.dart';
import 'package:forma/features/habits/domain/usecases/reorder_habits.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late ReorderHabits useCase;
  late MockHabitRepository mockRepository;

  setUp(() {
    mockRepository = MockHabitRepository();
    useCase = ReorderHabits(mockRepository);
  });

  group('ReorderHabits', () {
    test('should call repository.reorder with ordered IDs', () async {
      // Arrange
      const orderedIds = ['habit-1', 'habit-2', 'habit-3'];
      when(() => mockRepository.reorder(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(orderedIds);

      // Assert
      verify(() => mockRepository.reorder(orderedIds)).called(1);
    });

    test('should pass empty list to repository', () async {
      // Arrange
      when(() => mockRepository.reorder(any())).thenAnswer((_) async {});

      // Act & Assert
      expect(
        () => useCase.call([]),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => mockRepository.reorder(any()));
    });

    test('should throw ArgumentError when orderedIds is empty', () async {
      // Act & Assert
      expect(
        () => useCase.call([]),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('empty'),
          ),
        ),
      );
    });

    test('should handle single habit ID', () async {
      // Arrange
      const orderedIds = ['habit-1'];
      when(() => mockRepository.reorder(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(orderedIds);

      // Assert
      verify(() => mockRepository.reorder(orderedIds)).called(1);
    });

    test('should handle large list of IDs', () async {
      // Arrange
      final orderedIds = List.generate(100, (i) => 'habit-$i');
      when(() => mockRepository.reorder(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(orderedIds);

      // Assert
      verify(() => mockRepository.reorder(orderedIds)).called(1);
    });

    test('should propagate repository errors', () async {
      // Arrange
      const orderedIds = ['habit-1', 'habit-2'];
      when(() => mockRepository.reorder(any()))
          .thenThrow(Exception('DB error'));

      // Act & Assert
      expect(
        () => useCase.call(orderedIds),
        throwsA(isA<Exception>()),
      );
    });

    test('should maintain ID order in call', () async {
      // Arrange
      const orderedIds = ['z-last', 'm-middle', 'a-first'];
      when(() => mockRepository.reorder(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(orderedIds);

      // Assert
      final captured =
          verify(() => mockRepository.reorder(captureAny())).captured.single
              as List<String>;
      expect(captured[0], equals('z-last'));
      expect(captured[1], equals('m-middle'));
      expect(captured[2], equals('a-first'));
    });
  });
}
