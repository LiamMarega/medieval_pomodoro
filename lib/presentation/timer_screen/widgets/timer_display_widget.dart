import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medieval_pomodoro/models/timer_mode.dart';
import 'package:sizer/sizer.dart';

import '../../../providers/timer_provider.dart';

class TimerDisplayWidget extends ConsumerWidget {
  const TimerDisplayWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerControllerProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 5,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(2.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.5),
            width: 5,
          ),
        ),
        child: timerState.currentMode == TimerMode.gapTime
            ? Text(
                "NOTIFICACION",
                style: GoogleFonts.pressStart2p(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFFDAA520),
                  letterSpacing: 4.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      offset: const Offset(4, 4),
                      blurRadius: 8,
                    ),
                    Shadow(
                      color: const Color(0xFFDAA520).withValues(alpha: 0.5),
                      offset: const Offset(-2, -2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              )
            : Text(
                _formatTime(timerState.currentSeconds),
                style: GoogleFonts.pressStart2p(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFFDAA520),
                  letterSpacing: 4.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      offset: const Offset(4, 4),
                      blurRadius: 8,
                    ),
                    Shadow(
                      color: const Color(0xFFDAA520).withValues(alpha: 0.5),
                      offset: const Offset(-2, -2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
