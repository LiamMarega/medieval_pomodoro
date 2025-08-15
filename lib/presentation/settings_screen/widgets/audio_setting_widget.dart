import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class AudioSettingWidget extends StatefulWidget {
  final String title;
  final bool isEnabled;
  final Function(bool) onToggle;
  final double? volume;
  final Function(double)? onVolumeChanged;

  const AudioSettingWidget({
    super.key,
    required this.title,
    required this.isEnabled,
    required this.onToggle,
    this.volume,
    this.onVolumeChanged,
  });

  @override
  State<AudioSettingWidget> createState() => _AudioSettingWidgetState();
}

class _AudioSettingWidgetState extends State<AudioSettingWidget> {
  late bool _isEnabled;
  late double _volume;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.isEnabled;
    _volume = widget.volume ?? 0.7;
  }

  void _toggleEnabled(bool value) {
    setState(() {
      _isEnabled = value;
    });
    widget.onToggle(value);
    HapticFeedback.lightImpact();
  }

  void _updateVolume(double value) {
    setState(() {
      _volume = value;
    });
    widget.onVolumeChanged?.call(value);
    HapticFeedback.selectionClick();
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: GoogleFonts.roboto(
                    fontSize: 14.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
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
                    alignment: _isEnabled
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
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
          if (widget.volume != null && _isEnabled) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'volume_down',
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor:
                            AppTheme.lightTheme.colorScheme.secondary,
                        inactiveTrackColor: AppTheme.borderColor,
                        thumbColor: AppTheme.lightTheme.colorScheme.secondary,
                        overlayColor: AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.2),
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 8),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _volume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        onChanged: _updateVolume,
                      ),
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName: 'volume_up',
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}