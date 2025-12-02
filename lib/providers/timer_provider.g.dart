// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimerController)
const timerControllerProvider = TimerControllerProvider._();

final class TimerControllerProvider
    extends $NotifierProvider<TimerController, TimerState> {
  const TimerControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'timerControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$timerControllerHash();

  @$internal
  @override
  TimerController create() => TimerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimerState>(value),
    );
  }
}

String _$timerControllerHash() => r'16de42af9726c9f9d2ab04bf3b8668bfd9c32b98';

abstract class _$TimerController extends $Notifier<TimerState> {
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
