import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/pixel_frame.dart';
import '../../../providers/timer_provider.dart';

class MusicToggleWidget extends ConsumerWidget {
  const MusicToggleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerControllerProvider);
    final timerController = ref.read(timerControllerProvider.notifier);

    return PixelFrame(
      cornerSize: 16,
      edgeThickness: 4,
      padding: 6,
      borderStyle: MedievalBorderStyle.stone,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            color: const Color(0xFFDAA520),
            size: 24,
          ),
          SizedBox(height: 1.h),
          GestureDetector(
            onTap: () => timerController.toggleMusic(),
            child: Container(
              width: 15.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: timerState.isMusicEnabled
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF757575),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: const Color(0xFFDAA520),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  timerState.isMusicEnabled ? 'ON' : 'OFF',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 6.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
