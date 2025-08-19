// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(SettingsController)
const settingsControllerProvider = SettingsControllerProvider._();

final class SettingsControllerProvider
    extends $NotifierProvider<SettingsController, SettingsState> {
  const SettingsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settingsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerHash();

  @$internal
  @override
  SettingsController create() => SettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsState>(value),
    );
  }
}

String _$settingsControllerHash() =>
    r'38437bbe3da6bc932bae6e0461eb63b54de9e8e4';

abstract class _$SettingsController extends $Notifier<SettingsState> {
  SettingsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SettingsState, SettingsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SettingsState, SettingsState>,
        SettingsState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
