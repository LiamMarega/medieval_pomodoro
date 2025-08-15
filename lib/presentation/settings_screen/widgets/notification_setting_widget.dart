import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class NotificationSettingWidget extends StatefulWidget {
  final String title;
  final String description;
  final bool isEnabled;
  final Function(bool) onToggle;
  final IconData icon;

  const NotificationSettingWidget({
    super.key,
    required this.title,
    required this.description,
    required this.isEnabled,
    required this.onToggle,
    required this.icon,
  });

  @override
  State<NotificationSettingWidget> createState() =>
      _NotificationSettingWidgetState();
}

class _NotificationSettingWidgetState extends State<NotificationSettingWidget> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.isEnabled;
  }

  void _toggleEnabled(bool value) {
    setState(() {
      _isEnabled = value;
    });
    widget.onToggle(value);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: _isEnabled
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.borderColor,
                width: 1,
              ),
            ),
            child: CustomIconWidget(
              iconName: widget.icon.toString().split('.').last,
              color: _isEnabled
                  ? AppTheme.lightTheme.colorScheme.onSecondary
                  : AppTheme.textSecondary,
              size: 20,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.roboto(
                    fontSize: 14.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  widget.description,
                  style: GoogleFonts.roboto(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _toggleEnabled(!_isEnabled),
            child: Container(
              width: 12.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: _isEnabled
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : AppTheme.borderColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    _isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 5.w,
                  height: 5.w,
                  margin: EdgeInsets.all(0.5.w),
                  decoration: BoxDecoration(
                    color: _isEnabled
                        ? AppTheme.lightTheme.colorScheme.onSecondary
                        : AppTheme.textSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.borderColor,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}