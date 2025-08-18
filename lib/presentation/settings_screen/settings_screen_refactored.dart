import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../providers/settings_provider.dart';
import '../../providers/timer_provider.dart';
import '../../widgets/pixel_frame.dart';
import 'widgets/settings_header_widget.dart';
import 'widgets/music_setting_widget.dart';
import 'widgets/duration_setting_widget.dart';
import 'widgets/save_button_widget.dart';

class SettingsScreenRefactored extends ConsumerStatefulWidget {
  const SettingsScreenRefactored({super.key});

  @override
  ConsumerState<SettingsScreenRefactored> createState() => _SettingsScreenRefactoredState();
}

class _SettingsScreenRefactoredState extends ConsumerState<SettingsScreenRefactored> {
  late int _workDurationMinutes;
  late int _shortBreakMinutes;
  late int _longBreakMinutes;
  late bool _isMusicEnabled;

  @override
  void initState() {
    super.initState();
    final settingsState = ref.read(settingsControllerProvider);
    _workDurationMinutes = settingsState.workDurationMinutes;
    _shortBreakMinutes = settingsState.shortBreakMinutes;
    _longBreakMinutes = settingsState.longBreakMinutes;
    _isMusicEnabled = settingsState.isMusicEnabled;
  }

  void _saveSettings() {
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final timerController = ref.read(timerControllerProvider.notifier);

    settingsController.updateSettings(
      workDurationMinutes: _workDurationMinutes,
      shortBreakMinutes: _shortBreakMinutes,
      longBreakMinutes: _longBreakMinutes,
      isMusicEnabled: _isMusicEnabled,
    );

    timerController.updateSettings(
      workDurationMinutes: _workDurationMinutes,
      shortBreakMinutes: _shortBreakMinutes,
      longBreakMinutes: _longBreakMinutes,
      isMusicEnabled: _isMusicEnabled,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SettingsHeaderWidget(),
          Expanded(
            child: Container(
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
                      MusicSettingWidget(
                        isMusicEnabled: _isMusicEnabled,
                        onChanged: (value) => setState(() => _isMusicEnabled = value),
                      ),
                      SizedBox(height: 3.h),
                      DurationSettingWidget(
                        title: 'Work Duration',
                        currentValue: _workDurationMinutes,
                        minValue: 5,
                        maxValue: 60,
                        increment: 5,
                        onChanged: (value) => setState(() => _workDurationMinutes = value),
                      ),
                      SizedBox(height: 3.h),
                      DurationSettingWidget(
                        title: 'Short Break',
                        currentValue: _shortBreakMinutes,
                        minValue: 1,
                        maxValue: 15,
                        increment: 1,
                        onChanged: (value) => setState(() => _shortBreakMinutes = value),
                      ),
                      SizedBox(height: 3.h),
                      DurationSettingWidget(
                        title: 'Long Break',
                        currentValue: _longBreakMinutes,
                        minValue: 15,
                        maxValue: 60,
                        increment: 5,
                        onChanged: (value) => setState(() => _longBreakMinutes = value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SaveButtonWidget(onPressed: _saveSettings),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
