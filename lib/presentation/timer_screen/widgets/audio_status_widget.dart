import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../providers/audio_provider.dart';

class AudioStatusWidget extends ConsumerWidget {
  const AudioStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioControllerProvider);

    // Show error if any
    if (audioState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(context, audioState.error!);
        ref.read(audioControllerProvider.notifier).clearError();
      });
    }

    // Show loading indicator if audio is initializing
    if (audioState.isLoading) {
      return Container(
        padding: EdgeInsets.all(2.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 3.w,
              height: 3.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryLight),
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              'Loading Audio...',
              style: GoogleFonts.pressStart2p(
                fontSize: 8.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Show status indicators
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Initialization status
        if (!audioState.isInitialized)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                         decoration: BoxDecoration(
               color: AppTheme.errorLight.withValues(alpha: 0.2),
               borderRadius: BorderRadius.circular(4),
             ),
             child: Text(
               'Audio Not Ready',
               style: GoogleFonts.pressStart2p(
                 fontSize: 6.sp,
                 color: AppTheme.errorLight,
               ),
             ),
          ),
        
        // Playing status
        if (audioState.isPlaying)
          Container(
            margin: EdgeInsets.only(left: 2.w),
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.music_note,
                  size: 3.w,
                  color: AppTheme.successColor,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Playing',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 6.sp,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ),
        
        // Music enabled status
        if (!audioState.isMusicEnabled)
          Container(
            margin: EdgeInsets.only(left: 2.w),
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Music OFF',
              style: GoogleFonts.pressStart2p(
                fontSize: 6.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Audio Error: $error',
          style: GoogleFonts.pressStart2p(fontSize: 8.sp),
        ),
        backgroundColor: AppTheme.errorLight,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
