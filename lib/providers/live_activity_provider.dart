import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import '../core/services/live_activity_service.dart';
import '../models/timer_state.dart';
import '../models/timer_mode.dart';

part 'live_activity_provider.g.dart';

@Riverpod(keepAlive: true)
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
        appGroupId: 'group.com.focusknight.app',
        urlScheme: 'focusknight',
        customActivityId: 'focus-knight-activity',
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

  /// Handle Live Activity actions from Dynamic Island with robust error handling
  void _handleLiveActivityAction(String action) {
    debugPrint('🎯 Handling Live Activity action: $action');
    
    try {
      // Handle different actions from the Live Activity
      switch (action.toLowerCase()) {
        case 'pause':
          debugPrint('⏸️ Pause action from Live Activity');
          // Action will be handled by timer_provider through handleLiveActivityAction
          break;
        case 'resume':
        case 'play':
          debugPrint('▶️ Resume action from Live Activity');
          // Action will be handled by timer_provider through handleLiveActivityAction
          break;
        case 'stop':
          debugPrint('⏹️ Stop action from Live Activity');
          // Action will be handled by timer_provider through handleLiveActivityAction
          break;
        default:
          debugPrint('❓ Unknown Live Activity action: $action');
      }
    } catch (e) {
      debugPrint('❌ Error handling Live Activity action: $e');
      // Silent failure - don't affect app functionality
    }
  }

  /// Sync timer state with Live Activity with robust error handling
  Future<void> syncTimerState(TimerState timerState) async {
    if (_liveActivityService == null) {
      debugPrint('⚠️ Live Activity service not initialized');
      return;
    }

    try {
      // Store the timer state for background sync
      _lastTimerState = timerState;
      
      // Check if Live Activities are available with timeout
      final isAvailable = await _liveActivityService!.isAvailable()
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
      
      if (!isAvailable) {
        debugPrint('⚠️ Live Activities not available on this device');
        return;
      }

      // Convert session type to PomodoroPhase
      PomodoroPhase phase;
      switch (timerState.currentMode) {
        case TimerMode.work:
          phase = PomodoroPhase.focus;
          break;
        case TimerMode.shortBreak:
          phase = PomodoroPhase.shortBreak;
          break;
        case TimerMode.longBreak:
          phase = PomodoroPhase.longBreak;
          break;
      }

      // Calculate end time based on current seconds remaining
      final endAt = DateTime.now().add(
        Duration(seconds: timerState.currentSeconds),
      );

      // Create snapshot with unique timestamp to avoid conflicts
      final snapshot = PomodoroSnapshot(
        taskName: '${timerState.currentMode.name} - Session ${timerState.sessionNumber}',
        phase: phase,
        endAt: endAt,
        isRunning: timerState.isActive,
      );

      // Sync with timeout to prevent blocking
      await _liveActivityService!.sync(snapshot)
          .timeout(const Duration(seconds: 3));
      
      debugPrint('✅ Timer state synced with Live Activity (${timerState.currentMode.name}, ${timerState.currentSeconds}s remaining)');
    } catch (e) {
      debugPrint('❌ Error syncing timer state: $e');
      // Attempt recovery by trying a simple patch instead of full sync
      _attemptRecoverySync(timerState);
    }
  }
  
  /// Attempt to recover from sync errors with a simpler approach
  Future<void> _attemptRecoverySync(TimerState timerState) async {
    try {
      debugPrint('🔄 Attempting Live Activity recovery sync...');
      await patchLiveActivity(
        isRunning: timerState.isActive,
        newEndAt: DateTime.now().add(Duration(seconds: timerState.currentSeconds)),
      );
      debugPrint('✅ Live Activity recovery sync successful');
    } catch (e) {
      debugPrint('❌ Live Activity recovery sync failed: $e');
      // Silent failure - don't affect timer functionality
    }
  }

  /// Update specific Live Activity fields with robust error handling
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
      // Check if we have any meaningful updates to make
      if (isRunning == null && newEndAt == null && phase == null && taskName == null) {
        debugPrint('⚠️ No Live Activity updates to apply');
        return;
      }
      
      // Apply patch with timeout to prevent blocking
      await _liveActivityService!.patch(
        isRunning: isRunning,
        newEndAt: newEndAt,
        phase: phase,
        taskName: taskName,
      ).timeout(const Duration(seconds: 2));
      
      debugPrint('✅ Live Activity patched successfully (running: $isRunning)');
    } catch (e) {
      debugPrint('❌ Error patching Live Activity: $e');
      // Silent failure - don't affect timer functionality
    }
  }

  /// End Live Activity with robust error handling
  Future<void> endLiveActivity() async {
    if (_liveActivityService == null) {
      debugPrint('⚠️ Live Activity service not initialized');
      return;
    }

    try {
      // End with timeout to prevent blocking
      await _liveActivityService!.end()
          .timeout(const Duration(seconds: 2));
      
      // Clear stored timer state
      _lastTimerState = null;
      
      debugPrint('✅ Live Activity ended successfully');
    } catch (e) {
      debugPrint('❌ Error ending Live Activity: $e');
      // Silent failure - don't affect timer functionality
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

  /// Called when app goes to background with robust error handling
  void _onAppWentToBackground() {
    debugPrint('📱 App went to background');
    _isAppInBackground = true;

    // Use microtask to avoid blocking the background transition
    Future.microtask(() async {
      try {
        // If we have a timer state and it's active, ensure Live Activity is shown
        if (_lastTimerState != null &&
            _lastTimerState!.isActive &&
            _lastTimerState!.currentSeconds > 0) {
          debugPrint(
            '⏰ Timer is active in background, ensuring Live Activity is shown',
          );
          await syncTimerState(_lastTimerState!);
        }
      } catch (e) {
        debugPrint('❌ Error handling background transition: $e');
        // Silent failure - don't affect app functionality
      }
    });
  }

  /// Called when app comes to foreground with robust error handling
  void _onAppWentToForeground() {
    debugPrint('📱 App came to foreground');
    _isAppInBackground = false;

    // Use microtask to avoid blocking the foreground transition
    Future.microtask(() async {
      try {
        // End Live Activity when app comes to foreground
        if (_liveActivityService != null) {
          debugPrint('📱 App in foreground, ending Live Activity');
          await endLiveActivity();
        }
      } catch (e) {
        debugPrint('❌ Error handling foreground transition: $e');
        // Silent failure - don't affect app functionality
      }
    });
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
