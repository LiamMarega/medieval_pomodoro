import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/timer_state.dart';
import '../models/timer_mode.dart';
// Importa el nuevo servicio de audio
import '../services/audio_service_manager.dart';
import '../core/services/user_stats_service.dart';
import '../core/services/live_activity_manager.dart';
import 'settings_provider.dart';

part 'timer_provider.g.dart';

@Riverpod(keepAlive: true)
class TimerController extends _$TimerController {
  Timer? _timer;
  PlaylistAudioService? _audioService;
  TimerMode? _previousSessionMode; // Store previous session for gap time logic
  final UserStatsService _userStatsService = UserStatsService();
  LiveActivityManager? _liveActivityManager;

  @override
  TimerState build() {
    _initializeAudio();
    _initializeLiveActivity();
    _setupSettingsListener();
    _loadInitialSettings();

    // Use test settings for initial build (can be changed back to normal values)
    const workDuration = 0; // 10 seconds for testing
    const shortBreakDuration = 0; // 10 seconds for testing
    const longBreakDuration = 0; // 20 seconds for testing
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
      totalSeconds: _minutesToSeconds(workDuration),
      currentSeconds: _minutesToSeconds(workDuration),
    );
  }

  void _initializeLiveActivity() async {
    try {
      debugPrint('🚀 Initializing Live Activity Manager...');
      _liveActivityManager = LiveActivityManager();
      await _liveActivityManager!.init();
      debugPrint('✅ Live Activity Manager initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Live Activity Manager: $e');
    }
  }

  /// Converts minutes to seconds, with special handling for 0 minutes (test mode)
  /// 0 minutes = 10 seconds for work/break, 20 seconds for long break, 3 seconds for gapTime
  int _minutesToSeconds(int minutes, {TimerMode? mode}) {
    if (mode == TimerMode.gapTime) {
      return 5; // Always 3 seconds for gap time
    }

    if (minutes == 0) {
      // Test mode: 10 seconds for work/break, 20 seconds for long break
      if (mode == TimerMode.longBreak) {
        return 20; // 20 seconds for long break testing
      } else {
        return 10; // 10 seconds for work/short break testing
      }
    }
    return minutes * 60;
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
            final newTotalSeconds = _minutesToSeconds(data.workDurationMinutes,
                mode: TimerMode.work);
            state = state.copyWith(
              totalSeconds: newTotalSeconds,
              currentSeconds: newTotalSeconds,
            );
          }

          debugPrint('⚙️ Initial settings loaded successfully');
        },
        loading: () => debugPrint('⏳ Loading initial settings...'),
        error: (error, stack) =>
            debugPrint('❌ Error loading initial settings: $error'),
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
            final newTotalSeconds = _minutesToSeconds(
                settings.workDurationMinutes,
                mode: TimerMode.work);
            state = state.copyWith(
              totalSeconds: newTotalSeconds,
              currentSeconds: newTotalSeconds,
            );
          }

          debugPrint(
              '⚙️ Settings updated via listener - Music state preserved');
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

        // Update Live Activity with optimized frequency for better real-time experience
        // Update every 5 seconds for the first 30 seconds, every 15 seconds for the first 5 minutes, then every 30 seconds
        final shouldUpdateLiveActivity = newSeconds <= 30
            ? (newSeconds % 5 == 0)
            : newSeconds <= 300
                ? (newSeconds % 15 == 0)
                : (newSeconds % 30 == 0);

        if (shouldUpdateLiveActivity || newSeconds <= 5) {
          _updateLiveActivity();
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

    // Prevent pausing during gap time
    if (state.currentMode.isGapTime) {
      debugPrint('⚠️ Cannot pause timer during gap time');
      return;
    }

    // Cancelar el timer
    _timer?.cancel();
    state = state.copyWith(isActive: false);

    // Update Live Activity with pause state
    _updateLiveActivity();

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

    // Sync with Live Activity
    _updateLiveActivity();

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
          _updateLiveActivity();
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

    // Update Live Activity with restart state
    _updateLiveActivity();

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

    // Handle gap time completion differently
    if (completedSessionType.isGapTime) {
      _completeGapTime();
      return;
    }

    // Solo incrementar sessionNumber si completamos una sesión de trabajo
    int newSessionNumber = state.sessionNumber;
    if (state.currentMode.isWork) {
      newSessionNumber = state.sessionNumber + 1;
    }

    // Only set isActive to false if not transitioning to gap time
    state = state.copyWith(
      isActive: false,
      sessionNumber: newSessionNumber,
    );

    // End Live Activity when session completes
    _endLiveActivity();

    // Detener música
    if (_audioService?.isPlaying ?? false) {
      debugPrint('🔇 Stopping music for session completion...');
      _stopMusic();
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Play completion sound and haptic feedback
    _playSessionCompletionFeedback();

    // Registrar estadísticas si es una sesión de trabajo completada
    if (completedSessionType.isWork) {
      _recordWorkSessionStats();
    }

    // Start gap time before next session
    _startGapTime(completedSessionType);

    debugPrint('✅ Session completed successfully: $completedSessionType');
    debugPrint('📊 Current session number: ${state.sessionNumber}');
  }

  void _startGapTime(TimerMode completedSessionType) {
    debugPrint('⏳ Starting gap time after $completedSessionType...');

    // Store the completed session type for determining next session
    _previousSessionMode = completedSessionType;

    // Configure gap time state - keep timer active
    final gapConfig = TimerModeConfig.getGapTimeConfig();
    state = state.copyWith(
      lastMode: state.currentMode, // Store current mode as last mode
      currentMode: gapConfig.mode,
      totalSeconds: 3, // Always 3 seconds for gap time
      currentSeconds: 3,
      currentMotivationalMessage: gapConfig.motivationalMessage,
      currentAnimation: gapConfig.animationType,
      isActive: true, // Keep timer active during gap time
    );

    // Auto-start gap time after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      startTimer();
    });
  }

  void _completeGapTime() {
    debugPrint('⏳ Gap time completed, determining next session...');

    _timer?.cancel();
    // Keep timer active during transition to next session
    state = state.copyWith(isActive: true);

    // Determine and configure next session based on previous session stored in _startGapTime
    _determineNextSessionAfterGap();

    // Auto-start next session after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      startTimer();
    });

    debugPrint('✅ Gap time completed, starting next session');
  }

  void _determineNextSessionAfterGap() {
    debugPrint('🔄 Determining next session after gap time...');

    if (_previousSessionMode == null) {
      debugPrint('⚠️ No previous session mode stored, defaulting to work');
      _configureSession(TimerMode.work);
      return;
    }

    TimerMode nextMode;

    switch (_previousSessionMode!) {
      case TimerMode.work:
        // After work, determine if it's short break or long break
        if (state.sessionNumber % 4 == 0) {
          nextMode = TimerMode.longBreak;
        } else {
          nextMode = TimerMode.shortBreak;
        }
        break;
      case TimerMode.shortBreak:
      case TimerMode.longBreak:
        // After any break, go to work
        nextMode = TimerMode.work;
        break;
      case TimerMode.gapTime:
        // This shouldn't happen, but default to work
        nextMode = TimerMode.work;
        break;
    }

    _configureSession(nextMode);
    debugPrint('✅ Next session configured: $nextMode');
  }

  void _configureSession(TimerMode mode) {
    TimerModeConfig config;
    int newSessionNumber = state.sessionNumber;

    switch (mode) {
      case TimerMode.work:
        config = TimerModeConfig.getWorkConfig(
          durationMinutes: state.workDurationMinutes,
        );
        break;
      case TimerMode.shortBreak:
        config = TimerModeConfig.getShortBreakConfig(
          durationMinutes: state.shortBreakMinutes,
        );
        break;
      case TimerMode.longBreak:
        config = TimerModeConfig.getLongBreakConfig(
          durationMinutes: state.longBreakMinutes,
        );
        // Reset session counter after long break
        newSessionNumber = 0;
        break;
      case TimerMode.gapTime:
        config = TimerModeConfig.getGapTimeConfig();
        break;
    }

    // Keep timer active if coming from gap time, otherwise set to false
    final shouldKeepActive = state.currentMode.isGapTime;

    state = state.copyWith(
      lastMode: state.currentMode, // Store current mode as last mode
      currentMode: config.mode,
      totalSeconds:
          _minutesToSeconds(config.durationMinutes, mode: config.mode),
      currentSeconds:
          _minutesToSeconds(config.durationMinutes, mode: config.mode),
      currentMotivationalMessage: config.motivationalMessage,
      currentAnimation: config.animationType,
      sessionNumber: newSessionNumber,
      isActive: shouldKeepActive, // Keep active if coming from gap time
    );

    // Play session change feedback
    _playSessionChangeFeedback(config.mode);
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

    debugPrint('💭 Motivational message updated: $config.motivationalMessage');
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

    debugPrint(
        '✅ Settings update triggered - listener will handle state changes');
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
  /// Sincroniza el estado actual con Live Activity
  void _syncWithLiveActivity() {
    if (_liveActivityManager == null) return;

    try {
      _liveActivityManager!.createFocusActivity(
        userName: "Liam", // O obtenerlo de SharedPreferences
        sessionType: _getSessionTypeString(state.currentMode),
        currentSession: state.sessionNumber,
        timeRemaining: state.currentSeconds,
        paused: !state.isActive,
      );
    } catch (e) {
      debugPrint('⚠️ Live Activity sync error: $e');
    }
  }

  /// Actualiza campos específicos en Live Activity
  void _updateLiveActivity() {
    if (_liveActivityManager == null) return;

    try {
      _liveActivityManager!.updateActivity(
        timeRemaining: state.currentSeconds,
        sessionType: _getSessionTypeString(state.currentMode),
        currentSession: state.sessionNumber,
        paused: !state.isActive,
      );
    } catch (e) {
      debugPrint('⚠️ Live Activity update error: $e');
    }
  }

  /// Finaliza la Live Activity
  void _endLiveActivity() {
    if (_liveActivityManager == null) return;

    try {
      _liveActivityManager!.endActivity();
    } catch (e) {
      debugPrint('⚠️ Live Activity end error: $e');
    }
  }

  /// Convierte TimerMode a string para Live Activity
  String _getSessionTypeString(TimerMode mode) {
    switch (mode) {
      case TimerMode.work:
        return "Focus";
      case TimerMode.shortBreak:
        return "Break";
      case TimerMode.longBreak:
        return "Long Break";
      case TimerMode.gapTime:
        return "Focus"; // Use Focus for gap time
    }
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
        if (!state.isActive &&
            state.currentSeconds > 0 &&
            state.currentSeconds < state.totalSeconds) {
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

  /// Registra las estadísticas de una sesión de trabajo completada
  void _recordWorkSessionStats() {
    try {
      // Calcular la duración de la sesión en minutos
      final durationMinutes = state.workDurationMinutes;

      // Registrar la sesión de forma asíncrona para no bloquear el timer
      Future.microtask(() async {
        await _userStatsService.recordFocusSession(durationMinutes);
        debugPrint('📊 Work session recorded: $durationMinutes minutes');
      });
    } catch (e) {
      debugPrint('❌ Error recording work session stats: $e');
    }
  }
}
