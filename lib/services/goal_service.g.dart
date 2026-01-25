// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(goalService)
const goalServiceProvider = GoalServiceProvider._();

final class GoalServiceProvider
    extends $FunctionalProvider<GoalService, GoalService, GoalService>
    with $Provider<GoalService> {
  const GoalServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalServiceHash();

  @$internal
  @override
  $ProviderElement<GoalService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoalService create(Ref ref) {
    return goalService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalService>(value),
    );
  }
}

String _$goalServiceHash() => r'5e1af0a22113078fad8d8d418ff65d3ca2fd1fdb';
