import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'stats_provider.g.dart';

class StatsState {
  final int totalPomodoros;
  final int totalFocusSeconds;
  final Map<String, int> dailyPomodoros; // yyyy-MM-dd -> count
  final int currentStreakDays;
  final String? lastActiveDate; // yyyy-MM-dd

  const StatsState({
    this.totalPomodoros = 0,
    this.totalFocusSeconds = 0,
    this.dailyPomodoros = const {},
    this.currentStreakDays = 0,
    this.lastActiveDate,
  });

  StatsState copyWith({
    int? totalPomodoros,
    int? totalFocusSeconds,
    Map<String, int>? dailyPomodoros,
    int? currentStreakDays,
    String? lastActiveDate,
  }) {
    return StatsState(
      totalPomodoros: totalPomodoros ?? this.totalPomodoros,
      totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
      dailyPomodoros: dailyPomodoros ?? this.dailyPomodoros,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}

@Riverpod(keepAlive: true)
class StatsController extends _$StatsController {
  @override
  StatsState build() {
    // Load asynchronously
    Future.microtask(() => _restore());
    return const StatsState();
  }

  Future<void> _restore() async {
    final sp = await SharedPreferences.getInstance();
    final totalP = sp.getInt('sp.totalPomodoros') ?? 0;
    final totalSec = sp.getInt('sp.totalFocusSeconds') ?? 0;
    final dailyJson = sp.getString('sp.dailyPomodoros');
    final lastDate = sp.getString('sp.lastActiveDate');
    final streak = sp.getInt('sp.currentStreak') ?? 0;
    state = StatsState(
      totalPomodoros: totalP,
      totalFocusSeconds: totalSec,
      dailyPomodoros:
          dailyJson != null ? Map<String, int>.from(json.decode(dailyJson)) : {},
      lastActiveDate: lastDate,
      currentStreakDays: streak,
    );
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('sp.totalPomodoros', state.totalPomodoros);
    await sp.setInt('sp.totalFocusSeconds', state.totalFocusSeconds);
    await sp.setString('sp.dailyPomodoros', json.encode(state.dailyPomodoros));
    await sp.setString('sp.lastActiveDate', state.lastActiveDate ?? '');
    await sp.setInt('sp.currentStreak', state.currentStreakDays);
  }

  /// Llamar cuando un pomodoro de trabajo termina correctamente.
  Future<void> markPomodoroCompleted({required int workSeconds}) async {
    final today = _today();
    final Map<String, int> daily = Map.of(state.dailyPomodoros);
    daily[today] = (daily[today] ?? 0) + 1;

    // Streak: si ayer hubo actividad y hoy también, +1; si había saltos, reinicia a 1.
    final prev = state.lastActiveDate;
    final streak = (prev == _yesterday()) ? state.currentStreakDays + 1 : 1;

    state = state.copyWith(
      totalPomodoros: state.totalPomodoros + 1,
      totalFocusSeconds: state.totalFocusSeconds + workSeconds,
      dailyPomodoros: daily,
      currentStreakDays: streak,
      lastActiveDate: today,
    );

    await _persist();
  }

  int todayCount() => state.dailyPomodoros[_today()] ?? 0;

  static String _today() => DateTime.now().toLocal().toIso8601String().substring(0, 10);

  static String _yesterday() {
    final d = DateTime.now().toLocal().subtract(const Duration(days: 1));
    return d.toIso8601String().substring(0, 10);
  }
}

