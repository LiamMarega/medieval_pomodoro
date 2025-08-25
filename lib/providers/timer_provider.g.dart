// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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

String _$timerControllerHash() => r'0751a7f3e8001f35a1dbb0f4b0263cf77dac905a';

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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
