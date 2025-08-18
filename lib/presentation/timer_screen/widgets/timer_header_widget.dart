import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/pixel_frame.dart';
import 'music_toggle_widget.dart';

class TimerHeaderWidget extends StatelessWidget {
  const TimerHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PixelFrame(
      cornerSize: 32,
      edgeThickness: 8,
      padding: 16,
      showLeftBorder: false,
      showRightBorder: false,
      borderStyle: MedievalBorderStyle.stone,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSwordDecoration(),
            Expanded(
              child: Text(
                'POMODORO TIMER',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFFDAA520),
                  letterSpacing: 2.0,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    Shadow(
                      color: const Color(0xFFDAA520).withValues(alpha: 0.5),
                      offset: const Offset(-1, -1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            const MusicToggleWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildSwordDecoration() {
    return SizedBox(
      width: 15.w,
      height: 15.w,
      child: Stack(
        children: [
          Positioned(
            top: 1.w,
            right: 4.w,
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 2.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFC0C0C0),
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 1.w,
            left: 4.w,
            child: Transform.rotate(
              angle: -0.785398,
              child: Container(
                width: 2.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFC0C0C0),
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
