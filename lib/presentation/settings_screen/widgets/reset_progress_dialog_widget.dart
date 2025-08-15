import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class ResetProgressDialogWidget extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ResetProgressDialogWidget({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 80.w,
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              offset: const Offset(4, 4),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: AppTheme.errorLight,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 2,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'warning',
                color: Colors.white,
                size: 32,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Reset Progress?',
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(
                fontSize: 14.sp,
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'This will permanently delete all your achievements, session history, and progress. This action cannot be undone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 12.sp,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onCancel();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 12.sp,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      onConfirm();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppTheme.errorLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Reset All',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ResetProgressDialogWidget(
          onConfirm: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}