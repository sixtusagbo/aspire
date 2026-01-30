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

@ProviderFor(goalTemplates)
const goalTemplatesProvider = GoalTemplatesProvider._();

final class GoalTemplatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GoalTemplate>>,
          List<GoalTemplate>,
          FutureOr<List<GoalTemplate>>
        >
    with
        $FutureModifier<List<GoalTemplate>>,
        $FutureProvider<List<GoalTemplate>> {
  const GoalTemplatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalTemplatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalTemplatesHash();

  @$internal
  @override
  $FutureProviderElement<List<GoalTemplate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GoalTemplate>> create(Ref ref) {
    return goalTemplates(ref);
  }
}

String _$goalTemplatesHash() => r'668a60fc7a7c5403e66d2680a8904fde391c1e16';
