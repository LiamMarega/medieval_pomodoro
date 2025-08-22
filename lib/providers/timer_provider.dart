import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/timer_state.dart';
import '../models/timer_mode.dart';
// Importa el nuevo servicio de audio
import '../services/audio_service_manager.dart';
import 'live_activity_provider.dart';
import 'settings_provider.dart';

part 'timer_provider.g.dart';

@Riverpod(keepAlive: true)
class TimerController extends _$TimerController {
  Timer? _timer;
  PlaylistAudioService? _audioService;

  @override
  TimerState build() {
    _initializeAudio();

    // Get settings from settings provider
    final settings = ref.watch(settingsControllerProvider);

    // Use settings if available, otherwise use defaults
    final workDuration = settings.when(
      data: (data) => data.workDurationMinutes,
      loading: () => 25,
      error: (_, __) => 25,
    );

    final shortBreakDuration = settings.when(
      data: (data) => data.shortBreakMinutes,
      loading: () => 5,
      error: (_, __) => 5,
    );

    final longBreakDuration = settings.when(
      data: (data) => data.longBreakMinutes,
      loading: () => 30,
      error: (_, __) => 30,
    );

    final isMusicEnabled = settings.when(
      data: (data) => data.isMusicEnabled,
      loading: () => true,
      error: (_, __) => true,
    );

    // Crear configuración inicial del modo de trabajo
    final initialConfig = TimerModeConfig.getWorkConfig(
      durationMinutes: workDuration,
      motivationalMessage: "A knight's focus is their greatest weapon!",
    );

    return TimerState(
      currentMotivationalMessage: initialConfig.motivationalMessage,
      isMusicEnabled: isMusicEnabled,
      currentMode: initialConfig.mode,
      currentAnimation: initialConfig.animationType,
      workDurationMinutes: workDuration,
      shortBreakMinutes: shortBreakDuration,
      longBreakMinutes: longBreakDuration,
      totalSeconds: workDuration * 60,
      currentSeconds: workDuration * 60,
    );
  }

  void _initializeAudio() async {
    try {
      debugPrint('🚀 Initializing audio in timer provider...');
      _audioService = PlaylistAudioService.instance;
      await _audioService!.initialize();
      debugPrint('✅ Audio initialized successfully in timer provider');

      // Validar playlist después de inicializar
      final isValid = await _audioService!.validatePlaylist();
      if (!isValid) {
        debugPrint('⚠️ Warning: Some songs in playlist may not be available');
      }
    } catch (e) {
      debugPrint('❌ Error initializing audio in timer provider: $e');
    }
  }

