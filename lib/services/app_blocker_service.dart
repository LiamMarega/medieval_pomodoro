import 'dart:io';
import 'package:app_limiter/app_limiter.dart';
import 'package:flutter/foundation.dart';

class AppBlockerService {
  static final AppBlockerService _instance = AppBlockerService._internal();
  factory AppBlockerService() => _instance;
  AppBlockerService._internal();

  final AppLimiter _appLimiter = AppLimiter();

  /// Solicita permisos necesarios en Android
  Future<void> requestAndroidPermission() async {
    if (!Platform.isAndroid) return;
    try {
      debugPrint('🔒 Requesting Android permissions for AppBlocker...');
      await _appLimiter.requestAndroidPermission();
    } catch (e) {
      debugPrint('❌ Error requesting Android permissions: $e');
    }
  }

  /// Solicita permisos necesarios en iOS (Family Controls)
  Future<bool> requestIosPermission() async {
    if (!Platform.isIOS) return false;
    try {
      debugPrint('🔒 Requesting iOS permissions for AppBlocker...');
      final result = await _appLimiter.requestIosPermission();
      debugPrint('🔒 iOS Permission result: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Error requesting iOS permissions: $e');
      return false;
    }
  }

  /// Bloquea las apps especificadas en Android
  /// Nota: En la versión actual del plugin, se activa el bloqueo general configurado
  Future<void> blockAndroid(List<String> apps) async {
    if (!Platform.isAndroid) return;
    try {
      debugPrint('🚫 Blocking Android apps: $apps');
      await _appLimiter.blocAndroidApp();
    } catch (e) {
      debugPrint('❌ Error blocking Android apps: $e');
      throw e;
    }
  }

  /// Desbloquea las apps en Android
  Future<void> unblockAndroid(List<String> apps) async {
    if (!Platform.isAndroid) return;
    try {
      debugPrint('🔓 Unblocking Android apps');
      await _appLimiter.unblocAndroidApp();
    } catch (e) {
      debugPrint('❌ Error unblocking Android apps: $e');
      throw e;
    }
  }

  /// Bloquea apps en iOS
  Future<void> blockIos(List<String> apps) async {
    if (!Platform.isIOS) return;
    try {
      debugPrint('🚫 Blocking iOS apps');
      await _appLimiter.blockAndUnblockIOSApp();
    } catch (e) {
      debugPrint('❌ Error blocking iOS apps: $e');
      throw e;
    }
  }

  /// Desbloquea apps en iOS
  Future<void> unblockIos(List<String> apps) async {
    if (!Platform.isIOS) return;
    try {
      debugPrint('🔓 Unblocking iOS apps');
      // En iOS con app_limiter, el toggle suele manejar ambos estados, 
      // pero para asegurarnos intentamos llamar al método de desbloqueo si existe o re-togglaer
      // Nota: Revisar comportamiento específico del plugin en iOS
      await _appLimiter.blockAndUnblockIOSApp();
    } catch (e) {
      debugPrint('❌ Error unblocking iOS apps: $e');
      throw e;
    }
  }

  /// Verifica si los permisos de Android están concedidos
  Future<bool> checkAndroidPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _appLimiter.isAndroidPermissionAllowed();
    } catch (e) {
      debugPrint('❌ Error checking Android permissions: $e');
      return false;
    }
  }
}

