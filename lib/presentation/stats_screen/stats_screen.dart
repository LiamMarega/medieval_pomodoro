import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../generated/locale_keys.g.dart';
import '../../providers/user_stats_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/rewards_provider.dart';
import '../../models/focus_session.dart';
import '../../widgets/user_stats_widget.dart';
import '../../widgets/pixel_art_effect.dart';
import '../../widgets/pixel_frame.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStatsAsync = ref.watch(userStatsControllerProvider);
    final sessionsAsync = ref.watch(focusSessionsProvider);
    final stats = ref.watch(statsControllerProvider);
    final rewards = ref.watch(rewardsControllerProvider);

    return PixelArtEffect(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            LocaleKeys.stats_screen_knights_progress.tr(),
            style: GoogleFonts.pressStart2p(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(userStatsControllerProvider);
                ref.invalidate(focusSessionsProvider);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nuevas estadísticas del sistema de recompensas
              _buildNewStatsSection(stats, rewards),

              const SizedBox(height: 24),

              // // Información del dispositivo
              // userStatsAsync.when(
              //   data: (userStats) => _buildDeviceInfo(userStats),
              //   loading: () => const Center(
              //     child: CircularProgressIndicator(color: Colors.amber),
              //   ),
              //   error: (error, stack) => PixelFrame(
              //     cornerSize: 16,
              //     edgeThickness: 4,
              //     padding: 16,
              //     child: Container(
              //       padding: const EdgeInsets.all(16),
              //       decoration: BoxDecoration(
              //         color: Colors.red[900],
              //       ),
              //       child: Text(
              //         'Error loading user info: $error',
              //         style: GoogleFonts.pressStart2p(
              //           color: Colors.white,
              //           fontSize: 10,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              // const SizedBox(height: 24),

              // Widget de estadísticas legacy
              const UserStatsWidget(),

              const SizedBox(height: 24),

              // Historial de sesiones
              _buildSessionsHistory(sessionsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewStatsSection(StatsState stats, RewardsState rewards) {
    // Calcular tiempo total formateado
    final totalHours = stats.totalFocusSeconds ~/ 3600;
    final totalMinutes = (stats.totalFocusSeconds % 3600) ~/ 60;

    // Contar recompensas desbloqueadas
    final totalRewards = rewards.unlocked.length;
    final chapters =
        rewards.unlocked.where((id) => id.startsWith('chapter_')).length;
    final miniScenes =
        rewards.unlocked.where((id) => id.startsWith('mini_')).length;
    final streaks =
        rewards.unlocked.where((id) => id.startsWith('streak_')).length;

    // Pomodoros de hoy
    final today = DateTime.now().toLocal().toIso8601String().substring(0, 10);
    final todayPomodoros = stats.dailyPomodoros[today] ?? 0;

    return PixelFrame(
      cornerSize: 20,
      edgeThickness: 6,
      padding: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF2A1B0A),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Color(0xFFDAA520),
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  LocaleKeys.stats_screen_knights_achievements.tr(),
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Total Pomodoros
            _buildStatCard(
              LocaleKeys.stats_screen_total_pomodoros.tr(),
              '${stats.totalPomodoros}',
              Icons.timer,
              Colors.blue,
            ),
            const SizedBox(height: 12),

            // Tiempo total de enfoque
            _buildStatCard(
              LocaleKeys.stats_screen_total_focus_time.tr(),
              totalHours > 0
                  ? '${totalHours}h ${totalMinutes}m'
                  : '${totalMinutes}m',
              Icons.access_time,
              Colors.green,
            ),
            const SizedBox(height: 12),

            // Pomodoros de hoy
            _buildStatCard(
              LocaleKeys.stats_screen_todays_pomodoros.tr(),
              '$todayPomodoros',
              Icons.today,
              Colors.orange,
            ),
            const SizedBox(height: 12),

            // Racha actual
            _buildStatCard(
              LocaleKeys.stats_screen_current_streak.tr(),
              '${stats.currentStreakDays} ${LocaleKeys.stats_screen_days.tr()}',
              Icons.local_fire_department,
              Colors.red,
            ),
            const SizedBox(height: 12),

            // Recompensas desbloqueadas
            _buildStatCard(
              LocaleKeys.stats_screen_rewards_unlocked.tr(),
              '$totalRewards',
              Icons.star,
              Colors.amber,
              subtitle:
                  '($chapters ${LocaleKeys.stats_screen_chapters.tr()}, $miniScenes ${LocaleKeys.stats_screen_mini_scenes.tr()}, $streaks ${LocaleKeys.stats_screen_streaks.tr()})',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color,
      {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2318),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.pressStart2p(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.pressStart2p(
                      color: Colors.grey[500],
                      fontSize: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(dynamic userStats) {
    return PixelFrame(
      cornerSize: 20,
      edgeThickness: 6,
      padding: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF2A1B0A),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.device_hub,
                  color: Color(0xFFDAA520),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Device Information',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Device Type', userStats.deviceType),
            const SizedBox(height: 8),
            _buildInfoRow('Device Model', userStats.deviceModel),
            const SizedBox(height: 8),
            _buildInfoRow(
                'Device ID', userStats.deviceId.substring(0, 8) + '...'),
            const SizedBox(height: 8),
            _buildInfoRow('Member Since',
                '${userStats.createdAt.day}/${userStats.createdAt.month}/${userStats.createdAt.year}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.pressStart2p(
              color: Colors.grey[400],
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: GoogleFonts.pressStart2p(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsHistory(AsyncValue<List<FocusSession>> sessionsAsync) {
    return PixelFrame(
      cornerSize: 20,
      edgeThickness: 6,
      padding: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF2A1B0A),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history,
                  color: Color(0xFFDAA520),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  LocaleKeys.stats_screen_recent_sessions.tr(),
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            sessionsAsync.when(
              data: (sessions) => sessions.isEmpty
                  ? Center(
                      child: Text(
                        LocaleKeys.stats_screen_no_sessions_recorded_yet.tr(),
                        style: GoogleFonts.pressStart2p(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    )
                  : Column(
                      children: sessions.take(10).map((session) {
                        final startTime = session.startTime;
                        final duration = session.durationMinutes;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A2318),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      LocaleKeys.stats_screen_min_focus_session
                                          .tr(namedArgs: {
                                        'minutes': duration.toString()
                                      }),
                                      style: GoogleFonts.pressStart2p(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${startTime.day}/${startTime.month}/${startTime.year} at ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
                                      style: GoogleFonts.pressStart2p(
                                        color: Colors.grey[400],
                                        fontSize: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFDAA520)),
              ),
              error: (error, stack) => Center(
                child: Text(
                  LocaleKeys.stats_screen_error_loading_sessions
                      .tr(namedArgs: {'error': error.toString()}),
                  style: GoogleFonts.pressStart2p(
                    color: Colors.red,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
