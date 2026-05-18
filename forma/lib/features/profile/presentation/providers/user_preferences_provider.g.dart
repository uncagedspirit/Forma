// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userPreferencesHash() => r'4b926c9d368668dbebd770b295b8470c082bb89d';

/// Provides the current user's preferences from Hive.
///
/// Returns `null` if no preferences have been saved yet.
/// Hive is synchronous after initialization, so this provider
/// returns a plain [UserPreferencesModel?] without async/await.
///
/// Copied from [userPreferences].
@ProviderFor(userPreferences)
final userPreferencesProvider =
    AutoDisposeProvider<UserPreferencesModel?>.internal(
  userPreferences,
  name: r'userPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserPreferencesRef = AutoDisposeProviderRef<UserPreferencesModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
