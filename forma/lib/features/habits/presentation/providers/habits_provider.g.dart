// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habits_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitsForDateHash() => r'b3eeb551d3f78ae5ca2e6047269f7d7327b5d132';

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

/// See also [habitsForDate].
@ProviderFor(habitsForDate)
const habitsForDateProvider = HabitsForDateFamily();

/// See also [habitsForDate].
class HabitsForDateFamily extends Family<AsyncValue<List<HabitWithStatus>>> {
  /// See also [habitsForDate].
  const HabitsForDateFamily();

  /// See also [habitsForDate].
  HabitsForDateProvider call(
    DateTime date,
  ) {
    return HabitsForDateProvider(
      date,
    );
  }

  @override
  HabitsForDateProvider getProviderOverride(
    covariant HabitsForDateProvider provider,
  ) {
    return call(
      provider.date,
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
  String? get name => r'habitsForDateProvider';
}

/// See also [habitsForDate].
class HabitsForDateProvider
    extends AutoDisposeFutureProvider<List<HabitWithStatus>> {
  /// See also [habitsForDate].
  HabitsForDateProvider(
    DateTime date,
  ) : this._internal(
          (ref) => habitsForDate(
            ref as HabitsForDateRef,
            date,
          ),
          from: habitsForDateProvider,
          name: r'habitsForDateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$habitsForDateHash,
          dependencies: HabitsForDateFamily._dependencies,
          allTransitiveDependencies:
              HabitsForDateFamily._allTransitiveDependencies,
          date: date,
        );

  HabitsForDateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    FutureOr<List<HabitWithStatus>> Function(HabitsForDateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HabitsForDateProvider._internal(
        (ref) => create(ref as HabitsForDateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<HabitWithStatus>> createElement() {
    return _HabitsForDateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitsForDateProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin HabitsForDateRef on AutoDisposeFutureProviderRef<List<HabitWithStatus>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _HabitsForDateProviderElement
    extends AutoDisposeFutureProviderElement<List<HabitWithStatus>>
    with HabitsForDateRef {
  _HabitsForDateProviderElement(super.provider);

  @override
  DateTime get date => (origin as HabitsForDateProvider).date;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
