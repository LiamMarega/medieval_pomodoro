import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/pixel_frame.dart';

class MedievalTaskDisplay extends StatelessWidget {
  final String? currentTask;
  final String motivationalMessage;

  const MedievalTaskDisplay({
    super.key,
    required this.currentTask,
    required this.motivationalMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Current Task Panel
        if (currentTask != null) ...[
          PixelFrame(
            cornerSize: 16,
            edgeThickness: 4,
            padding: 10,
            child: Container(
              width: 90.w,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT QUEST',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.normal,
                      color: AppTheme.secondaryLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    currentTask!,
                    style: GoogleFonts.roboto(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],

        // Motivational Message Panel
        PixelFrame(
          cornerSize: 16,
          edgeThickness: 4,
          padding: 10,
          child: Container(
            width: 90.w,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'lightbulb',
                  color: AppTheme.secondaryLight,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    motivationalMessage,
                    style: GoogleFonts.roboto(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
