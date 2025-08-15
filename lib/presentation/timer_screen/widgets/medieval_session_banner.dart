import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/pixel_frame.dart';

class MedievalSessionBanner extends StatelessWidget {
  final String sessionType;
  final int sessionNumber;

  const MedievalSessionBanner({
    super.key,
    required this.sessionType,
    required this.sessionNumber,
  });

  @override
  Widget build(BuildContext context) {
    return PixelFrame(
      cornerSize: 20,
      edgeThickness: 6,
      padding: 12,
      child: Container(
        width: 90.w,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3728), // Dark brown
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF5A4738),
              const Color(0xFF4A3728),
            ],
          ),
        ),
        child: Column(
          children: [
            Text(
              '$sessionType'.toUpperCase(),
              style: GoogleFonts.pressStart2p(
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                color: const Color(0xFFDAA520), // Golden color
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'SESSION $sessionNumber - ${_getSessionDescription()}',
              style: GoogleFonts.pressStart2p(
                fontSize: 8.sp,
                color: const Color(0xFFB8860B), // Darker gold
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSessionDescription() {
    switch (sessionType.toLowerCase()) {
      case 'work':
        return 'FOCUS TIME';
      case 'short break':
        return 'SHORT BREAK';
      case 'long break':
        return 'LONG BREAK';
      default:
        return 'FOCUS TIME';
    }
  }
}
