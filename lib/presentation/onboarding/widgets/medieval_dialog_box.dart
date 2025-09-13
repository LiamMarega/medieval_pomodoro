import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/pixel_frame.dart';
import '../../../theme/app_theme.dart';

/// Widget que muestra un diálogo estilo medieval con título y contenido
class MedievalDialogBox extends StatelessWidget {
  final String title;
  final String content;
  final Color backgroundColor;
  final Color textColor;

  const MedievalDialogBox({
    super.key,
    required this.title,
    required this.content,
    this.backgroundColor = const Color(0xFF2A1B0A),
    this.textColor = const Color(0xFFDAA520),
  });

  @override
  Widget build(BuildContext context) {
    return PixelFrame(
      cornerSize: 20,
      edgeThickness: 6,
      padding: 12,
      borderStyle: MedievalBorderStyle.wood,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(2.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor.withValues(alpha: 0.9),
              backgroundColor.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty) ...[
              Center(
                child: Text(
                  title,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 14.sp,
                    color: textColor,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 1.5.h),
            ],
            Text(
              content,
              style: GoogleFonts.vt323(
                fontSize: 16.sp,
                color: Colors.white,
                height: 1.3,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 1.h),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.arrow_downward,
                color: textColor,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
