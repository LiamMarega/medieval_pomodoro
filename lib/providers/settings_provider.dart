import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/settings_state.dart';
import '../services/local_storage_service.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  late LocalStorageService _storage;

  @override
  Future<SettingsState> build() async {
    // Initialize local storage
    _storage = await LocalStorageService.getInstance();

    // Load saved settings from local storage
    final savedSettings = _storage.loadAllSettings();

    debugPrint('📱 Loading saved settings: $savedSettings');

    return SettingsState(
      workDurationMinutes: savedSettings['workDurationMinutes'],
      shortBreakMinutes: savedSettings['shortBreakMinutes'],
      longBreakMinutes: savedSettings['longBreakMinutes'],
      isMusicEnabled: savedSettings['isMusicEnabled'],
    );
  }

  Future<void> updateSettings({
    required int workDurationMinutes,
    required int shortBreakMinutes,
    required int longBreakMinutes,
    required bool isMusicEnabled,
  }) async {
    // Update state immediately for UI responsiveness
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(
        workDurationMinutes: workDurationMinutes,
        shortBreakMinutes: shortBreakMinutes,
        longBreakMinutes: longBreakMinutes,
        isMusicEnabled: isMusicEnabled,
      ));
    }

    // Save to local storage
    final saved = await _storage.saveAllSettings(
      workDurationMinutes: workDurationMinutes,
      shortBreakMinutes: shortBreakMinutes,
      longBreakMinutes: longBreakMinutes,
      isMusicEnabled: isMusicEnabled,
    );

    if (!saved) {
      debugPrint('⚠️ Warning: Failed to save settings to local storage');
    }

    debugPrint(
        'Settings updated: Work=$workDurationMinutes, Short=$shortBreakMinutes, Long=$longBreakMinutes, Music=$isMusicEnabled');
  }

  Future<void> setLoading(bool isLoading) async {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(isLoading: isLoading));
    }
  }

  Future<void> setError(String? error) async {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(error: error));
    }
  }

  // Individual setting update methods for convenience
  Future<void> updateWorkDuration(int minutes) async {
    final currentState = state.value;
    if (currentState != null) {
      await updateSettings(
        workDurationMinutes: minutes,
        shortBreakMinutes: currentState.shortBreakMinutes,
        longBreakMinutes: currentState.longBreakMinutes,
        isMusicEnabled: currentState.isMusicEnabled,
      );
    }
  }

  Future<void> updateShortBreakDuration(int minutes) async {
    final currentState = state.value;
    if (currentState != null) {
      await updateSettings(
        workDurationMinutes: currentState.workDurationMinutes,
        shortBreakMinutes: minutes,
        longBreakMinutes: currentState.longBreakMinutes,
        isMusicEnabled: currentState.isMusicEnabled,
      );
    }
  }

  Future<void> updateLongBreakDuration(int minutes) async {
    final currentState = state.value;
    if (currentState != null) {
      await updateSettings(
        workDurationMinutes: currentState.workDurationMinutes,
        shortBreakMinutes: currentState.shortBreakMinutes,
        longBreakMinutes: minutes,
        isMusicEnabled: currentState.isMusicEnabled,
      );
    }
  }

  Future<void> updateMusicEnabled(bool enabled) async {
    final currentState = state.value;
    if (currentState != null) {
      await updateSettings(
        workDurationMinutes: currentState.workDurationMinutes,
        shortBreakMinutes: currentState.shortBreakMinutes,
        longBreakMinutes: currentState.longBreakMinutes,
        isMusicEnabled: enabled,
      );
    }
  }

  // Reset to default settings
  Future<void> resetToDefaults() async {
    await updateSettings(
      workDurationMinutes: 25,
      shortBreakMinutes: 5,
      longBreakMinutes: 30,
      isMusicEnabled: true,
    );
    debugPrint('🔄 Settings reset to defaults');
  }
}
