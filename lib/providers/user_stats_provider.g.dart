// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(UserStatsController)
const userStatsControllerProvider = UserStatsControllerProvider._();

final class UserStatsControllerProvider
    extends $AsyncNotifierProvider<UserStatsController, UserStats> {
  const UserStatsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userStatsControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userStatsControllerHash();

  @$internal
  @override
  UserStatsController create() => UserStatsController();
}

String _$userStatsControllerHash() =>
    r'd86195b04b3e549e9ff1167532486f3896c2cb63';

abstract class _$UserStatsController extends $AsyncNotifier<UserStats> {
  FutureOr<UserStats> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<UserStats>, UserStats>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<UserStats>, UserStats>,
        AsyncValue<UserStats>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Provider para las estadísticas resumidas
@ProviderFor(statsSummary)
const statsSummaryProvider = StatsSummaryProvider._();

/// Provider para las estadísticas resumidas
final class StatsSummaryProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>>,
        Map<String, dynamic>,
        FutureOr<Map<String, dynamic>>>
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// Provider para las estadísticas resumidas
  const StatsSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'statsSummaryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$statsSummaryHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return statsSummary(ref);
  }
}

String _$statsSummaryHash() => r'958b6b76460319582731ea6f1e035d018dc34cd0';

/// Provider para las sesiones de enfoque
@ProviderFor(focusSessions)
const focusSessionsProvider = FocusSessionsProvider._();

/// Provider para las sesiones de enfoque
final class FocusSessionsProvider extends $FunctionalProvider<
        AsyncValue<List<FocusSession>>,
        List<FocusSession>,
        FutureOr<List<FocusSession>>>
    with
        $FutureModifier<List<FocusSession>>,
        $FutureProvider<List<FocusSession>> {
  /// Provider para las sesiones de enfoque
  const FocusSessionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'focusSessionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$focusSessionsHash();

  @$internal
  @override
  $FutureProviderElement<List<FocusSession>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<FocusSession>> create(Ref ref) {
    return focusSessions(ref);
  }
}

String _$focusSessionsHash() => r'7a7c0bdbd393fa92d5f3d725c6a0db06a83ac625';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
