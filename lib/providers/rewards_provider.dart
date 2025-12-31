import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'stats_provider.dart';

part 'rewards_provider.g.dart';

enum RewardTier {
  onboard1,
  onboard2,
  onboard3,
  miniScene,
  streak3,
  chapter,
  title
}

class RewardEvent {
  final RewardTier tier;
  final String title;
  final String description;

  const RewardEvent(this.tier, this.title, this.description);
}

class RewardsState {
  final Set<String> unlocked; // ids
  final RewardEvent? lastEvent;
  final int goldCoins;

  const RewardsState({
    this.unlocked = const {},
    this.lastEvent,
    this.goldCoins = 0,
  });

  RewardsState copyWith({
    Set<String>? unlocked,
    RewardEvent? lastEvent,
    int? goldCoins,
  }) {
    return RewardsState(
      unlocked: unlocked ?? this.unlocked,
      lastEvent: lastEvent,
      goldCoins: goldCoins ?? this.goldCoins,
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
    final coins = sp.getInt('sp.goldCoins') ?? 0;

    state = RewardsState(
      unlocked: set.toSet(),
      goldCoins: coins,
    );

    // Evaluar el estado actual para desbloquear recompensas pendientes
    // (por si el usuario ya tenía pomodoros pero las recompensas no estaban desbloqueadas)
    final currentStats = ref.read(statsControllerProvider);
    evaluate(currentStats);
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList('sp.unlockedRewards', state.unlocked.toList());
    await sp.setInt('sp.goldCoins', state.goldCoins);
  }

  void addCoins(int amount) {
    state = state.copyWith(goldCoins: state.goldCoins + amount);
    _persist();
  }

  void evaluate(StatsState stats) {
    RewardEvent? lastUnlockedEvent;
    bool hasChanges = false;

    // Titles based on Gold Coins
    final titles = {
      100: 'Squire',
      500: 'Knight',
      1000: 'Paladin',
      5000: 'King',
    };

    for (final entry in titles.entries) {
      final coinsNeeded = entry.key;
      final titleName = entry.value;
      final id = 'title_$coinsNeeded';

      if (state.goldCoins >= coinsNeeded && !_isUnlocked(id)) {
        lastUnlockedEvent = RewardEvent(
          RewardTier.title,
          'New Title: $titleName',
          'You have earned the title of $titleName!',
        );
        _unlockSilent(id);
        hasChanges = true;
      }
    }

    // Onboarding rápido (solo una vez)
    if (!_isUnlocked('onboard_1') && stats.totalPomodoros >= 1) {
      lastUnlockedEvent = const RewardEvent(RewardTier.onboard1, 'Primer paso',
          '¡Completaste tu primer pomodoro! (+10 💰)');
      _unlockSilent('onboard_1');
      addCoins(10);
      hasChanges = true;
    }

    if (!_isUnlocked('onboard_2') &&
        (ref.read(statsControllerProvider.notifier).todayCount() >= 3)) {
      lastUnlockedEvent = const RewardEvent(RewardTier.onboard2,
          'Calentando motores', '3 pomodoros en un mismo día. (+20 💰)');
      _unlockSilent('onboard_2');
      addCoins(20);
      hasChanges = true;
    }

    if (!_isUnlocked('onboard_3') && stats.totalPomodoros >= 5) {
      lastUnlockedEvent = const RewardEvent(RewardTier.onboard3,
          '¡Buen comienzo!', '5 pomodoros acumulados. (+30 💰)');
      _unlockSilent('onboard_3');
      addCoins(30);
      hasChanges = true;
    }

    // Desbloquear todas las mini escenas que deberías tener hasta ahora
    // Mini escenas: cada 8 pomodoros (8, 16, 24, 32, ...)
    if (stats.totalPomodoros >= 8) {
      final shouldHaveMiniScenes = stats.totalPomodoros ~/ 8;
      for (int i = 1; i <= shouldHaveMiniScenes; i++) {
        final miniId = 'mini_${i * 8}';
        if (!_isUnlocked(miniId)) {
          lastUnlockedEvent = RewardEvent(RewardTier.miniScene, 'Nueva escena',
              'Has alcanzado ${i * 8} pomodoros. (+50 💰)');
          _unlockSilent(miniId);
          addCoins(50);
          hasChanges = true;
        }
      }
    }

    // Desbloquear todos los capítulos que deberías tener hasta ahora
    // Capítulos: cada 25 pomodoros (25, 50, 75, 100, ...)
    if (stats.totalPomodoros >= 25) {
      final shouldHaveChapters = stats.totalPomodoros ~/ 25;
      for (int i = 1; i <= shouldHaveChapters; i++) {
        final chapterId = 'chapter_${i * 25}';
        if (!_isUnlocked(chapterId)) {
          lastUnlockedEvent = RewardEvent(
              RewardTier.chapter,
              'Capítulo desbloqueado',
              '${i * 25} pomodoros acumulados. (+100 💰)');
          _unlockSilent(chapterId);
          addCoins(100);
          hasChanges = true;
        }
      }
    }

    // Racha 3 días seguidos
    if (stats.currentStreakDays >= 3 &&
        !_isUnlocked('streak_3_${stats.currentStreakDays}')) {
      lastUnlockedEvent = const RewardEvent(
          RewardTier.streak3,
          'Racha de 3 días',
          'Mantuviste el hábito por 3 días seguidos. (+50 💰)');
      _unlockSilent('streak_3_${stats.currentStreakDays}');
      addCoins(50);
      hasChanges = true;
    }

    // Si se desbloqueó algo, actualizar el estado con el último evento y persistir
    if (hasChanges) {
      state = RewardsState(
          unlocked: state.unlocked,
          lastEvent: lastUnlockedEvent,
          goldCoins: state.goldCoins);
      _persist();
    }
  }

  bool _isUnlocked(String id) => state.unlocked.contains(id);

  /// Desbloquea una recompensa sin crear evento (para uso interno en evaluate)
  void _unlockSilent(String id) {
    if (!_isUnlocked(id)) {
      final set = {...state.unlocked, id};
      state = RewardsState(unlocked: set, lastEvent: state.lastEvent);
    }
  }

  /// Consumir el último evento (para no repetir modales/toasts)
  void consumeLastEvent() => state = RewardsState(unlocked: state.unlocked);
}
