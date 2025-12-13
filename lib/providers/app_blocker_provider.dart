import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/app_blocker_service.dart';

part 'app_blocker_provider.g.dart';

@Riverpod(keepAlive: true)
class AppBlocker extends _$AppBlocker {
  final AppBlockerService _service = AppBlockerService();

  @override
  Future<bool> build() async {
    // Return whether apps have been selected
    return await _service.hasAppsSelected();
  }

  /// Request Family Controls permission (one-time, during onboarding)
  Future<bool> requestPermission() async {
    if (!Platform.isIOS) {
      debugPrint('⚠️ App blocking only supported on iOS');
      return false;
    }

    try {
      debugPrint('🔒 Requesting Screen Time permission...');
      final result = await _service.requestPermission();
      debugPrint('🔒 Permission result: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Error requesting permission: $e');
      return false;
    }
  }

  /// Check if user has authorized Family Controls
  Future<bool> hasPermission() async {
    try {
      return await _service.hasPermission();
    } catch (e) {
      debugPrint('❌ Error checking permission: $e');
      return false;
    }
  }

  /// Show app selection UI (loads previous selection, allows modification)
  /// Updates state in real-time based on selection result
  Future<bool> selectAppsToBlock() async {
    if (!Platform.isIOS) {
      debugPrint('⚠️ App selection only supported on iOS');
      return false;
    }

    try {
      // Check permission first
      final hasAuth = await hasPermission();
      if (!hasAuth) {
        debugPrint('⚠️ Cannot select apps - permission not granted');
        return false;
      }

      debugPrint('📱 Showing app selection UI...');
      final result = await _service.selectAppsToBlock();

      // Always update state based on result (true = apps selected, false = no apps)
      // This ensures the UI reflects the current selection state
      state = AsyncValue.data(result);
      
      // Also refresh from service to ensure we have the latest state
      final actualState = await _service.hasAppsSelected();
      state = AsyncValue.data(actualState);
      
      debugPrint('📱 App selection completed. State updated: $actualState');

      return result;
    } catch (e) {
      debugPrint('❌ Error selecting apps: $e');
      return false;
    }
  }

  /// Block the selected apps (called when timer starts)
  Future<void> blockDistractingApps() async {
    if (!Platform.isIOS) return;

    try {
      debugPrint('🚫 blockDistractingApps called');

      // Check if apps have been selected
      final appsSelected = state.value ?? false;
      if (!appsSelected) {
        debugPrint('⚠️ Cannot block apps - no apps selected yet');
        debugPrint('📱 Automatically opening app selection UI...');
        
        // Check authorization first
        final hasAuth = await hasPermission();
        if (!hasAuth) {
          debugPrint('🔒 Authorization not granted, requesting...');
          final authResult = await requestPermission();
          if (!authResult) {
            debugPrint('❌ Authorization denied, cannot select apps');
            return;
          }
        }
        
        // Automatically open app selection UI
        final selectionResult = await selectAppsToBlock();
        if (selectionResult) {
          debugPrint('✅ Apps selected, now blocking...');
          // After selection, try to block again
          await _service.blockApps();
          debugPrint('✅ Apps blocked successfully');
        } else {
          debugPrint('⚠️ App selection cancelled or failed');
        }
        return;
      }

      await _service.blockApps();
      debugPrint('✅ Apps blocked successfully');
    } catch (e) {
      debugPrint('❌ Provider error in blockDistractingApps: $e');
      // Don't propagate error - app should continue
    }
  }

  /// Unblock all apps (called when timer pauses/completes)
  Future<void> unblockAll() async {
    if (!Platform.isIOS) return;

    try {
      debugPrint('🔓 unblockAll called');
      await _service.unblockApps();
      debugPrint('✅ Apps unblocked successfully');
    } catch (e) {
      debugPrint('❌ Provider error in unblockAll: $e');
      // Don't propagate error - app should continue
    }
  }
}
