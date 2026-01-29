// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tipService)
const tipServiceProvider = TipServiceProvider._();

final class TipServiceProvider
    extends $FunctionalProvider<TipService, TipService, TipService>
    with $Provider<TipService> {
  const TipServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tipServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tipServiceHash();

  @$internal
  @override
  $ProviderElement<TipService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TipService create(Ref ref) {
    return tipService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TipService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TipService>(value),
    );
  }
}

String _$tipServiceHash() => r'bc98a96ce23396a3d0b48cd739e5bfe5836e3f75';

@ProviderFor(tipOfTheDay)
const tipOfTheDayProvider = TipOfTheDayProvider._();

final class TipOfTheDayProvider
    extends $FunctionalProvider<AsyncValue<Tip?>, Tip?, FutureOr<Tip?>>
    with $FutureModifier<Tip?>, $FutureProvider<Tip?> {
  const TipOfTheDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tipOfTheDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tipOfTheDayHash();

  @$internal
  @override
  $FutureProviderElement<Tip?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Tip?> create(Ref ref) {
    return tipOfTheDay(ref);
  }
}

String _$tipOfTheDayHash() => r'1d36a696f1ffe76c0c80066a0f813eaa9b1193fd';
