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
    extends $AsyncNotifierProvider<AppBlocker, List<String>> {
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

String _$appBlockerHash() => r'9151338b09102360fb333b257b6705410ce560b0';

abstract class _$AppBlocker extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<String>>, List<String>>,
        AsyncValue<List<String>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