  void startTimer() {
    debugPrint('▶️ Starting timer...');
    if (_timer?.isActive ?? false) {
      debugPrint('⚠️ Timer is already active');
      return;
    }

    state = state.copyWith(isActive: true);

    // Sync with Live Activity
    _syncWithLiveActivity();

    // Iniciar música si está habilitada
    if (state.isMusicEnabled) {
      debugPrint('🎵 Starting music...');
      _startMusic();
    } else {
      debugPrint('🔇 Music is disabled, not starting');
    }

    // Configurar modo inmersivo
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Iniciar el timer del pomodoro
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.currentSeconds > 0) {
        final newSeconds = state.currentSeconds - 1;
        state = state.copyWith(currentSeconds: newSeconds);

        // Update Live Activity every 30 seconds to avoid too frequent updates
        if (newSeconds % 30 == 0) {
          _patchLiveActivity(isRunning: true);
        }

        // Actualizar mensaje motivacional cada 5 minutos (300 segundos)
        if (newSeconds % 300 == 0) {
          _updateMotivationalMessage();
        }
      } else {
        _completeSession();
      }
    });

    debugPrint('✅ Timer started successfully');
  }

  void pauseTimer() {
    debugPrint('⏸️ Pausing timer...');
    debugPrint(
        'Current music state - isPlaying: ${_audioService?.isPlaying ?? false}, isEnabled: ${state.isMusicEnabled}');

    // Cancelar el timer
    _timer?.cancel();
    state = state.copyWith(isActive: false);

    // Update Live Activity
    _patchLiveActivity(isRunning: false);

    // Detener música si está reproduciéndose
    if (state.isMusicEnabled && (_audioService?.isPlaying ?? false)) {
      debugPrint('🔇 Stopping music...');
      _stopMusic();
    } else {
      debugPrint('🔇 Music is not playing or is disabled, skipping stop');
    }

    // Salir del modo inmersivo
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    debugPrint('✅ Timer paused successfully');
  }

  void restartTimer() {
    debugPrint('🔄 Restarting timer...');

    _timer?.cancel();
    state = state.copyWith(
      isActive: false,
      currentSeconds: state.totalSeconds,
    );

    // Update Live Activity
    _patchLiveActivity(isRunning: false);

    // Detener música si está reproduciéndose
    if (_audioService?.isPlaying ?? false) {
      debugPrint('🔇 Stopping music for restart...');
      _stopMusic();
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _updateMotivationalMessage();
    HapticFeedback.mediumImpact();

    debugPrint('✅ Timer restarted successfully');
  }

  void _completeSession() {
    debugPrint('🏁 Completing session...');

    final completedSessionType = state.currentMode;

    _timer?.cancel();
    state = state.copyWith(
      isActive: false,
      sessionNumber: state.sessionNumber + 1,
    );

    // End Live Activity
    _endLiveActivity();

    // Detener música
    if (_audioService?.isPlaying ?? false) {
      debugPrint('🔇 Stopping music for session completion...');
      _stopMusic();
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Play completion sound and haptic feedback
    _playSessionCompletionFeedback();

    // Determine next session and auto-start
    _determineNextSession();

    // Auto-start next session after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      startTimer();
    });

    debugPrint('✅ Session completed successfully: $completedSessionType');
  }

  void _playSessionCompletionFeedback() {
    // Play completion sound
    SystemSound.play(SystemSoundType.alert);

    // Haptic feedback based on session type
    if (state.currentMode.isWork) {
      // Work session completed - 2 vibrations
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.heavyImpact();
      });
    } else {
      // Break session completed - 1 vibration
      HapticFeedback.mediumImpact();
    }
  }

  void _determineNextSession() {
    TimerModeConfig newConfig;

    if (state.currentMode.isWork) {
      if (state.sessionNumber % 4 == 0) {
        newConfig = TimerModeConfig.getLongBreakConfig(
          durationMinutes: state.longBreakMinutes,
        );
      } else {
        newConfig = TimerModeConfig.getShortBreakConfig(
          durationMinutes: state.shortBreakMinutes,
        );
      }
    } else {
      newConfig = TimerModeConfig.getWorkConfig(
        durationMinutes: state.workDurationMinutes,
      );
    }

    // Play session change sound and haptic feedback
    _playSessionChangeFeedback(newConfig.mode);

    state = state.copyWith(
      currentMode: newConfig.mode,
      totalSeconds: newConfig.durationMinutes * 60,
      currentSeconds: newConfig.durationMinutes * 60,
      currentMotivationalMessage: newConfig.motivationalMessage,
      currentAnimation: newConfig.animationType,
    );

    debugPrint(
        '📋 Next session determined: ${newConfig.mode.displayName} (${newConfig.durationMinutes * 60}s)');
  }

  void _playSessionChangeFeedback(TimerMode newMode) {
    // Play session change sound
    SystemSound.play(SystemSoundType.click);

    // Haptic feedback based on new session type
    if (newMode.isWork) {
      // Changing to work - 2 vibrations
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.heavyImpact();
      });
    } else {
      // Changing to break - 1 vibration
      HapticFeedback.mediumImpact();
    }
  }

  void _updateMotivationalMessage() {
    TimerModeConfig config;

    if (state.currentMode.isWork) {
      config = TimerModeConfig.getWorkConfig(
        durationMinutes: state.workDurationMinutes,
      );
    } else {
      config = TimerModeConfig.getShortBreakConfig(
        durationMinutes: state.shortBreakMinutes,
      );
    }

    state = state.copyWith(
      currentMotivationalMessage: config.motivationalMessage,
      currentAnimation: config.animationType,
    );

    debugPrint(
        '💭 Motivational message updated: ${config.motivationalMessage}');
  }

  void toggleMusic() {
    debugPrint('🎵 Toggling music...');

    final newMusicEnabled = !state.isMusicEnabled;
    state = state.copyWith(isMusicEnabled: newMusicEnabled);

    // Actualizar el servicio de audio
    _audioService?.setMusicEnabled(newMusicEnabled);

    // Si se deshabilitó la música y está reproduciéndose, detenerla
    if (!newMusicEnabled && (_audioService?.isPlaying ?? false)) {
      debugPrint('🔇 Music disabled, stopping playback...');
      _stopMusic();
    }

    HapticFeedback.mediumImpact();
    debugPrint('✅ Music toggled: $newMusicEnabled');
  }

  void _startMusic() async {
    debugPrint('🎵 _startMusic() called');

    if (!state.isMusicEnabled) {
      debugPrint('🔇 Music is not enabled, skipping start');
      return;
    }

    if (_audioService == null || !_audioService!.isInitialized) {
      debugPrint('❌ Audio service not initialized in _startMusic()');
      return;
    }

    try {
      await _audioService!.play();
      state = state.copyWith(isMusicPlaying: true);
      debugPrint('✅ Music started successfully - isMusicPlaying set to true');
    } catch (e) {
      debugPrint('❌ Error starting music: $e');
    }
  }

  void _stopMusic() async {
    debugPrint('🔇 _stopMusic() called');

    if (_audioService == null || !_audioService!.isInitialized) {
      debugPrint('❌ Audio service not initialized in _stopMusic()');
      return;
    }

    try {
      await _audioService!.pause();
      state = state.copyWith(isMusicPlaying: false);
      debugPrint('✅ Music stopped successfully - isMusicPlaying set to false');
    } catch (e) {
      debugPrint('❌ Error stopping music: $e');
    }
  }

  void updateSettings({
    required int workDurationMinutes,
    required int shortBreakMinutes,
    required int longBreakMinutes,
    required bool isMusicEnabled,
  }) {
    debugPrint('⚙️ Updating settings...');

    // Update settings in the settings provider (this will persist to local storage)
    ref.read(settingsControllerProvider.notifier).updateSettings(
          workDurationMinutes: workDurationMinutes,
          shortBreakMinutes: shortBreakMinutes,
          longBreakMinutes: longBreakMinutes,
          isMusicEnabled: isMusicEnabled,
        );

    // Update local state for immediate UI responsiveness
    state = state.copyWith(
      workDurationMinutes: workDurationMinutes,
      shortBreakMinutes: shortBreakMinutes,
      longBreakMinutes: longBreakMinutes,
      isMusicEnabled: isMusicEnabled,
    );

    // Don't change music state when updating settings to prevent stopping music
    // The audio provider will handle music state separately

    // Si estamos en una sesión de trabajo, actualizar el tiempo total
    if (state.currentMode.isWork) {
      final newTotalSeconds = workDurationMinutes * 60;
      state = state.copyWith(
        totalSeconds: newTotalSeconds,
        currentSeconds: newTotalSeconds,
      );
    }

    debugPrint('✅ Settings updated successfully');
  }

  // Métodos adicionales para controlar la playlist
  void nextSong() {
    debugPrint('⏭️ Skipping to next song...');
    _audioService?.nextSong();
    HapticFeedback.lightImpact();
  }

  void previousSong() {
    debugPrint('⏮️ Skipping to previous song...');
    _audioService?.previousSong();
    HapticFeedback.lightImpact();
  }

  void setMusicVolume(double volume) {
    debugPrint('🔊 Setting music volume to: ${(volume * 100).round()}%');
    _audioService?.setVolume(volume);
  }

  // Getters para información de la playlist
  String get currentSongTitle =>
      _audioService?.currentSongTitle ?? 'Medieval Lofi Music';
  List<String> get playlistInfo => _audioService?.getPlaylistInfo() ?? [];
  int get currentSongIndex => _audioService?.currentIndex ?? 0;
  Duration get currentPosition =>
      _audioService?.currentPosition ?? Duration.zero;
  Duration get totalDuration => _audioService?.totalDuration ?? Duration.zero;

  // Live Activity integration methods
  void _syncWithLiveActivity() {
    // Get the Live Activity provider and sync the current state
    final liveActivityProvider =
        ref.read(liveActivityControllerProvider.notifier);

    // Debug Live Activity status first
    liveActivityProvider.debugLiveActivityStatus();

    // Then sync the state
    liveActivityProvider.syncTimerState(state);
    liveActivityProvider.updateLastTimerState(state);
  }

  void _patchLiveActivity({bool? isRunning, DateTime? newEndAt}) {
    // Get the Live Activity provider and patch specific fields
    final liveActivityProvider =
        ref.read(liveActivityControllerProvider.notifier);
    liveActivityProvider.patchLiveActivity(
      isRunning: isRunning,
      newEndAt: newEndAt,
    );
  }

  void _endLiveActivity() {
    // Get the Live Activity provider and end the activity
    final liveActivityProvider =
        ref.read(liveActivityControllerProvider.notifier);
    liveActivityProvider.endLiveActivity();
  }

  // Handle Live Activity actions from Dynamic Island
  void handleLiveActivityAction(String action) {
    switch (action) {
      case 'pause':
        pauseTimer();
        break;
      case 'resume':
        startTimer();
        break;
      case 'stop':
        restartTimer();
        break;
      default:
        debugPrint('⚠️ Unknown Live Activity action: $action');
    }
  }
}
