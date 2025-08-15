import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class TimerDurationSettingWidget extends StatefulWidget {
  final String title;
  final int currentValue;
  final int minValue;
  final int maxValue;
  final Function(int) onChanged;
  final String unit;

  const TimerDurationSettingWidget({
    super.key,
    required this.title,
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    this.unit = 'min',
  });

  @override
  State<TimerDurationSettingWidget> createState() =>
      _TimerDurationSettingWidgetState();
}

class _TimerDurationSettingWidgetState
    extends State<TimerDurationSettingWidget> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.currentValue;
  }

  void _decrementValue() {
    if (_currentValue > widget.minValue) {
      setState(() {
        _currentValue--;
      });
      widget.onChanged(_currentValue);
      HapticFeedback.lightImpact();
    }
  }

  void _incrementValue() {
    if (_currentValue < widget.maxValue) {
      setState(() {
        _currentValue++;
      });
      widget.onChanged(_currentValue);
      HapticFeedback.lightImpact();
    }
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              widget.title,
              style: GoogleFonts.roboto(
                fontSize: 14.sp,
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: _decrementValue,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: _currentValue > widget.minValue
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'remove',
                      color: _currentValue > widget.minValue
                          ? AppTheme.lightTheme.colorScheme.onSecondary
                          : AppTheme.textSecondary,
                      size: 16,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Container(
                  width: 15.w,
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppTheme.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$_currentValue ${widget.unit}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.robotoMono(
                      fontSize: 12.sp,
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                GestureDetector(
                  onTap: _incrementValue,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: _currentValue < widget.maxValue
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'add',
                      color: _currentValue < widget.maxValue
                          ? AppTheme.lightTheme.colorScheme.onSecondary
                          : AppTheme.textSecondary,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}