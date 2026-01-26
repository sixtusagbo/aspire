// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_cat_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(revenueCatService)
const revenueCatServiceProvider = RevenueCatServiceProvider._();

final class RevenueCatServiceProvider
    extends
        $FunctionalProvider<
          RevenueCatService,
          RevenueCatService,
          RevenueCatService
        >
    with $Provider<RevenueCatService> {
  const RevenueCatServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'revenueCatServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$revenueCatServiceHash();

  @$internal
  @override
  $ProviderElement<RevenueCatService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RevenueCatService create(Ref ref) {
    return revenueCatService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RevenueCatService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RevenueCatService>(value),
    );
  }
}

String _$revenueCatServiceHash() => r'14566e6fb58f17c9102b49dcad46546c0b39f199';

/// Provider for premium status (reactive)

@ProviderFor(isPremium)
const isPremiumProvider = IsPremiumProvider._();

/// Provider for premium status (reactive)

final class IsPremiumProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Provider for premium status (reactive)
  const IsPremiumProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isPremiumProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isPremiumHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return isPremium(ref);
  }
}

String _$isPremiumHash() => r'248d30f50c8690cc67899a1474ddb3e1fba965d4';
