import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/settings_state.dart';

part 'settings_provider.g.dart';

@riverpod
class SettingsController extends _$SettingsController {
  @override
  SettingsState build() {
    return const SettingsState();
  }

  void updateSettings({
    required int workDurationMinutes,
    required int shortBreakMinutes,
    required int longBreakMinutes,
    required bool isMusicEnabled,
  }) {
    state = state.copyWith(
      workDurationMinutes: workDurationMinutes,
      shortBreakMinutes: shortBreakMinutes,
      longBreakMinutes: longBreakMinutes,
      isMusicEnabled: isMusicEnabled,
    );
    
    debugPrint('Settings updated: Work=$workDurationMinutes, Short=$shortBreakMinutes, Long=$longBreakMinutes, Music=$isMusicEnabled');
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }
}
