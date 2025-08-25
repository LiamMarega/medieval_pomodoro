// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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

String _$audioControllerHash() => r'8aa0bcf9b8874cf650a45baaf6db65d0eaf3bf6b';

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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
