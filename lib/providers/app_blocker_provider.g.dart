// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_blocker_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppBlocker)
const appBlockerProvider = AppBlockerProvider._();

final class AppBlockerProvider
    extends $AsyncNotifierProvider<AppBlocker, bool> {
  const AppBlockerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appBlockerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appBlockerHash();

  @$internal
  @override
  AppBlocker create() => AppBlocker();
}

String _$appBlockerHash() => r'49ee6e89545f684c7b126fd1c4761ae5cf062cf4';

abstract class _$AppBlocker extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<bool>, bool>,
        AsyncValue<bool>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
