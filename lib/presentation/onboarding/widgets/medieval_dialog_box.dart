import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/pixel_frame.dart';

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
      padding: 10,
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 1.h),
              if (title.isNotEmpty) ...[
                Center(
                  child: Text(
                    title,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 16.sp,
                      color: textColor,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: GoogleFonts.vt323(
                      fontSize: 20.sp,
                      color: Colors.white,
                      height: 1,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
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
      ),
    );
  }
}
