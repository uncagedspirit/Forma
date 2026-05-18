// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$moodForDateHash() => r'e6b4f2841e203cbd64fac84806b34d5532764efc';

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

/// See also [moodForDate].
@ProviderFor(moodForDate)
const moodForDateProvider = MoodForDateFamily();

/// See also [moodForDate].
class MoodForDateFamily extends Family<AsyncValue<MoodEntry?>> {
  /// See also [moodForDate].
  const MoodForDateFamily();

  /// See also [moodForDate].
  MoodForDateProvider call(
    DateTime date,
  ) {
    return MoodForDateProvider(
      date,
    );
  }

  @override
  MoodForDateProvider getProviderOverride(
    covariant MoodForDateProvider provider,
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
  String? get name => r'moodForDateProvider';
}

/// See also [moodForDate].
class MoodForDateProvider extends AutoDisposeFutureProvider<MoodEntry?> {
  /// See also [moodForDate].
  MoodForDateProvider(
    DateTime date,
  ) : this._internal(
          (ref) => moodForDate(
            ref as MoodForDateRef,
            date,
          ),
          from: moodForDateProvider,
          name: r'moodForDateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$moodForDateHash,
          dependencies: MoodForDateFamily._dependencies,
          allTransitiveDependencies:
              MoodForDateFamily._allTransitiveDependencies,
          date: date,
        );

  MoodForDateProvider._internal(
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
    FutureOr<MoodEntry?> Function(MoodForDateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MoodForDateProvider._internal(
        (ref) => create(ref as MoodForDateRef),
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
  AutoDisposeFutureProviderElement<MoodEntry?> createElement() {
    return _MoodForDateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MoodForDateProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MoodForDateRef on AutoDisposeFutureProviderRef<MoodEntry?> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _MoodForDateProviderElement
    extends AutoDisposeFutureProviderElement<MoodEntry?> with MoodForDateRef {
  _MoodForDateProviderElement(super.provider);

  @override
  DateTime get date => (origin as MoodForDateProvider).date;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
