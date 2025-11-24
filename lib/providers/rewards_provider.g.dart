// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewards_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RewardsController)
const rewardsControllerProvider = RewardsControllerProvider._();

final class RewardsControllerProvider
    extends $NotifierProvider<RewardsController, RewardsState> {
  const RewardsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'rewardsControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$rewardsControllerHash();

  @$internal
  @override
  RewardsController create() => RewardsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RewardsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RewardsState>(value),
    );
  }
}

String _$rewardsControllerHash() => r'27f027c74f02d57ce50122cd8d15df1c91d5e0b7';

abstract class _$RewardsController extends $Notifier<RewardsState> {
  RewardsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<RewardsState, RewardsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<RewardsState, RewardsState>,
        RewardsState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
