import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
