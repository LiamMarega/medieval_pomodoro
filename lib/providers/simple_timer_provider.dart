import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'settings_provider.dart';
import '../models/timer_state.dart';
import '../models/timer_mode.dart';
import '../core/services/notification_service.dart';
import 'live_activity_provider.dart';
import 'rewards_provider.dart';

part 'simple_timer_provider.g.dart';

@Riverpod(keepAlive: true)
class SimpleTimerController extends _$SimpleTimerController {
  Timer? _timer;
  Timer? _volumeTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const double _maxVolume = 1;
  static const double _volumeStep = 0.05;
  static const int _volumeStepDuration = 500;

  @override
  TimerState build() {
    _initializeAudio();
    
    // Listen to settings changes
    ref.listen(settingsControllerProvider, (previous, next) {
      if (next.hasValue) {
        final settings = next.value!;
        updateSettings(
          workDurationMinutes: settings.workDurationMinutes,
          shortBreakMinutes: settings.shortBreakMinutes,
          longBreakMinutes: settings.longBreakMinutes,
          isMusicEnabled: settings.isMusicEnabled,
          isSoundEnabled: settings.isSoundEnabled,
        );
      }
    });

    final settings = ref.read(settingsControllerProvider).value;

    return TimerState(
      currentMotivationalMessage: "knight_quotes.0",
      isMusicEnabled: settings?.isMusicEnabled ?? true,
      isSoundEnabled: settings?.isSoundEnabled ?? true,
      workDurationMinutes: settings?.workDurationMinutes ?? 25,
      shortBreakMinutes: settings?.shortBreakMinutes ?? 5,
      longBreakMinutes: settings?.longBreakMinutes ?? 30,
    );
  }

