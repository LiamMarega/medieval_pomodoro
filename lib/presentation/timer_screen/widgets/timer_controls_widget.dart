import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../providers/timer_provider.dart';

class TimerControlsWidget extends ConsumerWidget {
  const TimerControlsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerControllerProvider);
    final timerController = ref.read(timerControllerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildControlButton(
          spritePath: timerState.isActive
              ? 'assets/sprites/stop_button.png'
              : 'assets/sprites/play_button.png',
          onPressed: () {
            HapticFeedback.lightImpact();
            if (timerState.isActive) {
              timerController.pauseTimer();
            } else {
              timerController.startTimer();
            }
          },
        ),
        // _buildControlButton(
        //   spritePath: 'assets/sprites/reset_button.png',
        //   onPressed: () {
        //     HapticFeedback.lightImpact();
        //     timerController.restartTimer();
        //   },
        // ),
        _buildControlButton(
          spritePath: 'assets/sprites/settings_button.png',
          onPressed: () {
            HapticFeedback.lightImpact();
            timerController.restartTimer();
          },
        ),
        // _buildControlButton(
        //   spritePath: 'assets/sprites/minize_button.png',
        //   onPressed: () {
        //     HapticFeedback.lightImpact();
        //     Navigator.pushNamed(context, '/settings-screen');
        //   },
        // ),
      ],
    );
  }

  Widget _buildControlButton({
    required String spritePath,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Image.asset(
        spritePath,
        height: 14.w,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
      ),
    );
  }
}
