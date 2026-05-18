// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_completion_rates_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitCompletionRatesHash() =>
    r'a616ecb10b01003e43633f7325bbdb62c34ae825';

/// Computes per-habit completion percentage over the last 30 days.
///
/// Returns a list of [HabitCompletionRate] sorted by rate descending,
/// then by habit name alphabetically.
///
/// Copied from [habitCompletionRates].
@ProviderFor(habitCompletionRates)
final habitCompletionRatesProvider =
    AutoDisposeFutureProvider<List<HabitCompletionRate>>.internal(
  habitCompletionRates,
  name: r'habitCompletionRatesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$habitCompletionRatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HabitCompletionRatesRef
    = AutoDisposeFutureProviderRef<List<HabitCompletionRate>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
