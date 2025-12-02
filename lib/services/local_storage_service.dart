import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LocalStorageService {
  static const String _workDurationKey = 'work_duration_minutes';
  static const String _shortBreakDurationKey = 'short_break_minutes';
  static const String _longBreakDurationKey = 'long_break_minutes';
  static const String _musicEnabledKey = 'music_enabled';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _userNameKey = 'user_name';
  static const String _strictModeKey = 'strict_mode';

  // Timer Persistence Keys
  static const String _timerEndsAtKey = 'timer_ends_at';
  static const String _timerRemainingKey = 'timer_remaining_seconds';
  static const String _timerModeKey = 'timer_mode';
  static const String _timerIsActiveKey = 'timer_is_active';
  static const String _timerSessionNumberKey = 'timer_session_number';
  static const String _timerLastSavedKey = 'timer_last_saved';

  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService._();
      _preferences = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Save work duration
  Future<bool> saveWorkDuration(int minutes) async {
    try {
      final result = await _preferences!.setInt(_workDurationKey, minutes);
      return result;
    } catch (e) {
      return false;
    }
  }

  // Get work duration
  int getWorkDuration() {
    return _preferences?.getInt(_workDurationKey) ?? 25;
  }

  // Save onboarding completed status
  Future<bool> saveOnboardingCompleted(bool completed) async {
    try {
      final result =
          await _preferences!.setBool(_onboardingCompletedKey, completed);
      debugPrint('💾 Onboarding completed status saved: $completed');
      return result;
    } catch (e) {
      debugPrint('❌ Error saving onboarding completed status: $e');
      return false;
    }
  }

  // Get onboarding completed status
  bool isOnboardingCompleted() {
    return _preferences?.getBool(_onboardingCompletedKey) ?? false;
  }

  // Save user name
  Future<bool> saveUserName(String name) async {
    try {
      final result = await _preferences!.setString(_userNameKey, name);
      debugPrint('💾 User name saved: $name');
      return result;
    } catch (e) {
      debugPrint('❌ Error saving user name: $e');
      return false;
    }
  }

  // Get user name
  String? getUserName() {
    return _preferences?.getString(_userNameKey);
  }

  // Save short break duration
  Future<bool> saveShortBreakDuration(int minutes) async {
    try {
      final result =
          await _preferences!.setInt(_shortBreakDurationKey, minutes);
      debugPrint('💾 Short break duration saved: $minutes minutes');
      return result;
    } catch (e) {
      debugPrint('❌ Error saving short break duration: $e');
      return false;
    }
  }

  // Get short break duration
  int getShortBreakDuration() {
    return _preferences?.getInt(_shortBreakDurationKey) ?? 5;
  }

  // Save long break duration
  Future<bool> saveLongBreakDuration(int minutes) async {
    try {
      final result = await _preferences!.setInt(_longBreakDurationKey, minutes);
      debugPrint('💾 Long break duration saved: $minutes minutes');
      return result;
    } catch (e) {
      debugPrint('❌ Error saving long break duration: $e');
      return false;
    }
  }

  // Get long break duration
  int getLongBreakDuration() {
    return _preferences?.getInt(_longBreakDurationKey) ?? 30;
  }

  // Save music enabled state
  Future<bool> saveMusicEnabled(bool enabled) async {
    try {
      final result = await _preferences!.setBool(_musicEnabledKey, enabled);
      debugPrint('💾 Music enabled saved: $enabled');
      return result;
    } catch (e) {
      debugPrint('❌ Error saving music enabled: $e');
      return false;
    }
  }

  // Get music enabled state
  bool getMusicEnabled() {
    return _preferences?.getBool(_musicEnabledKey) ?? true; // Default to true
  }

  // Save all settings at once
  Future<bool> saveAllSettings({
    required int workDurationMinutes,
    required int shortBreakMinutes,
    required int longBreakMinutes,
    required bool isMusicEnabled,
  }) async {
    try {
      final results = await Future.wait([
        saveWorkDuration(workDurationMinutes),
        saveShortBreakDuration(shortBreakMinutes),
        saveLongBreakDuration(longBreakMinutes),
        saveMusicEnabled(isMusicEnabled),
        // Strict mode is saved separately or we can add it here if needed,
        // but for now let's keep it separate or add a new method for all settings including strict mode
      ]);

      final allSaved = results.every((result) => result);
      debugPrint('💾 All settings saved successfully: $allSaved');
      return allSaved;
    } catch (e) {
      debugPrint('❌ Error saving all settings: $e');
      return false;
    }
  }

  // Load all settings
  Map<String, dynamic> loadAllSettings() {
    return {
      'workDurationMinutes': getWorkDuration(),
      'shortBreakMinutes': getShortBreakDuration(),
      'longBreakMinutes': getLongBreakDuration(),
      'isMusicEnabled': getMusicEnabled(),
      'strictMode': getStrictMode(),
    };
  }

  // Save strict mode
  Future<bool> saveStrictMode(bool enabled) async {
    try {
      final result = await _preferences!.setBool(_strictModeKey, enabled);
      debugPrint('💾 Strict mode saved: $enabled');
      return result;
    } catch (e) {
      debugPrint('❌ Error saving strict mode: $e');
      return false;
    }
  }

  // Get strict mode
  bool getStrictMode() {
    return _preferences?.getBool(_strictModeKey) ?? false; // Default to false
  }

  // Clear all settings (for testing or reset)
  Future<bool> clearAllSettings() async {
    try {
      final result = await _preferences!.clear();
      debugPrint('🗑️ All settings cleared');
      return result;
    } catch (e) {
      debugPrint('❌ Error clearing settings: $e');
      return false;
    }
  }

  // ==========================================
  // Timer Persistence Methods
  // ==========================================

  Future<void> saveTimerState({
    required String? endsAt,
    required int remainingSeconds,
    required String mode,
    required bool isActive,
    required int sessionNumber,
  }) async {
    try {
      await _preferences!.setInt(_timerRemainingKey, remainingSeconds);
      await _preferences!.setString(_timerModeKey, mode);
      await _preferences!.setBool(_timerIsActiveKey, isActive);
      await _preferences!.setInt(_timerSessionNumberKey, sessionNumber);
      await _preferences!
          .setString(_timerLastSavedKey, DateTime.now().toIso8601String());

      if (endsAt != null) {
        await _preferences!.setString(_timerEndsAtKey, endsAt);
      } else {
        await _preferences!.remove(_timerEndsAtKey);
      }

      debugPrint(
          '💾 Timer state saved: Mode=$mode, Active=$isActive, Rem=$remainingSeconds');
    } catch (e) {
      debugPrint('❌ Error saving timer state: $e');
    }
  }

  Map<String, dynamic>? loadTimerState() {
    try {
      final mode = _preferences?.getString(_timerModeKey);
      if (mode == null) return null; // No saved state

      return {
        'endsAt': _preferences?.getString(_timerEndsAtKey),
        'remainingSeconds': _preferences?.getInt(_timerRemainingKey) ?? 0,
        'mode': mode,
        'isActive': _preferences?.getBool(_timerIsActiveKey) ?? false,
        'sessionNumber': _preferences?.getInt(_timerSessionNumberKey) ?? 0,
        'lastSaved': _preferences?.getString(_timerLastSavedKey),
      };
    } catch (e) {
      debugPrint('❌ Error loading timer state: $e');
      return null;
    }
  }

  Future<void> clearTimerState() async {
    try {
      await _preferences!.remove(_timerEndsAtKey);
      await _preferences!.remove(_timerRemainingKey);
      await _preferences!.remove(_timerModeKey);
      await _preferences!.remove(_timerIsActiveKey);
      await _preferences!.remove(_timerSessionNumberKey);
      await _preferences!.remove(_timerLastSavedKey);
      debugPrint('🗑️ Timer state cleared');
    } catch (e) {
      debugPrint('❌ Error clearing timer state: $e');
    }
  }
}
