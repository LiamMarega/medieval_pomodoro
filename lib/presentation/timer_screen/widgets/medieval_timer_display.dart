import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pixel_frame.dart';

class MedievalTimerDisplay extends StatelessWidget {
  final String timeDisplay;
  final bool isActive;

  const MedievalTimerDisplay({
    super.key,
    required this.timeDisplay,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return PixelFrame(
      cornerSize: 32,
      edgeThickness: 8,
      padding: 20,
      child: Container(
        width: 85.w,
        height: 25.h,
        decoration: BoxDecoration(
          color: const Color(0xFF4A3728), // Dark brown medieval color
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF5A4738),
              const Color(0xFF3A2718),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeDisplay,
                style: GoogleFonts.pressStart2p(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFFDAA520), // Golden color
                  letterSpacing: 3.0,
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
              SizedBox(height: 2.h),
              // Animated glow effect when active
              if (isActive)
                Container(
                  width: 50.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryLight.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
