// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StatsController)
const statsControllerProvider = StatsControllerProvider._();

final class StatsControllerProvider
    extends $NotifierProvider<StatsController, StatsState> {
  const StatsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'statsControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$statsControllerHash();

  @$internal
  @override
  StatsController create() => StatsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsState>(value),
    );
  }
}

String _$statsControllerHash() => r'368014ef62d93f56de665b1d8f7b5559eb312b94';

abstract class _$StatsController extends $Notifier<StatsState> {
  StatsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<StatsState, StatsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<StatsState, StatsState>, StatsState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
