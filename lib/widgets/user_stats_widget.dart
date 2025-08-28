import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_stats_provider.dart';
import '../core/app_export.dart';

class UserStatsWidget extends ConsumerWidget {
  const UserStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsSummaryProvider);

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
                Icons.analytics,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Knight\'s Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => _buildStatsContent(stats),
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error loading stats: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(Map<String, dynamic> stats) {
    return Column(
      children: [
        _buildStatRow(
          'Total Focus Time',
          '${stats['totalFocusMinutes']} min',
          Icons.timer,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          'Total Sessions',
          '${stats['totalSessions']}',
          Icons.work,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          'Average Session',
          '${stats['averageSessionLength']} min',
          Icons.trending_up,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          'Today\'s Focus',
          '${stats['todayMinutes']} min',
          Icons.today,
          Colors.purple,
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          'This Week',
          '${stats['thisWeekMinutes']} min',
          Icons.calendar_view_week,
          Colors.teal,
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          'This Month',
          '${stats['thisMonthMinutes']} min',
          Icons.calendar_month,
          Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
