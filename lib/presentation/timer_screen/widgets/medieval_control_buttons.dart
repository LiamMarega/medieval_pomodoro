import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/pixel_frame.dart';

class MedievalControlButtons extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPlayPause;
  final VoidCallback onRestart;

  const MedievalControlButtons({
    super.key,
    required this.isActive,
    required this.onPlayPause,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return PixelFrame(
      cornerSize: 20,
      edgeThickness: 5,
      padding: 12,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Play/Pause Button
            _MedievalSpriteButton(
              spritePath: isActive
                  ? 'assets/sprites/close_button.png'
                  : 'assets/sprites/button_play.png',
              label: isActive ? 'PAUSE' : 'PLAY',
              onPressed: onPlayPause,
            ),
            SizedBox(width: 4.w),
            // Restart Button
            _MedievalSpriteButton(
              spritePath: 'assets/sprites/close_button.png',
              label: 'RESTART',
              onPressed: onRestart,
            ),
          ],
        ),
      ),
    );
  }
}

class _MedievalSpriteButton extends StatelessWidget {
  final String spritePath;
  final String label;
  final VoidCallback onPressed;
  const _MedievalSpriteButton({
    required this.spritePath,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 8.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(spritePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  label,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 6.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
