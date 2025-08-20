import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import '../core/services/live_activity_service.dart';
import '../models/timer_state.dart';

part 'live_activity_provider.g.dart';

@riverpod
class LiveActivityController extends _$LiveActivityController {
  LiveActivityService? _liveActivityService;
  StreamSubscription<FGBGType>? _fgbgSubscription;
  bool _isAppInBackground = false;
  TimerState? _lastTimerState;

  @override
  Future<void> build() async {
    _initializeLiveActivity();
    _setupForegroundBackgroundListener();
  }

  Future<void> _initializeLiveActivity() async {
    try {
      debugPrint('🚀 Initializing Live Activity service...');

      _liveActivityService = LiveActivityService(
        appGroupId: 'group.com.medieval.pomodoro',
        urlScheme: 'medievalpomodoro',
        customActivityId: 'medieval-pomodoro-activity',
      );

      await _liveActivityService!.init(
        onActionFromIsland: (action) {
          debugPrint('🎯 Live Activity action received: $action');
          _handleLiveActivityAction(action);
        },
        onActivityBecameActive: (activityId, pushToken) {
          debugPrint('✅ Live Activity became active: $activityId');
        },
        onActivityEnded: (activityId) {
          debugPrint('🏁 Live Activity ended: $activityId');
        },
      );

      debugPrint('✅ Live Activity service initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Live Activity service: $e');
    }
  }

  void _handleLiveActivityAction(String action) {
    // This will be called from the timer provider to handle actions
    // We'll need to pass this action to the timer provider
    debugPrint('🎯 Live Activity action received: $action');
    // The timer provider will handle this action when it's connected
  }

  /// Sync timer state with Live Activity
  Future<void> syncTimerState(TimerState timerState) async {
    if (_liveActivityService == null) {
      debugPrint('⚠️ Live Activity service not initialized');
      return;
    }

    try {
      // Check if Live Activities are available first
      final isAvailable = await _liveActivityService!.isAvailable();
      if (!isAvailable) {
        debugPrint('⚠️ Live Activities not available on this device');
        return;
      }

      // Convert session type to PomodoroPhase
      PomodoroPhase phase;
      switch (timerState.sessionType) {
        case 'Work':
          phase = PomodoroPhase.focus;
          break;
        case 'Short Break':
          phase = PomodoroPhase.shortBreak;
          break;
        case 'Long Break':
          phase = PomodoroPhase.longBreak;
          break;
        default:
          phase = PomodoroPhase.focus;
      }

      // Calculate end time based on current seconds remaining
      final endAt =
          DateTime.now().add(Duration(seconds: timerState.currentSeconds));

      final snapshot = PomodoroSnapshot(
        taskName: timerState.sessionType,
        phase: phase,
        endAt: endAt,
        isRunning: timerState.isActive,
      );

      await _liveActivityService!.sync(snapshot);
      debugPrint('✅ Timer state synced with Live Activity');
    } catch (e) {
      debugPrint('❌ Error syncing timer state: $e');
      // Don't throw the error, just log it to avoid breaking the timer
    }
  }

  /// Update specific Live Activity fields
  Future<void> patchLiveActivity({
    bool? isRunning,
    DateTime? newEndAt,
    PomodoroPhase? phase,
    String? taskName,
  }) async {
    if (_liveActivityService == null) {
      debugPrint('⚠️ Live Activity service not initialized');
      return;
    }

    try {
      await _liveActivityService!.patch(
        isRunning: isRunning,
        newEndAt: newEndAt,
        phase: phase,
        taskName: taskName,
      );
      debugPrint('✅ Live Activity patched successfully');
    } catch (e) {
      debugPrint('❌ Error patching Live Activity: $e');
    }
  }

  /// End the Live Activity
  Future<void> endLiveActivity() async {
    if (_liveActivityService == null) {
      debugPrint('⚠️ Live Activity service not initialized');
      return;
    }

    try {
      await _liveActivityService!.end();
      debugPrint('✅ Live Activity ended successfully');
    } catch (e) {
      debugPrint('❌ Error ending Live Activity: $e');
    }
  }

  /// Check if Live Activities are available
  Future<bool> isLiveActivityAvailable() async {
    if (_liveActivityService == null) {
      return false;
    }

    try {
      return await _liveActivityService!.isAvailable();
    } catch (e) {
      debugPrint('❌ Error checking Live Activity availability: $e');
      return false;
    }
  }

  /// Get Live Activity status for debugging
  Future<void> debugLiveActivityStatus() async {
    if (_liveActivityService == null) {
      debugPrint('🔍 Live Activity service is null');
      return;
    }

    try {
      final isAvailable = await _liveActivityService!.isAvailable();
      debugPrint('🔍 Live Activity available: $isAvailable');
    } catch (e) {
      debugPrint('🔍 Error checking Live Activity status: $e');
    }
  }

  /// Setup foreground/background listener
  void _setupForegroundBackgroundListener() {
    _fgbgSubscription = FGBGEvents.instance.stream.listen((event) {
      debugPrint('🔄 App state changed: $event');

      switch (event) {
        case FGBGType.background:
          _isAppInBackground = true;
          _onAppWentToBackground();
          break;
        case FGBGType.foreground:
          _isAppInBackground = false;
          _onAppWentToForeground();
          break;
      }
    });
  }

  /// Called when app goes to background
  void _onAppWentToBackground() {
    debugPrint('📱 App went to background');

    // If we have a timer state and it's active, ensure Live Activity is shown
    if (_lastTimerState != null &&
        _lastTimerState!.isActive &&
        _lastTimerState!.currentSeconds > 0) {
      debugPrint(
          '⏰ Timer is active in background, ensuring Live Activity is shown');
      syncTimerState(_lastTimerState!);
    }
  }

  /// Called when app comes to foreground
  void _onAppWentToForeground() {
    debugPrint('📱 App came to foreground');

    // End Live Activity when app comes to foreground
    if (_liveActivityService != null) {
      debugPrint('📱 App in foreground, ending Live Activity');
      endLiveActivity();
    }
  }

  /// Store last timer state for background management
  void updateLastTimerState(TimerState timerState) {
    _lastTimerState = timerState;
  }

  /// Dispose resources
  Future<void> dispose() async {
    _fgbgSubscription?.cancel();
    if (_liveActivityService != null) {
      await _liveActivityService!.dispose();
      _liveActivityService = null;
    }
  }
}
