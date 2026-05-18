// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$premiumStatusHash() => r'01fc7041ba6fceba8afa94ec731acf1e9fb5d884';

/// Reads the user's premium status from Hive.
///
/// Returns `true` if the user has an active premium subscription,
/// `false` otherwise. Hive is synchronous after initialization,
/// so this provider returns a plain [bool] without async/await.
///
/// Copied from [premiumStatus].
@ProviderFor(premiumStatus)
final premiumStatusProvider = AutoDisposeProvider<bool>.internal(
  premiumStatus,
  name: r'premiumStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$premiumStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PremiumStatusRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