  void _initializeAudio() async {
    debugPrint('SimpleTimerController._initializeAudio() called');
    try {
      await _audioPlayer.setAsset('assets/songs/medieval_lofi.mp3');

      await _audioPlayer.setLoopMode(LoopMode.all);

      await _audioPlayer.setVolume(0.0);
    } catch (e) {
      debugPrint('Error initializing simple audio: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  void startTimer() {
    debugPrint('SimpleTimerController.startTimer() called');
    if (_timer?.isActive ?? false) return;

    state = state.copyWith(isActive: true);

    if (state.isMusicEnabled) {
      _startMusicWithFadeIn();
    }

    // Sync with Live Activity
    ref.read(liveActivityControllerProvider.notifier).syncTimerState(state);

    // Update local notification
    NotificationService().updateTimerState(
        isActive: true,
        currentSeconds: state.remaining.inSeconds,
        sessionType: state.currentMode.name, // or a better readable name
        motivationalMessage: state.currentMotivationalMessage);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.currentSeconds > 0) {
        final newSeconds = state.currentSeconds - 1;

        state = state.copyWith(remaining: Duration(seconds: newSeconds));

        if (newSeconds % 300 == 0) {
          _updateMotivationalMessage();
        }

        // Update Live Activity periodically to save battery/resources
        // Every 30s usually, or on significant changes.
        // For simplicity and smoother updates in dynamic island, maybe every 1-5s?
        // Let's do every 1s for now as requested for correct operation,
        // but `LiveActivityProvider` handles throttling/patching if needed.
        if (newSeconds % 1 == 0) {
          ref
              .read(liveActivityControllerProvider.notifier)
              .syncTimerState(state);
        }

        // Update notification service state (it manages its own update frequency)
        NotificationService().updateTimerState(
            isActive: true,
            currentSeconds: newSeconds,
            sessionType: _getReadableSessionType(state.currentMode),
            motivationalMessage: state.currentMotivationalMessage);
      } else {
        _completeSession();
      }
    });
  }

  void pauseTimer() {
    debugPrint('SimpleTimerController.pauseTimer() called');
    _timer?.cancel();
    state = state.copyWith(isActive: false);

    if (state.isMusicPlaying) {
      _stopMusicWithFadeOut();
    }

    // Update Live Activity (Paused)
    ref.read(liveActivityControllerProvider.notifier).syncTimerState(state);

    // Update Notification Service
    NotificationService().updateTimerState(
        isActive: false,
        currentSeconds: state.currentSeconds,
        sessionType: _getReadableSessionType(state.currentMode),
        motivationalMessage: state.currentMotivationalMessage);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void restartTimer() {
    debugPrint('SimpleTimerController.restartTimer() called');
    _timer?.cancel();
    state = state.copyWith(
      isActive: false,
      remaining: Duration(seconds: state.totalSeconds),
    );

    if (state.isMusicPlaying) {
      _stopMusicWithFadeOut();
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _updateMotivationalMessage();

    // Update Live Activity (Reset)
    ref.read(liveActivityControllerProvider.notifier).endLiveActivity();

    // Clear Notification
    NotificationService().updateTimerState(
        isActive: false,
        currentSeconds: state.remaining.inSeconds,
        sessionType: _getReadableSessionType(state.currentMode),
        motivationalMessage: state.currentMotivationalMessage);

    HapticFeedback.mediumImpact();
  }

  void _completeSession() {
    debugPrint('SimpleTimerController._completeSession() called');
    _timer?.cancel();
    state = state.copyWith(
      isActive: false,
      sessionNumber: state.sessionNumber + 1,
    );

    if (state.isMusicPlaying) {
      _stopMusicWithFadeOut();
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _determineNextSession();

    // End Live Activity for the completed session
    ref.read(liveActivityControllerProvider.notifier).endLiveActivity();

    // Play Medieval Haptics
    if (state.currentMode.isWork) {
      // Break started (transition from work)
      _playTransitionHaptics(true);
      // Award Gold Coins for hard work!
      ref.read(rewardsControllerProvider.notifier).addCoins(10);
    } else {
      // Work started (transition from break)
      _playTransitionHaptics(false);
      // Award smaller amount for completing a break? Maybe not.
      // ref.read(rewardsControllerProvider.notifier).addCoins(5);
    }
  }

  void _determineNextSession() {
    String newSessionType;
    int newTotalSeconds;

    if (state.currentMode.isWork) {
      if (state.sessionNumber % 4 == 0) {
        newSessionType = 'Long Break';
        newTotalSeconds = state.longBreakMinutes * 60;
      } else {
        newSessionType = 'Short Break';
        newTotalSeconds = state.shortBreakMinutes * 60;
      }
    } else {
      newSessionType = 'Work';
      newTotalSeconds = state.workDurationMinutes * 60;
    }

    // Convertir el string a TimerMode
    TimerMode newMode;
    switch (newSessionType) {
      case 'Work':
        newMode = TimerMode.work;
        break;
      case 'Short Break':
        newMode = TimerMode.shortBreak;
        break;
      case 'Long Break':
        newMode = TimerMode.longBreak;
        break;
      default:
        newMode = TimerMode.work;
    }

    state = state.copyWith(
      currentMode: newMode,
      remaining: Duration(seconds: newTotalSeconds),
    );
  }

  void _updateMotivationalMessage() {
    int maxMessages = 99;
    String prefix = "knight_quotes";

    if (state.currentMode.isBreak) {
      maxMessages = 8;
      prefix = "knight_break_quotes";
    }

    final random = DateTime.now().millisecondsSinceEpoch % maxMessages;
    state = state.copyWith(
      currentMotivationalMessage: "$prefix.$random",
    );
  }

  void toggleMusic() {
    debugPrint('SimpleTimerController.toggleMusic() called');
    state = state.copyWith(isMusicEnabled: !state.isMusicEnabled);

    if (!state.isMusicEnabled && state.isMusicPlaying) {
      _stopMusicWithFadeOut();
    }

    debugPrint('Music enabled set to: ${state.isMusicEnabled}');
    HapticFeedback.mediumImpact();
  }

  void _startMusicWithFadeIn() async {
    debugPrint('SimpleTimerController._startMusicWithFadeIn() called');
    if (!state.isMusicEnabled) return;

    try {
      _volumeTimer?.cancel();

      debugPrint('Starting playback with just_audio...');
      await _audioPlayer.setVolume(_maxVolume);
      await _audioPlayer.play();

      state = state.copyWith(
        isMusicPlaying: true,
        currentVolume: _maxVolume,
      );

      debugPrint('Simple music started successfully');
    } catch (e) {
      debugPrint('Error starting simple music: $e');
    }
  }

  void _stopMusicWithFadeOut() async {
    debugPrint('SimpleTimerController._stopMusicWithFadeOut() called');
    try {
      _volumeTimer?.cancel();

      _volumeTimer = Timer.periodic(
        Duration(milliseconds: _volumeStepDuration),
        (timer) async {
          if (state.currentVolume > 0.0) {
            final newVolume = state.currentVolume - _volumeStep;
            await _audioPlayer.setVolume(newVolume);
            state = state.copyWith(currentVolume: newVolume);
          } else {
            timer.cancel();
            await _audioPlayer.pause();
            state = state.copyWith(isMusicPlaying: false);
            debugPrint('Simple music stopped successfully');
          }
        },
      );
    } catch (e) {
      debugPrint('Error stopping simple music: $e');
    }
  }

  void updateSettings({
    required int workDurationMinutes,
    required int shortBreakMinutes,
    required int longBreakMinutes,
    required bool isMusicEnabled,
    bool? isSoundEnabled,
  }) {
    state = state.copyWith(
      workDurationMinutes: workDurationMinutes,
      shortBreakMinutes: shortBreakMinutes,
      longBreakMinutes: longBreakMinutes,
      isMusicEnabled: isMusicEnabled,
      isSoundEnabled: isSoundEnabled ?? state.isSoundEnabled,
    );

    debugPrint('Music enabled set to: $isMusicEnabled');

    if (state.currentMode.isWork) {
      final newTotalSeconds = workDurationMinutes * 60;
      state = state.copyWith(
        remaining: Duration(seconds: newTotalSeconds),
      );
    }
  }

  void dispose() {
    _timer?.cancel();
    _volumeTimer?.cancel();
    _audioPlayer.dispose();
  }

  String _getReadableSessionType(TimerMode mode) {
    switch (mode) {
      case TimerMode.work:
        return 'Work';
      case TimerMode.shortBreak:
        return 'Short Break';
      case TimerMode.longBreak:
        return 'Long Break';
      default:
        return 'Focus';
    }
  }

  void _playTransitionHaptics(bool toBreak) {
    if (toBreak) {
      // Heavy sequence for earning a break
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200),
          () => HapticFeedback.heavyImpact());
      Future.delayed(const Duration(milliseconds: 400),
          () => HapticFeedback.mediumImpact());
    } else {
      // Sharp sequence for back to work
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 150),
          () => HapticFeedback.heavyImpact());
    }
  }
}
