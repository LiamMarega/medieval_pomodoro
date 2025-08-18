import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/pixel_frame.dart';
import '../../../providers/timer_provider.dart';

class ProgressIndicatorWidget extends ConsumerWidget {
  const ProgressIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerControllerProvider);
    final progress = _getProgress(timerState);

    return PixelFrame(
      cornerSize: 16,
      edgeThickness: 4,
      padding: 6,
      borderStyle: MedievalBorderStyle.stone,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'PROGRESS',
            style: GoogleFonts.pressStart2p(
              fontSize: 8.sp,
              color: const Color(0xFFDAA520),
            ),
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF4A3728),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFFDAA520),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            '${(progress * 100).toInt()}%',
            style: GoogleFonts.pressStart2p(
              fontSize: 6.sp,
              color: const Color(0xFFB8860B),
            ),
          ),
        ],
      ),
    );
  }

  double _getProgress(dynamic timerState) {
    if (timerState.totalSeconds == 0) return 0.0;
    return (timerState.totalSeconds - timerState.currentSeconds) / timerState.totalSeconds;
  }
}
