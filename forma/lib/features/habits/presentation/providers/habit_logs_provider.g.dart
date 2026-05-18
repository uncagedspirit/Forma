// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_logs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitLogsHash() => r'ba3b62730fb43decc506dd1f2e46b3091cb44261';

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

/// Fetches all completion logs for a specific habit.
///
/// Copied from [habitLogs].
@ProviderFor(habitLogs)
const habitLogsProvider = HabitLogsFamily();

/// Fetches all completion logs for a specific habit.
///
/// Copied from [habitLogs].
class HabitLogsFamily extends Family<AsyncValue<List<HabitLog>>> {
  /// Fetches all completion logs for a specific habit.
  ///
  /// Copied from [habitLogs].
  const HabitLogsFamily();

  /// Fetches all completion logs for a specific habit.
  ///
  /// Copied from [habitLogs].
  HabitLogsProvider call(
    String habitId,
  ) {
    return HabitLogsProvider(
      habitId,
    );
  }

  @override
  HabitLogsProvider getProviderOverride(
    covariant HabitLogsProvider provider,
  ) {
    return call(
      provider.habitId,
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
  String? get name => r'habitLogsProvider';
}

/// Fetches all completion logs for a specific habit.
///
/// Copied from [habitLogs].
class HabitLogsProvider extends AutoDisposeFutureProvider<List<HabitLog>> {
  /// Fetches all completion logs for a specific habit.
  ///
  /// Copied from [habitLogs].
  HabitLogsProvider(
    String habitId,
  ) : this._internal(
          (ref) => habitLogs(
            ref as HabitLogsRef,
            habitId,
          ),
          from: habitLogsProvider,
          name: r'habitLogsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$habitLogsHash,
          dependencies: HabitLogsFamily._dependencies,
          allTransitiveDependencies: HabitLogsFamily._allTransitiveDependencies,
          habitId: habitId,
        );

  HabitLogsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.habitId,
  }) : super.internal();

  final String habitId;

  @override
  Override overrideWith(
    FutureOr<List<HabitLog>> Function(HabitLogsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HabitLogsProvider._internal(
        (ref) => create(ref as HabitLogsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        habitId: habitId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<HabitLog>> createElement() {
    return _HabitLogsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitLogsProvider && other.habitId == habitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, habitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin HabitLogsRef on AutoDisposeFutureProviderRef<List<HabitLog>> {
  /// The parameter `habitId` of this provider.
  String get habitId;
}

class _HabitLogsProviderElement
    extends AutoDisposeFutureProviderElement<List<HabitLog>> with HabitLogsRef {
  _HabitLogsProviderElement(super.provider);

  @override
  String get habitId => (origin as HabitLogsProvider).habitId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
