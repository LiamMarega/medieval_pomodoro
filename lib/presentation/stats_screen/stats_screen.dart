import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_stats_provider.dart';
import '../../widgets/user_stats_widget.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStatsAsync = ref.watch(userStatsControllerProvider);
    final sessionsAsync = ref.watch(focusSessionsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Knight\'s Progress',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del dispositivo
            userStatsAsync.when(
              data: (userStats) => _buildDeviceInfo(userStats),
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
              error: (error, stack) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Error loading user info: $error',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Widget de estadísticas
            const UserStatsWidget(),

            const SizedBox(height: 24),

            // Historial de sesiones
            _buildSessionsHistory(sessionsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfo(dynamic userStats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.device_hub,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Device Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsHistory(AsyncValue<List<dynamic>> sessionsAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Recent Sessions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          sessionsAsync.when(
            data: (sessions) => sessions.isEmpty
                ? const Center(
                    child: Text(
                      'No sessions recorded yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Column(
                    children: sessions.take(10).map((session) {
                      final startTime = DateTime.parse(session['startTime']);
                      final duration = session['durationMinutes'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
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
                                    '$duration min focus session',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${startTime.day}/${startTime.month}/${startTime.year} at ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
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
              child: CircularProgressIndicator(color: Colors.amber),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error loading sessions: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
