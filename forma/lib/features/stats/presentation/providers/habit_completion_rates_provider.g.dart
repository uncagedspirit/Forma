// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_completion_rates_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitCompletionRatesHash() =>
    r'f4240d22856a82bb6aa08deddd4298f1d7873e05';

/// Computes per-habit completion percentage over the last 30 days.
///
/// Returns a map of habitId -> percentage (0.0 to 1.0).
///
/// Copied from [habitCompletionRates].
@ProviderFor(habitCompletionRates)
final habitCompletionRatesProvider =
    AutoDisposeFutureProvider<Map<String, double>>.internal(
  habitCompletionRates,
  name: r'habitCompletionRatesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$habitCompletionRatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HabitCompletionRatesRef
    = AutoDisposeFutureProviderRef<Map<String, double>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
