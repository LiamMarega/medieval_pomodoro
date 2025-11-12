// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SimpleTimerController)
const simpleTimerControllerProvider = SimpleTimerControllerProvider._();

final class SimpleTimerControllerProvider
    extends $NotifierProvider<SimpleTimerController, TimerState> {
  const SimpleTimerControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'simpleTimerControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$simpleTimerControllerHash();

  @$internal
  @override
  SimpleTimerController create() => SimpleTimerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimerState>(value),
    );
  }
}

String _$simpleTimerControllerHash() =>
    r'a4b580b85a687e8b18e6fac1d8a645583b70d900';

abstract class _$SimpleTimerController extends $Notifier<TimerState> {
  TimerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TimerState, TimerState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TimerState, TimerState>, TimerState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
