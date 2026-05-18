// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_week_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$moodWeekHash() => r'8461b4a6c6827f98382ee01a9a83bc78d5b69812';

/// Returns the last 7 days of mood entries (including nulls for missing days).
///
/// The list is ordered chronologically from 6 days ago to today.
///
/// Copied from [moodWeek].
@ProviderFor(moodWeek)
final moodWeekProvider = AutoDisposeFutureProvider<List<MoodEntry?>>.internal(
  moodWeek,
  name: r'moodWeekProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$moodWeekHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MoodWeekRef = AutoDisposeFutureProviderRef<List<MoodEntry?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
