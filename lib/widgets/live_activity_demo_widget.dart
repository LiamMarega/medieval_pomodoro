import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/widgets/minimized_pomodoro_widget.dart';
import '../providers/timer_provider.dart';

/// Demo widget showing how to use the MinimizedPomodoroWidget
/// This can be used as a compact timer display or when the app goes to background
class LiveActivityDemoWidget extends ConsumerWidget {
  const LiveActivityDemoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerControllerProvider);
    final timerController = ref.read(timerControllerProvider.notifier);

    // Convert seconds to Duration
    final remaining = Duration(seconds: timerState.currentSeconds);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Activity Demo',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This shows how the minimized pomodoro widget looks:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          // The minimized pomodoro widget
          MinimizedPomodoroWidget(
            remaining: remaining,
            isRunning: timerState.isActive,
            onPause: () => timerController.pauseTimer(),
            onResume: () => timerController.startTimer(),
            onStop: () => timerController.restartTimer(),
            title: timerState.sessionType,
            compact: false,
          ),
          const SizedBox(height: 16),
          // Compact version
          Text(
            'Compact version:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          MinimizedPomodoroWidget(
            remaining: remaining,
            isRunning: timerState.isActive,
            onPause: () => timerController.pauseTimer(),
            onResume: () => timerController.startTimer(),
            onStop: () => timerController.restartTimer(),
            title: timerState.sessionType,
            compact: true,
          ),
          const SizedBox(height: 24),
          // Live Activity status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Activity Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Session Type: ${timerState.sessionType}'),
                  Text('Is Active: ${timerState.isActive}'),
                  Text('Remaining: ${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}'),
                  Text('Session Number: ${timerState.sessionNumber}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
