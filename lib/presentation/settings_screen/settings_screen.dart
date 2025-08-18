import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/pixel_frame.dart';

class SettingsScreen extends StatefulWidget {
  final int workDurationMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final bool isMusicEnabled;
  final Function(int, int, int, bool) onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.workDurationMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.isMusicEnabled,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _workDurationMinutes;
  late int _shortBreakMinutes;
  late int _longBreakMinutes;
  late bool _isMusicEnabled;

  @override
  void initState() {
    super.initState();
    _workDurationMinutes = widget.workDurationMinutes;
    _shortBreakMinutes = widget.shortBreakMinutes;
    _longBreakMinutes = widget.longBreakMinutes;
    _isMusicEnabled = widget.isMusicEnabled;
  }

  void _saveSettings() {
    widget.onSettingsChanged(
      _workDurationMinutes,
      _shortBreakMinutes,
      _longBreakMinutes,
      _isMusicEnabled,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          _buildHeader(),
          // Settings content
          Expanded(
            child: _buildSettingsContent(),
          ),
          // Save button
          _buildSaveButton(),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Row(
          children: [
            // Back button
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(2.w),
                child: Icon(
                  Icons.arrow_back,
                  color: const Color(0xFFDAA520),
                  size: 24,
                ),
              ),
            ),
            // Title
            Expanded(
              child: Text(
                'OPTIONS',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFFDAA520), // Golden color
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    Shadow(
                      color: const Color(0xFFDAA520).withValues(alpha: 0.5),
                      offset: const Offset(-1, -1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10.w), // Space for symmetry
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return Container(
      child: PixelFrame(
        cornerSize: 24,
        edgeThickness: 6,
        padding: 16,
        borderStyle: MedievalBorderStyle.stone,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              // Music setting
              SizedBox(height: 3.h),
              // Work duration setting
              _buildDurationSetting(
                'Work Duration',
                _workDurationMinutes,
                5, // min value
                60, // max value
                5, // increment
                (value) => setState(() => _workDurationMinutes = value),
              ),
              SizedBox(height: 3.h),
              // Short break setting
              _buildDurationSetting(
                'Short Break',
                _shortBreakMinutes,
                1, // min value
                15, // max value
                1, // increment
                (value) => setState(() => _shortBreakMinutes = value),
              ),
              SizedBox(height: 3.h),
              // Long break setting
              _buildDurationSetting(
                'Long Break',
                _longBreakMinutes,
                15, // min value
                60, // max value
                5, // increment
                (value) => setState(() => _longBreakMinutes = value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSetting(
    String title,
    int currentValue,
    int minValue,
    int maxValue,
    int increment,
    Function(int) onChanged,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.pressStart2p(
              fontSize: 12.sp,
              color: const Color(0xFFDAA520),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Decrease button
              _buildControlButton(
                'assets/sprites/close_button.png',
                '-',
                currentValue > minValue
                    ? () => onChanged(currentValue - increment)
                    : null,
              ),
              // Current value
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3728),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFFDAA520),
                    width: 2,
                  ),
                ),
                child: Text(
                  '$currentValue min',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 14.sp,
                    color: const Color(0xFFDAA520),
                  ),
                ),
              ),
              // Increase button
              _buildControlButton(
                'assets/sprites/button_play.png',
                '+',
                currentValue < maxValue
                    ? () => onChanged(currentValue + increment)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      String spritePath, String label, VoidCallback? onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 15.w,
        height: 15.w,
        decoration: BoxDecoration(
          color: onPressed != null
              ? const Color(0xFF4A3728)
              : const Color(0xFF4A3728).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onPressed != null
                ? const Color(0xFFDAA520)
                : const Color(0xFFDAA520).withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(spritePath),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  colorFilter: onPressed != null
                      ? null
                      : ColorFilter.mode(
                          Colors.grey.withValues(alpha: 0.5),
                          BlendMode.modulate,
                        ),
                ),
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 6.sp,
                color: onPressed != null
                    ? const Color(0xFFDAA520)
                    : const Color(0xFFDAA520).withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      child: PixelFrame(
        borderStyle: MedievalBorderStyle.stone,
        child: InkWell(
          onTap: _saveSettings,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFFDAA520),
                width: 2,
              ),
            ),
            child: Text(
              'SAVE SETTINGS',
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(
                fontSize: 12.sp,
                color: Colors.white,
                letterSpacing: 1.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
