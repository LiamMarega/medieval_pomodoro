import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/timer_state.dart';
import '../models/timer_mode.dart';

part 'simple_timer_provider.g.dart';

@Riverpod(keepAlive: true)
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
    "Steel your resolve, for every minute counts.",
    "Let your focus shine brighter than your armor.",
    "Victory favors the diligent and the disciplined.",
    "A true knight conquers distraction with purpose.",
    "Forge ahead, for greatness is earned, not given.",
    "The lance of effort pierces the shield of doubt.",
    "Every tick of the clock is a step toward glory.",
    "Let your actions echo through the halls of time.",
    "A focused mind is sharper than any blade.",
    "Rise above the noise, champion of your quest.",
    "The bravest battles are fought within.",
    "Let perseverance be your trusted steed.",
    "With every task, you strengthen your legacy.",
    "The banners of success are raised by the persistent.",
    "A knight’s journey is measured in moments of focus.",
    "Let your will be as unyielding as your shield.",
    "The greatest victories are won in silence and effort.",
    "Stay the course, for the path is yours to claim.",
    "Discipline is the armor that guards your dreams.",
    "Let your focus be the torch that lights your way.",
    "Every effort is a brick in your castle of achievement.",
    "The quest for greatness begins with a single task.",
    "Let your mind be as steady as your sword.",
    "A true knight finds strength in routine.",
    "The seeds of success are sown in focused hours.",
    "Let your ambition be as boundless as the horizon.",
    "The strongest armor is forged in the fires of discipline.",
    "A focused knight fears no challenge.",
    "Let your purpose guide you through the fog of distraction.",
    "Every moment of focus is a victory in itself.",
    "The path to mastery is paved with small wins.",
    "Let your determination be your guiding star.",
    "A knight’s honor is built on daily effort.",
    "The greatest quests are completed one step at a time.",
    "Let your focus be unwavering, your spirit unbreakable.",
    "A disciplined mind is a knight’s greatest ally.",
    "The journey to greatness is a marathon, not a sprint.",
    "Let your resolve be as firm as castle walls.",
    "Every focused minute brings you closer to your goal.",
    "A knight’s legacy is written in moments of effort.",
    "Let your actions speak louder than your words.",
    "The true test of a knight is persistence.",
    "Let your focus carve a path through any obstacle.",
    "A steadfast heart conquers all distractions.",
    "The greatest treasures are found by those who persist.",
    "Let your discipline shine brighter than your sword.",
    "A knight’s strength lies in unwavering focus.",
    "The road to victory is traveled by the diligent.",
    "Let your mind be a fortress against distraction.",
    "Every quest is won by those who never yield.",
    "A focused knight is unstoppable.",
    "Let your dreams be fueled by daily effort.",
    "The banners of triumph are raised by the persistent.",
    "Let your focus be the key to every locked door.",
    "A knight’s courage is shown in moments of discipline.",
    "The greatest battles are won in the mind.",
    "Let your ambition be your compass.",
    "Every moment of focus is a step toward greatness.",
    "A true knight never wavers in pursuit of their quest.",
    "Let your discipline be your shield.",
    "The path to mastery is walked with steady steps.",
    "Let your focus be as sharp as your blade.",
    "A knight’s journey is defined by perseverance.",
    "The greatest victories are earned, not given.",
    "Let your resolve be your armor.",
    "Every task completed is a victory for the knight within.",
    "A focused mind is the mark of a true champion.",
    "Let your actions build the legacy you seek.",
    "The quest for excellence is never-ending.",
    "Let your focus lead you to new heights.",
    "A knight’s honor is found in daily effort.",
    "The strongest warriors are those who persist.",
    "Let your discipline guide you through every challenge.",
    "Every moment of focus brings you closer to your dreams.",
    "A true knight rises above distraction.",
    "Let your determination be your sword and shield.",
    "The path to greatness is paved with discipline.",
    "Let your focus be the light in the darkness.",
    "A knight’s strength is measured in moments of effort.",
    "The greatest achievements begin with a single step.",
    "Let your resolve carry you through every trial.",
    "Every focused minute is a victory on your quest.",
    "A disciplined mind conquers all obstacles.",
    "Let your ambition drive you forward.",
    "The journey to mastery is a noble quest.",
    "Let your focus be your greatest weapon.",
    "A knight’s legacy is built on perseverance.",
    "The banners of success are raised by the steadfast.",
    "Let your discipline be the foundation of your achievements.",
    "Every quest is won by those who never give up.",
    "A focused knight is a victorious knight.",
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

    if (state.currentMode.isWork) {
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
