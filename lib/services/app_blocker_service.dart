import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'native_screen_time_service.dart';

/// Service for blocking distracting apps during focus sessions
/// iOS: Uses native Screen Time API via NativeScreenTimeService
/// Android: Not currently supported (removed)
class AppBlockerService {
  static final AppBlockerService _instance = AppBlockerService._internal();
  factory AppBlockerService() => _instance;
  AppBlockerService._internal();

  final NativeScreenTimeService _nativeService = NativeScreenTimeService();

  /// Request Family Controls authorization (iOS only)
  /// This should be called during onboarding, only once
  Future<bool> requestPermission() async {
    if (!Platform.isIOS) {
      debugPrint('⚠️ App blocking only supported on iOS');
      return false;
    }

    try {
      debugPrint('🔒 Requesting Screen Time permissions...');
      final result = await _nativeService.requestAuthorization();
      debugPrint('🔒 Screen Time permission result: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Error requesting Screen Time permissions: $e');
      return false;
    }
  }

  /// Check if Family Controls authorization has been granted
  Future<bool> hasPermission() async {
    if (!Platform.isIOS) return false;

    try {
      return await _nativeService.isAuthorized();
    } catch (e) {
      debugPrint('❌ Error checking Screen Time authorization: $e');
      return false;
    }
  }

  /// Show app selection UI (FamilyActivityPicker)
  /// Should only be called once - selected apps are persisted
  Future<bool> selectAppsToBlock() async {
    if (!Platform.isIOS) {
      debugPrint('⚠️ App selection only supported on iOS');
      return false;
    }

    try {
      debugPrint('📱 Showing app selection UI...');
      final result = await _nativeService.selectAppsToBlock();
      debugPrint('📱 App selection result: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Error showing app selection UI: $e');
      return false;
    }
  }

  /// Check if user has selected apps to block
  Future<bool> hasAppsSelected() async {
    if (!Platform.isIOS) return false;

    try {
      return await _nativeService.hasAppsSelected();
    } catch (e) {
      debugPrint('❌ Error checking apps selected: $e');
      return false;
    }
  }

  /// Block the selected apps
  /// Apps must be selected first via selectAppsToBlock()
  Future<void> blockApps() async {
    if (!Platform.isIOS) return;

    try {
      debugPrint('🚫 Blocking apps...');
      await _nativeService.blockApps();
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
      await _nativeService.unblockApps();
      debugPrint('✅ Apps unblocked successfully');
    } catch (e) {
      debugPrint('❌ Error unblocking apps: $e');
      // Don't rethrow - let app continue even if unblocking fails
    }
  }

  /// Update the shield status (e.g., Focus vs Break)
  Future<void> updateShieldStatus({required bool isBreakTime}) async {
    if (!Platform.isIOS) return;

    final String titleKey =
        isBreakTime ? 'shield.break_title' : 'shield.focus_title';
    final String subtitleKey =
        isBreakTime ? 'shield.break_subtitle' : 'shield.focus_subtitle';

    await _nativeService.updateShieldStatus(
      title: tr(titleKey),
      subtitle: tr(subtitleKey),
      buttonLabel: tr('shield.close_button'),
    );
  }
}
