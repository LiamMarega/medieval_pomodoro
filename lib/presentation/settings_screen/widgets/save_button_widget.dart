import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/pixel_frame.dart';

class SaveButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const SaveButtonWidget({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PixelFrame(
      borderStyle: MedievalBorderStyle.stone,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFFDAA520),
              width: 2,
            ),
          ),
          child: Text(
            'SAVE SETTINGS',
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              fontSize: 12.sp,
              color: Colors.white,
              letterSpacing: 1.0,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
