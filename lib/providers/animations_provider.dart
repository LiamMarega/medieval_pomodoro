import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:medieval_pomodoro/models/timer_state.dart';
import 'package:medieval_pomodoro/providers/timer_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'rewards_provider.dart';

part 'animations_provider.g.dart';

class AnimationItem {
  final String name;
  final String path;
  final String description;

  const AnimationItem({
    required this.name,
    required this.path,
    required this.description,
  });

  factory AnimationItem.fromJson(Map<String, dynamic> m) => AnimationItem(
      name: m['name'], path: m['path'], description: m['description'] ?? '');
}

class AnimationsState {
  final List<AnimationItem> all;
  final AnimationItem? current;

  const AnimationsState({this.all = const [], this.current});

  AnimationsState copyWith({
    List<AnimationItem>? all,
    AnimationItem? current,
  }) {
    return AnimationsState(
      all: all ?? this.all,
      current: current,
    );
  }
}

@Riverpod(keepAlive: true)
class AnimationsController extends _$AnimationsController {
  @override
  AnimationsState build() {
    // Load asynchronously
    Future.microtask(() => _load());
    // Cambiar animación cuando lleguen recompensas
    ref.listen<RewardsState>(rewardsControllerProvider, (prev, next) {
      // Si hay cambios en las recompensas desbloqueadas, recalcular basado en puntos
      if (prev?.unlocked.length != next.unlocked.length) {
        // Recalcular basado en el modo actual del timer
        final timerState = ref.read(timerControllerProvider);
        final isBreak = !timerState.currentMode.isWork;
        pickForSession(isBreak: isBreak);
      }
    });

    // Listen to timer mode changes
    ref.listen<TimerState>(timerControllerProvider, (prev, next) {
      if (prev?.currentMode != next.currentMode) {
        final isBreak = !next.currentMode.isWork;
        pickForSession(isBreak: isBreak);
      }
    });

    return const AnimationsState();
  }

  Future<void> _load() async {
    try {
      final jsonStr =
          await rootBundle.loadString('assets/animations/animations_list.json');
      final data = (json.decode(jsonStr) as List)
          .map((e) => AnimationItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Después de cargar, recalcular la animación basada en el estado actual
      Future.microtask(() {
        final timerState = ref.read(timerControllerProvider);
        final isBreak = !timerState.currentMode.isWork;
        state = AnimationsState(all: data, current: null);
        pickForSession(isBreak: isBreak);
      });
    } catch (_) {
      state = const AnimationsState(all: [], current: null);
    }
  }

  /// Lógica de selección de animación:
  /// - Si es break: busca animación con "break" en el nombre
  /// - Si es work: selecciona según progreso (mini escenas y capítulos)
  ///
  /// Las animaciones se seleccionan cronológicamente según el orden en animations_list.json
  /// Mini escenas: cada 8 pomodoros (mini_8, mini_16, mini_24, ...)
  /// Capítulos: cada 25 pomodoros (chapter_25, chapter_50, chapter_75, ...)
  ///
  /// El índice se calcula: (capítulos × 2) + mini_escenas
  /// Esto permite escalar a muchas animaciones manteniendo progresión lógica
  void pickForSession({required bool isBreak}) {
    final all = state.all;
    if (all.isEmpty) return;

    if (isBreak) {
      // Buscar animación de break (puede haber múltiples en el futuro)
      final breakAnimations = all
          .where(
            (a) => a.name.toLowerCase().contains('break'),
          )
          .toList();

      if (breakAnimations.isNotEmpty) {
        // Si hay múltiples animaciones de break, usar la última desbloqueada
        // o la primera si ninguna está desbloqueada
        state = AnimationsState(all: all, current: breakAnimations.last);
      } else {
        // Fallback: usar la última animación si no hay ninguna de break
        state = AnimationsState(all: all, current: all.last);
      }
      return;
    }

    // Selección por progresión para modo work
    final unlocked = ref.read(rewardsControllerProvider).unlocked;

    // Contar capítulos desbloqueados (chapter_25, chapter_50, etc.)
    final chapters = unlocked.where((id) => id.startsWith('chapter_')).length;

    // Contar mini escenas desbloqueadas (mini_8, mini_16, etc.)
    final mini = unlocked.where((id) => id.startsWith('mini_')).length;

    // Calcular índice: cada capítulo cuenta como 2 puntos, cada mini escena como 1
    // Esto permite progresión más rápida con capítulos importantes
    final progressPoints = (chapters * 2) + mini;

    // Filtrar animaciones que NO son de break para el modo work
    final workAnimations = all
        .where(
          (a) => !a.name.toLowerCase().contains('break'),
        )
        .toList();

    if (workAnimations.isEmpty) {
      // Fallback si no hay animaciones de work
      state = AnimationsState(all: all, current: all.first);
      return;
    }

    // El índice se calcula basado en puntos de progreso
    // Clamp para asegurar que no exceda el número de animaciones disponibles
    final idx = progressPoints.clamp(0, workAnimations.length - 1);
    state = AnimationsState(all: all, current: workAnimations[idx]);
  }

  /// Avanza a la siguiente animación cronológica cuando se desbloquea una recompensa
  /// Solo avanza si la recompensa es de tipo miniScene o chapter
  /// Las animaciones avanzan en el orden definido en animations_list.json
  void pickForReward(RewardEvent? ev) {
    if (ev == null) return;

    // Solo avanzar animación para recompensas de progreso (no onboarding)
    if (ev.tier != RewardTier.miniScene &&
        ev.tier != RewardTier.chapter &&
        ev.tier != RewardTier.streak3) {
      return;
    }

    final all = state.all;
    if (all.isEmpty) return;

    // Filtrar animaciones de work (no break)
    final workAnimations = all
        .where(
          (a) => !a.name.toLowerCase().contains('break'),
        )
        .toList();

    if (workAnimations.isEmpty) return;

    // Encontrar la animación actual en la lista de work
    final cur = state.current;
    final currentIndex =
        cur != null ? workAnimations.indexWhere((e) => e.path == cur.path) : -1;

    // Avanzar a la siguiente animación cronológica
    if (currentIndex >= 0 && currentIndex + 1 < workAnimations.length) {
      // Avanzar una posición
      state =
          AnimationsState(all: all, current: workAnimations[currentIndex + 1]);
    } else if (currentIndex == -1) {
      // Si no se encontró la actual, usar la primera de work
      state = AnimationsState(all: all, current: workAnimations.first);
    }
    // Si ya está en la última, mantenerla
  }
}
