import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const SettingsSectionWidget({
    super.key,
    required this.title,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            offset: const Offset(2, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              border: const Border(
                bottom: BorderSide(
                  color: AppTheme.borderColor,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              title,
              style: GoogleFonts.pressStart2p(
                fontSize: 12.sp,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Padding(
            padding: padding ?? EdgeInsets.all(4.w),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}