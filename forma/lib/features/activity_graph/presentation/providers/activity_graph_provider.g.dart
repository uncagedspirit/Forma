// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_graph_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activityGraphHash() => r'538fbd575d45f11ef36f447de652848aca124366';

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

/// Maps daily completion scores to [ActivityLevel] for the GitHub-style
/// contribution graph.
///
/// Thresholds per ARCHITECTURE.md §5:
/// - 0% → none
/// - > 0%, ≤ 25% → light
/// - > 25%, ≤ 60% → medium
/// - > 60%, < 100% → dark
/// - 100% → full
///
/// Copied from [activityGraph].
@ProviderFor(activityGraph)
const activityGraphProvider = ActivityGraphFamily();

/// Maps daily completion scores to [ActivityLevel] for the GitHub-style
/// contribution graph.
///
/// Thresholds per ARCHITECTURE.md §5:
/// - 0% → none
/// - > 0%, ≤ 25% → light
/// - > 25%, ≤ 60% → medium
/// - > 60%, < 100% → dark
/// - 100% → full
///
/// Copied from [activityGraph].
class ActivityGraphFamily
    extends Family<AsyncValue<Map<DateTime, ActivityLevel>>> {
  /// Maps daily completion scores to [ActivityLevel] for the GitHub-style
  /// contribution graph.
  ///
  /// Thresholds per ARCHITECTURE.md §5:
  /// - 0% → none
  /// - > 0%, ≤ 25% → light
  /// - > 25%, ≤ 60% → medium
  /// - > 60%, < 100% → dark
  /// - 100% → full
  ///
  /// Copied from [activityGraph].
  const ActivityGraphFamily();

  /// Maps daily completion scores to [ActivityLevel] for the GitHub-style
  /// contribution graph.
  ///
  /// Thresholds per ARCHITECTURE.md §5:
  /// - 0% → none
  /// - > 0%, ≤ 25% → light
  /// - > 25%, ≤ 60% → medium
  /// - > 60%, < 100% → dark
  /// - 100% → full
  ///
  /// Copied from [activityGraph].
  ActivityGraphProvider call(
    DateTime start,
    DateTime end,
  ) {
    return ActivityGraphProvider(
      start,
      end,
    );
  }

  @override
  ActivityGraphProvider getProviderOverride(
    covariant ActivityGraphProvider provider,
  ) {
    return call(
      provider.start,
      provider.end,
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
  String? get name => r'activityGraphProvider';
}

/// Maps daily completion scores to [ActivityLevel] for the GitHub-style
/// contribution graph.
///
/// Thresholds per ARCHITECTURE.md §5:
/// - 0% → none
/// - > 0%, ≤ 25% → light
/// - > 25%, ≤ 60% → medium
/// - > 60%, < 100% → dark
/// - 100% → full
///
/// Copied from [activityGraph].
class ActivityGraphProvider
    extends AutoDisposeFutureProvider<Map<DateTime, ActivityLevel>> {
  /// Maps daily completion scores to [ActivityLevel] for the GitHub-style
  /// contribution graph.
  ///
  /// Thresholds per ARCHITECTURE.md §5:
  /// - 0% → none
  /// - > 0%, ≤ 25% → light
  /// - > 25%, ≤ 60% → medium
  /// - > 60%, < 100% → dark
  /// - 100% → full
  ///
  /// Copied from [activityGraph].
  ActivityGraphProvider(
    DateTime start,
    DateTime end,
  ) : this._internal(
          (ref) => activityGraph(
            ref as ActivityGraphRef,
            start,
            end,
          ),
          from: activityGraphProvider,
          name: r'activityGraphProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activityGraphHash,
          dependencies: ActivityGraphFamily._dependencies,
          allTransitiveDependencies:
              ActivityGraphFamily._allTransitiveDependencies,
          start: start,
          end: end,
        );

  ActivityGraphProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.start,
    required this.end,
  }) : super.internal();

  final DateTime start;
  final DateTime end;

  @override
  Override overrideWith(
    FutureOr<Map<DateTime, ActivityLevel>> Function(ActivityGraphRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActivityGraphProvider._internal(
        (ref) => create(ref as ActivityGraphRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<DateTime, ActivityLevel>>
      createElement() {
    return _ActivityGraphProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityGraphProvider &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ActivityGraphRef
    on AutoDisposeFutureProviderRef<Map<DateTime, ActivityLevel>> {
  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _ActivityGraphProviderElement
    extends AutoDisposeFutureProviderElement<Map<DateTime, ActivityLevel>>
    with ActivityGraphRef {
  _ActivityGraphProviderElement(super.provider);

  @override
  DateTime get start => (origin as ActivityGraphProvider).start;
  @override
  DateTime get end => (origin as ActivityGraphProvider).end;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
