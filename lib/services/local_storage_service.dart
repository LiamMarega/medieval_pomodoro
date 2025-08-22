import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LocalStorageService {
  static const String _workDurationKey = 'work_duration_minutes';
  static const String _shortBreakDurationKey = 'short_break_minutes';
  static const String _longBreakDurationKey = 'long_break_minutes';
  static const String _musicEnabledKey = 'music_enabled';

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
    };
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
}
