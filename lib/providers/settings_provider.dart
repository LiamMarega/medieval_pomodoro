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
      strictMode: savedSettings['strictMode'] ?? false,
    );
  }

  Future<void> updateSettings({
    required int workDurationMinutes,
    required int shortBreakMinutes,
    required int longBreakMinutes,
    required bool isMusicEnabled,
    required bool strictMode,
  }) async {
    // Update state immediately for UI responsiveness
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(
        workDurationMinutes: workDurationMinutes,
        shortBreakMinutes: shortBreakMinutes,
        longBreakMinutes: longBreakMinutes,
        isMusicEnabled: isMusicEnabled,
        strictMode: strictMode,
      ));
    }

    // Save to local storage
    final saved = await _storage.saveAllSettings(
      workDurationMinutes: workDurationMinutes,
      shortBreakMinutes: shortBreakMinutes,
      longBreakMinutes: longBreakMinutes,
      isMusicEnabled: isMusicEnabled,
    );

    // Save strict mode separately
    await _storage.saveStrictMode(strictMode);

    if (!saved) {
      debugPrint('⚠️ Warning: Failed to save settings to local storage');
    }

    debugPrint(
        'Settings updated: Work=$workDurationMinutes, Short=$shortBreakMinutes, Long=$longBreakMinutes, Music=$isMusicEnabled, Strict=$strictMode');
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
        strictMode: currentState.strictMode,
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
        strictMode: currentState.strictMode,
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
        strictMode: currentState.strictMode,
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
        strictMode: currentState.strictMode,
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
      strictMode: false,
    );
    debugPrint('🔄 Settings reset to normal defaults (25/5/30 minutes)');
  }

  // Set test durations for quick testing
  Future<void> setTestDurations() async {
    await updateSettings(
      workDurationMinutes: 0, // 10 seconds
      shortBreakMinutes: 0, // 10 seconds
      longBreakMinutes: 0, // 20 seconds
      isMusicEnabled: true,
      strictMode: false,
    );
    debugPrint('🧪 Test durations set: 10s work/break, 20s long break');
  }

  // Reset everything and return to onboarding
  Future<void> resetEverything() async {
    try {
      // Clear all settings from local storage
      await _storage.clearAllSettings();

      // Reset onboarding status
      await _storage.saveOnboardingCompleted(false);

      // Clear user name
      await _storage.saveUserName('');

      debugPrint('🗑️ Everything reset - returning to onboarding flow');

      // Reset the current state to defaults
      state = AsyncValue.data(const SettingsState(
        workDurationMinutes: 25,
        shortBreakMinutes: 5,
        longBreakMinutes: 30,
        isMusicEnabled: true,
        strictMode: false,
      ));
    } catch (e) {
      debugPrint('❌ Error resetting everything: $e');
      rethrow;
    }
  }
}
