import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../providers/settings_provider.dart';
import '../../providers/timer_provider.dart';
import '../../providers/audio_provider.dart';
import '../../widgets/pixel_frame.dart';
import 'widgets/settings_header_widget.dart';

class SettingsScreenRefactored extends ConsumerStatefulWidget {
  const SettingsScreenRefactored({super.key});

  @override
  ConsumerState<SettingsScreenRefactored> createState() =>
      _SettingsScreenRefactoredState();
}

class _SettingsScreenRefactoredState
    extends ConsumerState<SettingsScreenRefactored> {
  late int _workDurationMinutes;
  late int _shortBreakMinutes;
  late int _longBreakMinutes;

  @override
  void initState() {
    super.initState();
    final settingsState = ref.read(settingsControllerProvider);
    _workDurationMinutes = settingsState.workDurationMinutes;
    _shortBreakMinutes = settingsState.shortBreakMinutes;
    _longBreakMinutes = settingsState.longBreakMinutes;
  }

  void _autoSaveSettings() {
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final timerController = ref.read(timerControllerProvider.notifier);

    settingsController.updateSettings(
      workDurationMinutes: _workDurationMinutes,
      shortBreakMinutes: _shortBreakMinutes,
      longBreakMinutes: _longBreakMinutes,
      isMusicEnabled: true, // Always true
    );

    timerController.updateSettings(
      workDurationMinutes: _workDurationMinutes,
      shortBreakMinutes: _shortBreakMinutes,
      longBreakMinutes: _longBreakMinutes,
      isMusicEnabled: true, // Always true
    );

    // Ensure music continues playing by using the audio provider
    final audioController = ref.read(audioControllerProvider.notifier);
    audioController.setMusicEnabled(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SettingsHeaderWidget(),
          Expanded(
            child: PixelFrame(
              cornerSize: 24,
              edgeThickness: 6,
              padding: 20,
              borderStyle: MedievalBorderStyle.stone,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 3.h),
                    _buildDurationSetting(
                      title: 'WORK DURATION',
                      currentValue: _workDurationMinutes,
                      minValue: 1,
                      maxValue: 60,
                      increment: 5,
                      onChanged: (value) {
                        setState(() => _workDurationMinutes = value);
                        _autoSaveSettings();
                      },
                      customIncrementLogic: (currentValue, isIncrement) {
                        if (isIncrement) {
                          // When incrementing, always add 5
                          return currentValue + 5;
                        } else {
                          // When decrementing, use smart logic
                          if (currentValue > 5) {
                            // If above 5, subtract 5
                            return currentValue - 5;
                          } else if (currentValue > 1) {
                            // If between 1 and 5, subtract 1
                            return currentValue - 1;
                          } else {
                            // If at 1, can't go lower
                            return currentValue;
                          }
                        }
                      },
                    ),
                    SizedBox(height: 4.h),
                    _buildDurationSetting(
                      title: 'SHORT BREAK TIME',
                      currentValue: _shortBreakMinutes,
                      minValue: 1,
                      maxValue: 15,
                      increment: 1,
                      onChanged: (value) {
                        setState(() => _shortBreakMinutes = value);
                        _autoSaveSettings();
                      },
                    ),
                    SizedBox(height: 4.h),
                    _buildDurationSetting(
                      title: 'LONG BREAK TIME',
                      currentValue: _longBreakMinutes,
                      minValue: 15,
                      maxValue: 60,
                      increment: 5,
                      onChanged: (value) {
                        setState(() => _longBreakMinutes = value);
                        _autoSaveSettings();
                      },
                    ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildDurationSetting({
    required String title,
    required int currentValue,
    required int minValue,
    required int maxValue,
    required int increment,
    required Function(int) onChanged,
    int Function(int, bool)? customIncrementLogic,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          // Title
          Text(
            title,
            style: GoogleFonts.pressStart2p(
              fontSize: 16.sp,
              color: const Color(0xFFDAA520),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          // Value display and controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Minus button
              _buildControlButton(
                '-',
                _canDecrement(currentValue, minValue, customIncrementLogic)
                    ? () => onChanged(_getDecrementedValue(
                        currentValue, increment, customIncrementLogic))
                    : null,
              ),
              // Value display
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3728),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFDAA520),
                    width: 3,
                  ),
                ),
                child: Text(
                  '${currentValue.toString().padLeft(2, '0')}:00',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 20.sp,
                    color: const Color(0xFFDAA520),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Plus button
              _buildControlButton(
                '+',
                _canIncrement(currentValue, maxValue, increment)
                    ? () => onChanged(_getIncrementedValue(
                        currentValue, increment, customIncrementLogic))
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(String label, VoidCallback? onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 18.w,
        height: 18.w,
        decoration: BoxDecoration(
          color: onPressed != null
              ? const Color(0xFF4A3728)
              : const Color(0xFF4A3728).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onPressed != null
                ? const Color(0xFFDAA520)
                : const Color(0xFFDAA520).withValues(alpha: 0.5),
            width: 3,
          ),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: const Color(0xFFDAA520).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 24.sp,
              color: onPressed != null
                  ? const Color(0xFFDAA520)
                  : const Color(0xFFDAA520).withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  bool _canDecrement(int currentValue, int minValue,
      int Function(int, bool)? customIncrementLogic) {
    if (customIncrementLogic != null) {
      final newValue = customIncrementLogic(currentValue, false);
      return newValue != currentValue && newValue >= minValue;
    }
    return currentValue > minValue;
  }

  bool _canIncrement(int currentValue, int maxValue, int increment) {
    return currentValue < maxValue;
  }

  int _getDecrementedValue(int currentValue, int increment,
      int Function(int, bool)? customIncrementLogic) {
    if (customIncrementLogic != null) {
      return customIncrementLogic(currentValue, false);
    }
    return currentValue - increment;
  }

  int _getIncrementedValue(int currentValue, int increment,
      int Function(int, bool)? customIncrementLogic) {
    if (customIncrementLogic != null) {
      return customIncrementLogic(currentValue, true);
    }
    return currentValue + increment;
  }
}
