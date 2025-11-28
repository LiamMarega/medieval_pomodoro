import 'dart:io';
import 'package:app_limiter/app_limiter.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_blocker_service.dart';

part 'app_blocker_provider.g.dart';

@Riverpod(keepAlive: true)
class AppBlocker extends _$AppBlocker {
  final AppBlockerService _service = AppBlockerService();
  static const String _prefsKey = 'blocked_apps_list';
  final _appLimiterPlugin = AppLimiter();

  static const List<String> _defaultBlockedApps = [
    "com.facebook.katana",
    "com.instagram.android",
    "com.zhiliaoapp.musically", // TikTok
    "com.reddit.frontpage",
    "com.google.android.youtube",
    "com.snapchat.android",
    "com.twitter.android",
    "tv.twitch.android.app",
    "com.discord",
    "com.netflix.mediaclient"
  ];

  @override
  Future<List<String>> build() async {
    return _loadBlockedApps();
  }

  Future<List<String>> _loadBlockedApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(_prefsKey);
      if (savedList != null && savedList.isNotEmpty) {
        return savedList;
      }
      return _defaultBlockedApps;
    } catch (e) {
      debugPrint('❌ Error loading blocked apps: $e');
      return _defaultBlockedApps;
    }
  }

  Future<void> _saveBlockedApps(List<String> apps) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, apps);
    } catch (e) {
      debugPrint('❌ Error saving blocked apps: $e');
    }
  }

  /// Solicita permisos iniciales
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await _service.requestAndroidPermission();
    } else if (Platform.isIOS) {
      await _service.requestIosPermission();
    }
  }

  /// Bloquea todas las apps configuradas
  Future<void> blockDistractingApps() async {
    try {
      print("blockDistractingApps");
      await _appLimiterPlugin.blockAndUnblockIOSApp();
    } catch (e) {
      debugPrint('❌ Provider error in blockDistractingApps: $e');
      // Don't propagate error - app should continue
    }
  }

  Future<void> _blockDistractingAppsInternal() async {
    final apps = state.value ?? _defaultBlockedApps;

    if (Platform.isAndroid) {
      // En Android, verificar/solicitar permisos antes de bloquear
      await _service.blockAndroid(apps);
    } else if (Platform.isIOS) {
      await _service.blockIos();
    }
  }

  /// Desbloquea todas las apps
  Future<void> unblockAll() async {
    try {
      await _unblockAllInternal().timeout(
        const Duration(seconds: 6),
        onTimeout: () {
          debugPrint('⏱️ Provider timeout: unblockAll operation');
        },
      );
    } catch (e) {
      debugPrint('❌ Provider error in unblockAll: $e');
      // Don't propagate error - app should continue
    }
  }

  Future<void> _unblockAllInternal() async {
    final apps = state.value ?? _defaultBlockedApps;
    debugPrint('🛡️ AppBlocker: Deactivating Shield');

    if (Platform.isAndroid) {
      await _service.unblockAndroid(apps);
    } else if (Platform.isIOS) {
      await _service.unblockIos();
    }
  }

  /// Agrega una app a la lista de bloqueo
  Future<void> addBlockedApp(String package) async {
    final current = state.value ?? _defaultBlockedApps;
    if (!current.contains(package)) {
      final newList = [...current, package];
      state = AsyncValue.data(newList);
      await _saveBlockedApps(newList);
    }
  }

  /// Remueve una app de la lista de bloqueo
  Future<void> removeBlockedApp(String package) async {
    final current = state.value ?? _defaultBlockedApps;
    if (current.contains(package)) {
      final newList = current.where((p) => p != package).toList();
      state = AsyncValue.data(newList);
      await _saveBlockedApps(newList);
    }
  }

  /// Restaura la lista por defecto
  Future<void> restoreDefaults() async {
    state = const AsyncValue.data(_defaultBlockedApps);
    await _saveBlockedApps(_defaultBlockedApps);
  }
}
