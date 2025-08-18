import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SettingsHeaderWidget extends StatelessWidget {
  const SettingsHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(2.w),
                child: Icon(
                  Icons.arrow_back,
                  color: const Color(0xFFDAA520),
                  size: 24,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'OPTIONS',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFFDAA520),
                  letterSpacing: 2.0,
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
            SizedBox(width: 10.w),
          ],
        ),
      ),
    );
  }
}
