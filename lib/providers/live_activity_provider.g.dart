// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_activity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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
          isAutoDispose: true,
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
    r'26b1dd509bdb4426ba1430763e4195db96799c7b';

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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
