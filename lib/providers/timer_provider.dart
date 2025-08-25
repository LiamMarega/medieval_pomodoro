import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/timer_state.dart';
import '../models/timer_mode.dart';
// Importa el nuevo servicio de audio
import '../services/audio_service_manager.dart';
import '../core/services/live_activity_service.dart';
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
    _setupSettingsListener();
    _loadInitialSettings();

    // Use default settings for initial build
    const workDuration = 25;
    const shortBreakDuration = 5;
    const longBreakDuration = 30;
    const isMusicEnabled = true;

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

  void _loadInitialSettings() {
    // Load initial settings asynchronously without blocking the build
    Future.microtask(() {
      final settings = ref.read(settingsControllerProvider);
      settings.when(
        data: (data) {
          // Update state with loaded settings while preserving music state
          state = state.copyWith(
            workDurationMinutes: data.workDurationMinutes,
            shortBreakMinutes: data.shortBreakMinutes,
            longBreakMinutes: data.longBreakMinutes,
            isMusicEnabled: data.isMusicEnabled,
          );

          // Update total time if in work session
          if (state.currentMode.isWork) {
            final newTotalSeconds = data.workDurationMinutes * 60;
            state = state.copyWith(
              totalSeconds: newTotalSeconds,
              currentSeconds: newTotalSeconds,
            );
          }

          debugPrint('⚙️ Initial settings loaded successfully');
        },
        loading: () => debugPrint('⏳ Loading initial settings...'),
        error: (error, stack) => debugPrint('❌ Error loading initial settings: $error'),
      );
    });
  }

  void _setupSettingsListener() {
    // Listen to settings changes without rebuilding the entire provider
    ref.listen(settingsControllerProvider, (previous, next) {
      next.when(
        data: (settings) {
          // Preserve current music playing state
          final currentMusicPlaying = state.isMusicPlaying;
          
          // Update state with new settings while preserving music state
          state = state.copyWith(
            workDurationMinutes: settings.workDurationMinutes,
            shortBreakMinutes: settings.shortBreakMinutes,
            longBreakMinutes: settings.longBreakMinutes,
            isMusicEnabled: settings.isMusicEnabled,
            isMusicPlaying: currentMusicPlaying, // Preserve music playing state
          );

          // Update audio service music enabled state without stopping playback
          _audioService?.setMusicEnabled(settings.isMusicEnabled);

          // If we're in a work session, update the total time
          if (state.currentMode.isWork) {
            final newTotalSeconds = settings.workDurationMinutes * 60;
            state = state.copyWith(
              totalSeconds: newTotalSeconds,
              currentSeconds: newTotalSeconds,
            );
          }

          debugPrint('⚙️ Settings updated via listener - Music state preserved');
        },
        loading: () => debugPrint('⏳ Settings loading...'),
        error: (error, stack) => debugPrint('❌ Settings error: $error'),
      );
    });
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

    // Sync with Live Activity (non-blocking)
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

        // Update Live Activity with optimized frequency for better real-time experience
        // Update every 5 seconds for the first 30 seconds, every 15 seconds for the first 5 minutes, then every 30 seconds
        final shouldUpdateLiveActivity = newSeconds <= 30 
            ? (newSeconds % 5 == 0) 
            : newSeconds <= 300
                ? (newSeconds % 15 == 0)
                : (newSeconds % 30 == 0);
            
        if (shouldUpdateLiveActivity || newSeconds <= 5) {
           // Convert current mode to PomodoroPhase for Live Activity
           PomodoroPhase phase;
           switch (state.currentMode) {
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
           
           _patchLiveActivity(
             isRunning: true,
             newEndAt: DateTime.now().add(Duration(seconds: newSeconds)),
             phase: phase,
             taskName: '${state.currentMode.name} - Session ${state.sessionNumber}',
           );
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

    // Update Live Activity with pause state (non-blocking)
    // Convert current mode to PomodoroPhase for Live Activity
    PomodoroPhase phase;
    switch (state.currentMode) {
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
    
    _patchLiveActivity(
      isRunning: false,
      newEndAt: DateTime.now().add(Duration(seconds: state.currentSeconds)),
      phase: phase,
      taskName: '${state.currentMode.name} - Session ${state.sessionNumber} (Paused)',
    );

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

  void resumeTimer() {
    debugPrint('▶️ Resuming timer...');
    if (_timer?.isActive ?? false) {
      debugPrint('⚠️ Timer is already active');
      return;
    }

    if (state.currentSeconds <= 0) {
      debugPrint('⚠️ Cannot resume timer with 0 seconds remaining');
      return;
    }

    state = state.copyWith(isActive: true);

    // Sync with Live Activity (non-blocking)
    _patchLiveActivity(
      isRunning: true,
      newEndAt: DateTime.now().add(Duration(seconds: state.currentSeconds)),
    );

    // Iniciar música si está habilitada
    if (state.isMusicEnabled) {
      debugPrint('🎵 Resuming music...');
      _startMusic();
    }

    // Configurar modo inmersivo
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Reanudar el timer del pomodoro
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.currentSeconds > 0) {
        final newSeconds = state.currentSeconds - 1;
        state = state.copyWith(currentSeconds: newSeconds);

        // Update Live Activity with optimized frequency for better real-time experience
         final shouldUpdateLiveActivity = newSeconds <= 30 
             ? (newSeconds % 5 == 0) 
             : newSeconds <= 300
                 ? (newSeconds % 15 == 0)
                 : (newSeconds % 30 == 0);
             
         if (shouldUpdateLiveActivity || newSeconds <= 5) {
           // Convert current mode to PomodoroPhase for Live Activity
           PomodoroPhase phase;
           switch (state.currentMode) {
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
           
           _patchLiveActivity(
             isRunning: true,
             newEndAt: DateTime.now().add(Duration(seconds: newSeconds)),
             phase: phase,
             taskName: '${state.currentMode.name} - Session ${state.sessionNumber}',
           );
         }

        // Actualizar mensaje motivacional cada 5 minutos (300 segundos)
        if (newSeconds % 300 == 0) {
          _updateMotivationalMessage();
        }
      } else {
        _completeSession();
      }
    });

    debugPrint('✅ Timer resumed successfully');
  }

  void restartTimer() {
    debugPrint('🔄 Restarting timer...');

    _timer?.cancel();
    state = state.copyWith(
      isActive: false,
      currentSeconds: state.totalSeconds,
    );

    // Update Live Activity with restart state (non-blocking)
    // Convert current mode to PomodoroPhase for Live Activity
    PomodoroPhase phase;
    switch (state.currentMode) {
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
    
    _patchLiveActivity(
      isRunning: false,
      newEndAt: DateTime.now().add(Duration(seconds: state.currentSeconds)),
      phase: phase,
      taskName: '${state.currentMode.name} - Session ${state.sessionNumber} (Ready)',
    );

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

    // Solo incrementar sessionNumber si completamos una sesión de trabajo
    int newSessionNumber = state.sessionNumber;
    if (state.currentMode.isWork) {
      newSessionNumber = state.sessionNumber + 1;
    }

    state = state.copyWith(
      isActive: false,
      sessionNumber: newSessionNumber,
    );

    // End Live Activity when session completes (non-blocking)
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
    debugPrint('📊 Current session number: ${state.sessionNumber}');
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
    int newSessionNumber = state.sessionNumber;

    if (state.currentMode.isWork) {
      // Después de cada sesión de trabajo, ir a break
      // El long break ocurre después de 3 sesiones de trabajo completas
      if (state.sessionNumber % 3 == 0) {
        newConfig = TimerModeConfig.getLongBreakConfig(
          durationMinutes: state.longBreakMinutes,
        );
      } else {
        newConfig = TimerModeConfig.getShortBreakConfig(
          durationMinutes: state.shortBreakMinutes,
        );
      }
    } else {
      // Después de cualquier break, volver a work
      newConfig = TimerModeConfig.getWorkConfig(
        durationMinutes: state.workDurationMinutes,
      );

      // Si acabamos de completar un long break, resetear el contador de sesiones
      if (state.currentMode.isLongBreak) {
        newSessionNumber = 0;
        debugPrint('🔄 Resetting session counter after long break');
      }
    }

    // Play session change sound and haptic feedback
    _playSessionChangeFeedback(newConfig.mode);

    state = state.copyWith(
      currentMode: newConfig.mode,
      totalSeconds: newConfig.durationMinutes * 60,
      currentSeconds: newConfig.durationMinutes * 60,
      currentMotivationalMessage: newConfig.motivationalMessage,
      currentAnimation: newConfig.animationType,
      sessionNumber: newSessionNumber,
    );

    debugPrint(
        '📋 Next session determined: ${newConfig.mode.displayName} (${newConfig.durationMinutes * 60}s) with animation: ${newConfig.animationType.assetPath}');
    debugPrint(
        '📊 Session counter: $newSessionNumber (Work sessions completed: ${newSessionNumber})');
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
    // The _setupSettingsListener will handle the state updates automatically
    ref.read(settingsControllerProvider.notifier).updateSettings(
          workDurationMinutes: workDurationMinutes,
          shortBreakMinutes: shortBreakMinutes,
          longBreakMinutes: longBreakMinutes,
          isMusicEnabled: isMusicEnabled,
        );

    debugPrint('✅ Settings update triggered - listener will handle state changes');
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
  /// Sincroniza el estado actual con Live Activity de forma no bloqueante
  void _syncWithLiveActivity() {
    // Ejecutar de forma asíncrona sin bloquear el timer
    Future.microtask(() async {
      try {
        final liveActivityController = ref.read(liveActivityControllerProvider.notifier);
        await liveActivityController.syncTimerState(state);
      } catch (e) {
        // Log error but don't affect timer functionality
        debugPrint('⚠️ Live Activity sync error: $e');
      }
    });
  }

  /// Actualiza campos específicos en Live Activity de forma no bloqueante
  void _patchLiveActivity({
    bool? isRunning,
    DateTime? newEndAt,
    PomodoroPhase? phase,
    String? taskName,
  }) {
    // Ejecutar de forma asíncrona sin bloquear el timer
    Future.microtask(() async {
      try {
        final liveActivityController = ref.read(liveActivityControllerProvider.notifier);
        await liveActivityController.patchLiveActivity(
          isRunning: isRunning,
          newEndAt: newEndAt,
          phase: phase,
          taskName: taskName,
        );
      } catch (e) {
        // Log error but don't affect timer functionality
        debugPrint('⚠️ Live Activity patch error: $e');
      }
    });
  }

  /// Finaliza la Live Activity de forma no bloqueante
  void _endLiveActivity() {
    // Ejecutar de forma asíncrona sin bloquear el timer
    Future.microtask(() async {
      try {
        final liveActivityController = ref.read(liveActivityControllerProvider.notifier);
        await liveActivityController.endLiveActivity();
      } catch (e) {
        // Log error but don't affect timer functionality
        debugPrint('⚠️ Live Activity end error: $e');
      }
    });
  }

  // Handle Live Activity actions from Dynamic Island
  void handleLiveActivityAction(String action) {
    switch (action) {
      case 'pause':
        pauseTimer();
        break;
      case 'resume':
      case 'play':
        // Use resumeTimer if timer is paused, otherwise startTimer for new sessions
        if (!state.isActive && state.currentSeconds > 0 && state.currentSeconds < state.totalSeconds) {
          resumeTimer();
        } else {
          startTimer();
        }
        break;
      case 'stop':
        restartTimer();
        break;
      default:
        debugPrint('⚠️ Unknown Live Activity action: $action');
    }
  }
}
