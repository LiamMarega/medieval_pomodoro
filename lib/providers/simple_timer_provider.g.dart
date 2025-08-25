// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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
    r'51439d322520bf2599c1bd572e45ae697d626f28';

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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
