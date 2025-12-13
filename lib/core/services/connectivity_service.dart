// connectivity_service.dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  bool _isWiFiConnected = false;

  StreamSubscription? _subscription;

  ConnectivityService._();

  static final ConnectivityService _instance = ConnectivityService._();
  static ConnectivityService get instance => _instance;

  Future<void> initialize() async {
    // Check initial state
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    // Listen for changes
    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _isWiFiConnected = results.contains(ConnectivityResult.wifi);
    debugPrint('📶 Connection status: $results, WiFi: $_isWiFiConnected');
  }

  bool get isWiFiConnected => _isWiFiConnected;

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}
