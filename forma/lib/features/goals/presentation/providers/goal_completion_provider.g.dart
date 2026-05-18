// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_completion_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$goalCompletionRatioHash() =>
    r'453ef840804eee142e7a133f0cdd805db4d7013e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [goalCompletionRatio].
@ProviderFor(goalCompletionRatio)
const goalCompletionRatioProvider = GoalCompletionRatioFamily();

/// See also [goalCompletionRatio].
class GoalCompletionRatioFamily extends Family<AsyncValue<double>> {
  /// See also [goalCompletionRatio].
  const GoalCompletionRatioFamily();

  /// See also [goalCompletionRatio].
  GoalCompletionRatioProvider call(
    String goalId,
  ) {
    return GoalCompletionRatioProvider(
      goalId,
    );
  }

  @override
  GoalCompletionRatioProvider getProviderOverride(
    covariant GoalCompletionRatioProvider provider,
  ) {
    return call(
      provider.goalId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'goalCompletionRatioProvider';
}

/// See also [goalCompletionRatio].
class GoalCompletionRatioProvider extends AutoDisposeFutureProvider<double> {
  /// See also [goalCompletionRatio].
  GoalCompletionRatioProvider(
    String goalId,
  ) : this._internal(
          (ref) => goalCompletionRatio(
            ref as GoalCompletionRatioRef,
            goalId,
          ),
          from: goalCompletionRatioProvider,
          name: r'goalCompletionRatioProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$goalCompletionRatioHash,
          dependencies: GoalCompletionRatioFamily._dependencies,
          allTransitiveDependencies:
              GoalCompletionRatioFamily._allTransitiveDependencies,
          goalId: goalId,
        );

  GoalCompletionRatioProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.goalId,
  }) : super.internal();

  final String goalId;

  @override
  Override overrideWith(
    FutureOr<double> Function(GoalCompletionRatioRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GoalCompletionRatioProvider._internal(
        (ref) => create(ref as GoalCompletionRatioRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        goalId: goalId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<double> createElement() {
    return _GoalCompletionRatioProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalCompletionRatioProvider && other.goalId == goalId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, goalId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GoalCompletionRatioRef on AutoDisposeFutureProviderRef<double> {
  /// The parameter `goalId` of this provider.
  String get goalId;
}

class _GoalCompletionRatioProviderElement
    extends AutoDisposeFutureProviderElement<double>
    with GoalCompletionRatioRef {
  _GoalCompletionRatioProviderElement(super.provider);

  @override
  String get goalId => (origin as GoalCompletionRatioProvider).goalId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
