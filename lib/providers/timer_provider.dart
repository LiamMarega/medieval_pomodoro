import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/timer_state.dart';

part 'timer_provider.g.dart';

@riverpod
class TimerController extends _$TimerController {
  Timer? _timer;
  Timer? _volumeTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  static const double _maxVolume = 0.7;
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
    );
  }

  void _initializeAudio() async {
    try {
      await _audioPlayer.setAsset('assets/songs/medieval_lofi.mp3');
      await _audioPlayer.setLoopMode(LoopMode.all);
      await _audioPlayer.setVolume(0.0);
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }

  void startTimer() {
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
    _timer?.cancel();
    state = state.copyWith(isActive: false);

    if (state.isMusicPlaying) {
      _stopMusicWithFadeOut();
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void restartTimer() {
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
    final random = DateTime.now().millisecondsSinceEpoch % _motivationalMessages.length;
    state = state.copyWith(
      currentMotivationalMessage: _motivationalMessages[random],
    );
  }

  void toggleMusic() {
    state = state.copyWith(isMusicEnabled: !state.isMusicEnabled);

    if (!state.isMusicEnabled && state.isMusicPlaying) {
      _stopMusicWithFadeOut();
    }

    HapticFeedback.mediumImpact();
  }

  void _startMusicWithFadeIn() async {
    if (!state.isMusicEnabled) return;

    try {
      _volumeTimer?.cancel();
      final newVolume = _maxVolume;
      await _audioPlayer.setVolume(newVolume);
      await _audioPlayer.play();

      state = state.copyWith(
        isMusicPlaying: true,
        currentVolume: newVolume,
      );
    } catch (e) {
      debugPrint('Error starting music: $e');
    }
  }

  void _stopMusicWithFadeOut() async {
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
          }
        },
      );
    } catch (e) {
      debugPrint('Error stopping music: $e');
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
