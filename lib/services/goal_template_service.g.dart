// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_template_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(goalTemplateService)
const goalTemplateServiceProvider = GoalTemplateServiceProvider._();

final class GoalTemplateServiceProvider
    extends
        $FunctionalProvider<
          GoalTemplateService,
          GoalTemplateService,
          GoalTemplateService
        >
    with $Provider<GoalTemplateService> {
  const GoalTemplateServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalTemplateServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalTemplateServiceHash();

  @$internal
  @override
  $ProviderElement<GoalTemplateService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GoalTemplateService create(Ref ref) {
    return goalTemplateService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalTemplateService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalTemplateService>(value),
    );
  }
}

String _$goalTemplateServiceHash() =>
    r'6cc73dcfefddc56163aac17023fcc910e3e4dc4c';

@ProviderFor(goalTemplatesStream)
const goalTemplatesStreamProvider = GoalTemplatesStreamProvider._();

final class GoalTemplatesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GoalTemplate>>,
          List<GoalTemplate>,
          Stream<List<GoalTemplate>>
        >
    with
        $FutureModifier<List<GoalTemplate>>,
        $StreamProvider<List<GoalTemplate>> {
  const GoalTemplatesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalTemplatesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalTemplatesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<GoalTemplate>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GoalTemplate>> create(Ref ref) {
    return goalTemplatesStream(ref);
  }
}

String _$goalTemplatesStreamHash() =>
    r'71e49d78b051d3086fb697c4eb266ed74e46a9da';
