// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnimationsController)
const animationsControllerProvider = AnimationsControllerProvider._();

final class AnimationsControllerProvider
    extends $NotifierProvider<AnimationsController, AnimationsState> {
  const AnimationsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'animationsControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$animationsControllerHash();

  @$internal
  @override
  AnimationsController create() => AnimationsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnimationsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnimationsState>(value),
    );
  }
}

String _$animationsControllerHash() =>
    r'80dbb9f210de4ec8b8943f055cd16a1872426193';

abstract class _$AnimationsController extends $Notifier<AnimationsState> {
  AnimationsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AnimationsState, AnimationsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AnimationsState, AnimationsState>,
        AnimationsState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
