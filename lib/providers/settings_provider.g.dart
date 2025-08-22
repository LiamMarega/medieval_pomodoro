// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(SettingsController)
const settingsControllerProvider = SettingsControllerProvider._();

final class SettingsControllerProvider
    extends $AsyncNotifierProvider<SettingsController, SettingsState> {
  const SettingsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settingsControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerHash();

  @$internal
  @override
  SettingsController create() => SettingsController();
}

String _$settingsControllerHash() =>
    r'77df8d44e513ceabb8e36116a2b6076efe625079';

abstract class _$SettingsController extends $AsyncNotifier<SettingsState> {
  FutureOr<SettingsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<SettingsState>, SettingsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<SettingsState>, SettingsState>,
        AsyncValue<SettingsState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
