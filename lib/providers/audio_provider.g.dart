// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AudioController)
const audioControllerProvider = AudioControllerProvider._();

final class AudioControllerProvider
    extends $NotifierProvider<AudioController, AudioState> {
  const AudioControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'audioControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$audioControllerHash();

  @$internal
  @override
  AudioController create() => AudioController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioState>(value),
    );
  }
}

String _$audioControllerHash() => r'c6e55e66aa95b1dc88b72dd1e7019416571b344c';

abstract class _$AudioController extends $Notifier<AudioState> {
  AudioState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AudioState, AudioState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AudioState, AudioState>, AudioState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
