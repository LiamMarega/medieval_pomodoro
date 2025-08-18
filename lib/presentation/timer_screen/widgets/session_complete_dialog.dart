import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../providers/timer_provider.dart';

class SessionCompleteDialog extends ConsumerWidget {
  const SessionCompleteDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerControllerProvider);
    final timerController = ref.read(timerControllerProvider.notifier);

    return AlertDialog(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.borderColor,
          width: 2,
        ),
      ),
      title: Row(
        children: [
          CustomIconWidget(
            iconName: 'celebration',
            color: AppTheme.secondaryLight,
            size: 24,
          ),
          SizedBox(width: 2.w),
          Text(
            'SESSION COMPLETE!',
            style: GoogleFonts.pressStart2p(
              fontSize: 10.sp,
              fontWeight: FontWeight.normal,
              color: AppTheme.secondaryLight,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Congratulations, brave knight! You have successfully completed your ${timerState.sessionType.toLowerCase()} session.',
            style: GoogleFonts.roboto(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.successColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Next: ${timerState.sessionType.toUpperCase()}',
              style: GoogleFonts.pressStart2p(
                fontSize: 8.sp,
                color: AppTheme.successColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Automatically start the next session after a short delay
            Future.delayed(const Duration(seconds: 2), () {
              timerController.startTimer();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successColor,
            foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
          ),
          child: Text(
            'CONTINUE',
            style: GoogleFonts.pressStart2p(
              fontSize: 8.sp,
            ),
          ),
        ),
      ],
    );
  }
}
