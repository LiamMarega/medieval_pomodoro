import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'stats_provider.dart';

part 'rewards_provider.g.dart';

enum RewardTier { onboard1, onboard2, onboard3, miniScene, streak3, chapter }

class RewardEvent {
  final RewardTier tier;
  final String title;
  final String description;

  const RewardEvent(this.tier, this.title, this.description);
}

class RewardsState {
  final Set<String> unlocked; // ids
  final RewardEvent? lastEvent;

  const RewardsState({this.unlocked = const {}, this.lastEvent});

  RewardsState copyWith({
    Set<String>? unlocked,
    RewardEvent? lastEvent,
  }) {
    return RewardsState(
      unlocked: unlocked ?? this.unlocked,
      lastEvent: lastEvent,
    );
  }
}

@Riverpod(keepAlive: true)
class RewardsController extends _$RewardsController {
  @override
  RewardsState build() {
    // Load asynchronously
    Future.microtask(() => _restore());
    // Listen to stats changes
    ref.listen<StatsState>(statsControllerProvider, (prev, next) {
      evaluate(next); // reaccionar a cambios de stats
    });
    return const RewardsState();
  }

  Future<void> _restore() async {
    final sp = await SharedPreferences.getInstance();
    final set = sp.getStringList('sp.unlockedRewards') ?? [];
    state = RewardsState(unlocked: set.toSet());
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList('sp.unlockedRewards', state.unlocked.toList());
  }

  void evaluate(StatsState stats) {
    RewardEvent? ev;

    // Onboarding rápido
    if (!_isUnlocked('onboard_1') && stats.totalPomodoros >= 1) {
      ev = const RewardEvent(RewardTier.onboard1, 'Primer paso',
          '¡Completaste tu primer pomodoro!');
      _unlock('onboard_1', ev);
      return;
    }

    if (!_isUnlocked('onboard_2') &&
        (ref.read(statsControllerProvider.notifier).todayCount() >= 3)) {
      ev = const RewardEvent(RewardTier.onboard2, 'Calentando motores',
          '3 pomodoros en un mismo día.');
      _unlock('onboard_2', ev);
      return;
    }

    if (!_isUnlocked('onboard_3') && stats.totalPomodoros >= 5) {
      ev = const RewardEvent(
          RewardTier.onboard3, '¡Buen comienzo!', '5 pomodoros acumulados.');
      _unlock('onboard_3', ev);
      return;
    }

    // Fase media: cada 8–10 pomodoros → mini escena
    final nextMiniScene = ((stats.totalPomodoros ~/ 8) * 8);
    if (stats.totalPomodoros >= 8 &&
        stats.totalPomodoros == nextMiniScene &&
        !_isUnlocked('mini_$nextMiniScene')) {
      ev = RewardEvent(RewardTier.miniScene, 'Nueva escena',
          'Has alcanzado $nextMiniScene pomodoros.');
      _unlock('mini_$nextMiniScene', ev);
      return;
    }

    // Racha 3 días seguidos
    if (stats.currentStreakDays >= 3 &&
        !_isUnlocked('streak_3_${stats.currentStreakDays}')) {
      ev = const RewardEvent(RewardTier.streak3, 'Racha de 3 días',
          'Mantuviste el hábito por 3 días seguidos.');
      _unlock('streak_3_${stats.currentStreakDays}', ev);
      return;
    }

    // Capítulo importante cada 25–30
    if (stats.totalPomodoros >= 25 &&
        stats.totalPomodoros % 25 == 0 &&
        !_isUnlocked('chapter_${stats.totalPomodoros}')) {
      ev = RewardEvent(RewardTier.chapter, 'Capítulo desbloqueado',
          '${stats.totalPomodoros} pomodoros acumulados.');
      _unlock('chapter_${stats.totalPomodoros}', ev);
    }
  }

  bool _isUnlocked(String id) => state.unlocked.contains(id);

  void _unlock(String id, RewardEvent ev) {
    final set = {...state.unlocked, id};
    state = RewardsState(unlocked: set, lastEvent: ev);
    _persist();
  }

  /// Consumir el último evento (para no repetir modales/toasts)
  void consumeLastEvent() => state = RewardsState(unlocked: state.unlocked);
}
