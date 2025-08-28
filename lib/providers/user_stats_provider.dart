import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/services/user_stats_service.dart';
import '../models/user_stats.dart';

part 'user_stats_provider.g.dart';

@Riverpod(keepAlive: true)
class UserStatsController extends _$UserStatsController {
  final UserStatsService _userStatsService = UserStatsService();

  @override
  Future<UserStats> build() async {
    return await _userStatsService.createOrUpdateUserStats();
  }

  /// Registra una sesión de enfoque completada
  Future<void> recordFocusSession(int durationMinutes) async {
    await _userStatsService.recordFocusSession(durationMinutes);
    // Refrescar el estado
    ref.invalidateSelf();
  }

  /// Obtiene las estadísticas resumidas
  Future<Map<String, dynamic>> getStatsSummary() async {
    return await _userStatsService.getStatsSummary();
  }

  /// Obtiene las sesiones de enfoque
  Future<List<FocusSession>> getFocusSessions() async {
    return await _userStatsService.getFocusSessions();
  }

  /// Refresca las estadísticas del usuario
  Future<void> refreshStats() async {
    ref.invalidateSelf();
  }
}

/// Provider para las estadísticas resumidas
@riverpod
Future<Map<String, dynamic>> statsSummary(StatsSummaryRef ref) async {
  final userStatsService = UserStatsService();
  return await userStatsService.getStatsSummary();
}

/// Provider para las sesiones de enfoque
@riverpod
Future<List<FocusSession>> focusSessions(FocusSessionsRef ref) async {
  final userStatsService = UserStatsService();
  return await userStatsService.getFocusSessions();
}
