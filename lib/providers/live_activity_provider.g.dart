// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_activity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LiveActivityController)
const liveActivityControllerProvider = LiveActivityControllerProvider._();

final class LiveActivityControllerProvider
    extends $AsyncNotifierProvider<LiveActivityController, void> {
  const LiveActivityControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'liveActivityControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$liveActivityControllerHash();

  @$internal
  @override
  LiveActivityController create() => LiveActivityController();
}

String _$liveActivityControllerHash() =>
    r'dfbb7f1f4932bb3d6103d08233912a19f2d38d9f';

abstract class _$LiveActivityController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleValue(ref, null);
  }
}
