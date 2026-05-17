import 'package:flutter_test/flutter_test.dart';
import 'package:forma/core/constants/app_colors.dart';

void main() {
  group('AppColors', () {
    test('should have no unintentional duplicate color values', () {
      // graphNone intentionally equals paper3 per design spec
      const intentionalDuplicates = <int>{0xFFE4DDD2}; // paper3 == graphNone
      
      final colors = AppColors.allColors;
      final uniqueValues = <int>{};
      final duplicates = <int, int>{};

      for (final color in colors) {
        final value = color.toARGB32();
        if (uniqueValues.contains(value) && !intentionalDuplicates.contains(value)) {
          duplicates[value] = (duplicates[value] ?? 1) + 1;
        } else {
          uniqueValues.add(value);
        }
      }

      expect(
        duplicates,
        isEmpty,
        reason: 'Found unintentional duplicate color values: ${
          duplicates.entries.map((e) => 
            '0x${e.key.toRadixString(16).toUpperCase()} (count: ${e.value})'
          ).join(', ')
        }',
      );
    });

    test('paper3 and graphNone should intentionally share the same color', () {
      // This is by design - graphNone represents "no activity" and blends with background
      expect(AppColors.paper3, equals(AppColors.graphNone));
    });

    test('should have exactly 22 colors defined', () {
      // 21 unique colors + 1 intentional duplicate (paper3 == graphNone)
      expect(AppColors.allColors, hasLength(22));
    });

    test('paper colors should be ordered from light to dark', () {
      // Paper colors should progress: paper > paper2 > paper3
      expect(AppColors.paper.toARGB32(), greaterThan(AppColors.paper2.toARGB32()));
      expect(AppColors.paper2.toARGB32(), greaterThan(AppColors.paper3.toARGB32()));
    });

    test('ink colors should be ordered from dark to light', () {
      // Ink colors should progress: ink > ink2 > ink3 > ink4
      expect(AppColors.ink.toARGB32(), lessThan(AppColors.ink2.toARGB32()));
      expect(AppColors.ink2.toARGB32(), lessThan(AppColors.ink3.toARGB32()));
      expect(AppColors.ink3.toARGB32(), lessThan(AppColors.ink4.toARGB32()));
    });

    test('activity graph colors should progress from light to dark', () {
      // Graph colors should progress: none > light > medium > dark > full
      expect(AppColors.graphNone.toARGB32(), greaterThan(AppColors.graphLight.toARGB32()));
      expect(AppColors.graphLight.toARGB32(), greaterThan(AppColors.graphMedium.toARGB32()));
      expect(AppColors.graphMedium.toARGB32(), greaterThan(AppColors.graphDark.toARGB32()));
      expect(AppColors.graphDark.toARGB32(), greaterThan(AppColors.graphFull.toARGB32()));
    });
  });
}