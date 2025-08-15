import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class AboutItemWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool showArrow;

  const AboutItemWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: icon.toString().split('.').last,
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                size: 20,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: 14.sp,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle!,
                      style: GoogleFonts.roboto(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow && onTap != null)
              CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}