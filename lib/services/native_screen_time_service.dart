import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Native iOS Screen Time integration service
/// Provides method channel communication for Family Controls and Screen Time API
class NativeScreenTimeService {
  static final NativeScreenTimeService _instance =
      NativeScreenTimeService._internal();
  factory NativeScreenTimeService() => _instance;
  NativeScreenTimeService._internal();

  static const MethodChannel _channel =
      MethodChannel('com.focusknight.app/screen_time');

  static const String _prefsKeyAppsSelected = 'screen_time_apps_selected';
  static const String _prefsKeyAuthGranted = 'screen_time_auth_granted';

  /// Check if Family Controls authorization has been granted
  Future<bool> isAuthorized() async {
    if (!Platform.isIOS) return false;

    try {
      final result =
          await _channel.invokeMethod<bool>('checkAuthorizationStatus');
      debugPrint('🔐 Screen Time authorization status: $result');

      // Store auth status
      if (result == true) {
        await _saveAuthGrantedStatus(true);
      }

      return result ?? false;
    } catch (e) {
      debugPrint('❌ Error checking Screen Time authorization: $e');
      return false;
    }
  }

  /// Request Family Controls authorization (one-time)
  /// Returns true if granted, false if denied
  Future<bool> requestAuthorization() async {
    if (!Platform.isIOS) return false;

    try {
      debugPrint('🔒 Requesting Family Controls authorization...');
      final result =
          await _channel.invokeMethod<bool>('requestFamilyControlsAuth');
      debugPrint('🔒 Family Controls auth result: $result');

      if (result == true) {
        await _saveAuthGrantedStatus(true);
      }

      return result ?? false;
    } catch (e) {
      debugPrint('❌ Error requesting Family Controls authorization: $e');
      return false;
    }
  }

  /// Show app selection UI (FamilyActivityPicker)
  /// Loads previous selection and allows user to modify it
  Future<bool> selectAppsToBlock() async {
    if (!Platform.isIOS) return false;

    try {
      // Check authorization first
      final authorized = await isAuthorized();
      if (!authorized) {
        debugPrint('❌ Cannot select apps - not authorized');
        return false;
      }

      debugPrint('📱 Showing app selection UI...');
      final result = await _channel.invokeMethod<bool>('selectAppsToBlock');
      debugPrint('📱 App selection result: $result');

      // Update status based on result (true = apps selected, false = no apps or cancelled)
      // The native code now always saves the selection, even if empty
      await _saveAppsSelectedStatus(result == true);
      
      // Also check actual state from native side to ensure sync
      final actualState = await hasAppsSelected();
      debugPrint('📱 Actual apps selected state: $actualState');

      return result ?? false;
    } catch (e) {
      debugPrint('❌ Error showing app selection UI: $e');
      return false;
    }
  }

  /// Block the selected apps
  /// Apps must be selected first via selectAppsToBlock()
  /// Note: The provider layer handles automatically opening selection UI if needed
  Future<void> blockApps() async {
    if (!Platform.isIOS) return;

    try {
      // Verify apps have been selected
      final appsSelected = await hasAppsSelected();
      if (!appsSelected) {
        debugPrint('⚠️ Cannot block apps - no apps selected');
        // The provider will handle opening the selection UI automatically
        return;
      }

      debugPrint('🚫 Blocking selected apps...');
      await _channel.invokeMethod('blockApps');
      debugPrint('✅ Apps blocked successfully');
    } catch (e) {
      debugPrint('❌ Error blocking apps: $e');
      // Don't rethrow - let app continue even if blocking fails
    }
  }

  /// Unblock all apps
  Future<void> unblockApps() async {
    if (!Platform.isIOS) return;

    try {
      debugPrint('🔓 Unblocking apps...');
      await _channel.invokeMethod('unblockApps');
      debugPrint('✅ Apps unblocked successfully');
    } catch (e) {
      debugPrint('❌ Error unblocking apps: $e');
      // Don't rethrow - let app continue even if unblocking fails
    }
  }

  /// Check if user has selected apps to block
  /// First checks native code for actual state, then falls back to SharedPreferences
  Future<bool> hasAppsSelected() async {
    if (!Platform.isIOS) return false;

    try {
      // First check native code for the actual state
      final nativeResult = await _channel.invokeMethod<bool>('checkAppsSelected');
      if (nativeResult != null) {
        // Sync with SharedPreferences
        await _saveAppsSelectedStatus(nativeResult);
        debugPrint('📱 Apps selected state from native: $nativeResult');
        return nativeResult;
      }
      
      // Fallback to SharedPreferences if native check fails
      final prefs = await SharedPreferences.getInstance();
      final prefsResult = prefs.getBool(_prefsKeyAppsSelected) ?? false;
      debugPrint('📱 Apps selected state from SharedPreferences: $prefsResult');
      return prefsResult;
    } catch (e) {
      debugPrint('❌ Error checking apps selected status: $e');
      // Fallback to SharedPreferences on error
      try {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getBool(_prefsKeyAppsSelected) ?? false;
      } catch (e2) {
        debugPrint('❌ Error reading from SharedPreferences: $e2');
        return false;
      }
    }
  }

  /// Check if user has granted authorization
  Future<bool> hasAuthGranted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefsKeyAuthGranted) ?? false;
    } catch (e) {
      debugPrint('❌ Error checking auth granted status: $e');
      return false;
    }
  }

  /// Save apps selected status
  Future<void> _saveAppsSelectedStatus(bool selected) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKeyAppsSelected, selected);
    } catch (e) {
      debugPrint('❌ Error saving apps selected status: $e');
    }
  }

  /// Save auth granted status
  Future<void> _saveAuthGrantedStatus(bool granted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKeyAuthGranted, granted);
    } catch (e) {
      debugPrint('❌ Error saving auth granted status: $e');
    }
  }

  /// Clear all stored preferences (for testing/debugging)
  Future<void> clearStoredPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKeyAppsSelected);
      await prefs.remove(_prefsKeyAuthGranted);
      debugPrint('🗑️ Screen Time preferences cleared');
    } catch (e) {
      debugPrint('❌ Error clearing preferences: $e');
    }
  }
}
