import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/timer_state.dart';

part 'simple_timer_provider.g.dart';

@riverpod
class SimpleTimerController extends _$SimpleTimerController {
  Timer? _timer;
  Timer? _volumeTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const double _maxVolume = 1;
  static const double _volumeStep = 0.05;
  static const int _volumeStepDuration = 500;

  final List<String> _motivationalMessages = [
    "A knight's focus is their greatest weapon!",
    "Every quest begins with a single step forward.",
    "The castle of success is built one stone at a time.",
    "Honor your commitment to excellence, brave warrior!",
    "In the realm of productivity, consistency reigns supreme.",
    "Your dedication today forges tomorrow's victories.",
    "Like a steadfast knight, persist through challenges.",
    "The path to mastery requires unwavering discipline.",
  ];

  @override
  TimerState build() {
    _initializeAudio();
    return const TimerState(
      currentMotivationalMessage: "A knight's focus is their greatest weapon!",
      isMusicEnabled: true, // Music always ON by default
    );
  }

  void _initializeAudio() async {
    debugPrint('SimpleTimerController._initializeAudio() called');
    try {
      debugPrint('Setting asset: assets/songs/medieval_lofi.mp3');
      await _audioPlayer.setAsset('assets/songs/medieval_lofi.mp3');
      debugPrint('Asset set successfully');

      debugPrint('Setting loop mode to all');
      await _audioPlayer.setLoopMode(LoopMode.all);
      debugPrint('Loop mode set successfully');

      debugPrint('Setting volume to 0.0');
      await _audioPlayer.setVolume(0.0);
      debugPrint('Volume set successfully');

      debugPrint('Simple audio initialized successfully');
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

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.currentSeconds > 0) {
        final newSeconds = state.currentSeconds - 1;

        state = state.copyWith(currentSeconds: newSeconds);

        if (newSeconds % 300 == 0) {
          _updateMotivationalMessage();
        }
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

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void restartTimer() {
    debugPrint('SimpleTimerController.restartTimer() called');
    _timer?.cancel();
    state = state.copyWith(
      isActive: false,
      currentSeconds: state.totalSeconds,
    );

    if (state.isMusicPlaying) {
      _stopMusicWithFadeOut();
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _updateMotivationalMessage();
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
    HapticFeedback.heavyImpact();
  }

  void _determineNextSession() {
    String newSessionType;
    int newTotalSeconds;

    if (state.sessionType == 'Work') {
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

    state = state.copyWith(
      sessionType: newSessionType,
      totalSeconds: newTotalSeconds,
      currentSeconds: newTotalSeconds,
    );
  }

  void _updateMotivationalMessage() {
    final random =
        DateTime.now().millisecondsSinceEpoch % _motivationalMessages.length;
    state = state.copyWith(
      currentMotivationalMessage: _motivationalMessages[random],
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
  }) {
    state = state.copyWith(
      workDurationMinutes: workDurationMinutes,
      shortBreakMinutes: shortBreakMinutes,
      longBreakMinutes: longBreakMinutes,
      isMusicEnabled: isMusicEnabled,
    );

    debugPrint('Music enabled set to: $isMusicEnabled');

    if (state.sessionType == 'Work') {
      final newTotalSeconds = workDurationMinutes * 60;
      state = state.copyWith(
        totalSeconds: newTotalSeconds,
        currentSeconds: newTotalSeconds,
      );
    }
  }

  void dispose() {
    _timer?.cancel();
    _volumeTimer?.cancel();
    _audioPlayer.dispose();
  }
}
