// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiService)
const aiServiceProvider = AiServiceProvider._();

final class AiServiceProvider
    extends $FunctionalProvider<AIService, AIService, AIService>
    with $Provider<AIService> {
  const AiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiServiceHash();

  @$internal
  @override
  $ProviderElement<AIService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AIService create(Ref ref) {
    return aiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AIService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AIService>(value),
    );
  }
}

String _$aiServiceHash() => r'c5ca77fbbebcbe821b863ad2f3cf2f523ac3a779';
