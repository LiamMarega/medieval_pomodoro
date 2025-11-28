import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/timer_state.dart';
import '../models/timer_mode.dart';
// Importa el nuevo servicio de audio
import '../services/audio_service_manager.dart';
import '../core/services/user_stats_service.dart';
import '../core/services/live_activity_manager.dart';
import 'settings_provider.dart';
import 'stats_provider.dart';
import 'app_blocker_provider.dart';

part 'timer_provider.g.dart';

@Riverpod(keepAlive: true)
class TimerController extends _$TimerController with WidgetsBindingObserver {
  Timer? _ticker;
  PlaylistAudioService? _audioService;
  TimerMode? _previousSessionMode; // Store previous session for gap time logic
  final UserStatsService _userStatsService = UserStatsService();
  LiveActivityManager? _liveActivityManager;

  @override
  TimerState build() {
    // Agregar observer para lifecycle (principio clave: manejo de lifecycle)
    WidgetsBinding.instance.addObserver(this);

    // Cleanup cuando el provider se destruye (principio clave: sin fugas)
    ref.onDispose(() {
      _stopTicker();
      WidgetsBinding.instance.removeObserver(this);
    });

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

    final initialDuration = Duration(seconds: _minutesToSeconds(workDuration));

    return TimerState(
      currentMotivationalMessage: initialConfig.motivationalMessage,
      isMusicEnabled: isMusicEnabled,
      currentMode: initialConfig.mode,
      currentAnimation: initialConfig.animationType,
      workDurationMinutes: workDuration,
      shortBreakMinutes: shortBreakDuration,
      longBreakMinutes: longBreakDuration,
      remaining: initialDuration,
      endsAt: null, // No iniciado
    );
  }

  void _initializeLiveActivity() async {
    try {
      debugPrint('🚀 Initializing Live Activity Manager...');
      _liveActivityManager = LiveActivityManager();
      await _liveActivityManager!.init();

      // Listen to actions from Live Activity
      _liveActivityManager!.actionStream.listen((action) {
        debugPrint('🎮 Live Activity Action received: $action');
        handleLiveActivityAction(action);
      });

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

          // Update remaining time if in work session and not running
          if (state.currentMode.isWork && !state.isActive) {
            final newDuration = Duration(
                seconds: _minutesToSeconds(data.workDurationMinutes,
                    mode: TimerMode.work));
            state = state.copyWith(
              remaining: newDuration,
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

          // If we're in a work session and not running, update the remaining time
          if (state.currentMode.isWork && !state.isActive) {
            final newDuration = Duration(
                seconds: _minutesToSeconds(settings.workDurationMinutes,
                    mode: TimerMode.work));
            state = state.copyWith(
              remaining: newDuration,
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

  // ======= Helper: Calcular tiempo restante desde endsAt (principio clave: DateTime-based) =======
  Duration _remainingFromEnds() {
    final end = state.endsAt;
    if (end == null) return state.remaining;
    final diff = end.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  void startTimer() {
    debugPrint('▶️ Starting timer...');
    if (_ticker?.isActive ?? false) {
      debugPrint('⚠️ Timer is already active');
      return;
    }

    // Calcular endsAt basado en remaining actual (principio clave: DateTime-based)
    final end = DateTime.now().add(state.remaining);

    state = state.copyWith(
      isActive: true,
      endsAt: end,
      remaining: state.remaining,
    );

    // Sync with Live Activity
    _syncWithLiveActivity();

    // Iniciar música si está habilitada
    if (state.isMusicEnabled) {
      debugPrint('🎵 Starting music...');
      _startMusic();
    } else {
      debugPrint('🔇 Music is disabled, not starting');
    }

    // Activar bloqueo de apps si es una sesión de trabajo
    if (state.currentMode.isWork) {
      debugPrint('🛡️ Activating App Blocker for Focus Session');
      // Fire and forget - don't await, don't block timer
      ref
          .read(appBlockerProvider.notifier)
          .blockDistractingApps()
          .catchError((e) {
        debugPrint('⚠️ App blocker failed to activate: $e');
      });
    }

    // Configurar modo inmersivo
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Iniciar el ticker (principio clave: 200ms para actualizaciones fluidas)
    _startTicker();

    debugPrint('✅ Timer started successfully');
  }

  // ======= Ticker & transición (principio clave: ticker a 200ms) =======
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final rem = _remainingFromEnds();
      if (rem <= Duration.zero) {
        _stopTicker();
        _completeSession();
      } else {
        state = state.copyWith(remaining: rem);

        // Update Live Activity con frecuencia optimizada
        final seconds = rem.inSeconds;
        final shouldUpdateLiveActivity = seconds <= 30
            ? (seconds % 5 == 0)
            : seconds <= 300
                ? (seconds % 15 == 0)
                : (seconds % 30 == 0);

        if (shouldUpdateLiveActivity || seconds <= 5) {
          _updateLiveActivity();
        }

        // Actualizar mensaje motivacional cada 5 minutos (300 segundos)
        if (seconds > 0 && seconds % 300 == 0) {
          _updateMotivationalMessage();
        }
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
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

    if (!state.isActive) return;

    // Detener ticker y guardar remaining actual (principio clave: DateTime-based)
    _stopTicker();
    final rem = _remainingFromEnds();

    state = state.copyWith(
      isActive: false,
      endsAt: null, // null => detenido
      remaining: rem,
    );

    // Update Live Activity with pause state
    _updateLiveActivity();

    // Detener música si está reproduciéndose
    if (state.isMusicEnabled && (_audioService?.isPlaying ?? false)) {
      debugPrint('🔇 Stopping music...');
      _stopMusic();
    } else {
      debugPrint('🔇 Music is not playing or is disabled, skipping stop');
    }

    // Desactivar bloqueo de apps al pausar
    if (state.currentMode.isWork) {
      debugPrint('🛡️ Deactivating App Blocker (Timer Paused)');
      ref.read(appBlockerProvider.notifier).unblockAll().catchError((e) {
        debugPrint('⚠️ App blocker failed to deactivate on pause: $e');
      });
    }

    // Salir del modo inmersivo
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    debugPrint('✅ Timer paused successfully');
  }

  void resumeTimer() {
    debugPrint('▶️ Resuming timer...');
    if (_ticker?.isActive ?? false) {
      debugPrint('⚠️ Timer is already active');
      return;
    }

    if (state.remaining <= Duration.zero) {
      debugPrint('⚠️ Cannot resume timer with 0 seconds remaining');
      return;
    }

    // Recalcular endsAt basado en remaining (principio clave: DateTime-based)
    final end = DateTime.now().add(state.remaining);

    state = state.copyWith(
      isActive: true,
      endsAt: end,
    );

    // Sync with Live Activity
    _updateLiveActivity();

    // Iniciar música si está habilitada
    if (state.isMusicEnabled) {
      debugPrint('🎵 Resuming music...');
      _startMusic();
    }

    // Configurar modo inmersivo
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Reanudar el ticker
    _startTicker();

    debugPrint('✅ Timer resumed successfully');
  }

  void restartTimer() {
    debugPrint('🔄 Restarting timer...');

    _stopTicker();

    // Calcular duración total según el modo actual
    final totalDuration = Duration(seconds: state.totalSeconds);

    state = state.copyWith(
      isActive: false,
      endsAt: null,
      remaining: totalDuration,
    );

    // Update Live Activity with restart state
    _updateLiveActivity();

    // Detener música si está reproduciéndose
    if (_audioService?.isPlaying ?? false) {
      debugPrint('🔇 Stopping music for restart...');
      _stopMusic();
    }

    // Desactivar bloqueo de apps al reiniciar
    debugPrint('🛡️ Deactivating App Blocker (Restart)');
    ref.read(appBlockerProvider.notifier).unblockAll().catchError((e) {
      debugPrint('⚠️ App blocker failed to deactivate: $e');
    });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _updateMotivationalMessage();
    HapticFeedback.mediumImpact();

    debugPrint('✅ Timer restarted successfully');
  }

  void _completeSession() {
    debugPrint('🏁 Completing session...');

    final completedSessionType = state.currentMode;

    _stopTicker();

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

    // Desactivar bloqueo de apps si es necesario
    // NOTA: Solo desbloqueamos si la sesión terminó, pero si vamos a gap time o break,
    // tal vez queremos mantenerlo? El usuario pidió desbloquear al "terminar".
    // Asumimos que el "Fin del Pomodoro" (Work) desbloquea.
    // Si el usuario quiere que en el break se desbloquee, lo hacemos aquí.
    debugPrint('🛡️ Deactivating App Blocker (Session Completed)');
    ref.read(appBlockerProvider.notifier).unblockAll().catchError((e) {
      debugPrint('⚠️ App blocker failed to deactivate: $e');
    });

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
    final gapDuration = const Duration(seconds: 3);

    state = state.copyWith(
      lastMode: state.currentMode, // Store current mode as last mode
      currentMode: gapConfig.mode,
      remaining: gapDuration,
      endsAt: null, // Will be set when timer starts
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

    _stopTicker();
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

    // Calcular duración según el modo (principio clave: DateTime-based)
    final duration = Duration(
        seconds: _minutesToSeconds(config.durationMinutes, mode: config.mode));

    state = state.copyWith(
      lastMode: state.currentMode, // Store current mode as last mode
      currentMode: config.mode,
      remaining: duration,
      endsAt: null, // Will be set when timer starts
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
    debugPrint('Handling Live Activity action: $action');
    switch (action) {
      case 'pause':
        if (state.isActive) pauseTimer();
        break;
      case 'resume':
      case 'play':
        if (!state.isActive) resumeTimer();
        break;
      case 'skip':
        _completeSession(); // Or skip logic
        break;
      default:
        debugPrint('Unknown action: $action');
    }
  }

  /// Registra las estadísticas de una sesión de trabajo completada
  void _recordWorkSessionStats() {
    try {
      // Calcular la duración de la sesión en segundos
      final workSeconds = state.workDurationMinutes * 60;
      if (workSeconds == 0) {
        // Test mode: use 10 seconds
        final testSeconds = 10;
        Future.microtask(() async {
          await ref
              .read(statsControllerProvider.notifier)
              .markPomodoroCompleted(workSeconds: testSeconds);
          debugPrint(
              '📊 Work session recorded (test mode): $testSeconds seconds');
        });
      } else {
        // Registrar la sesión de forma asíncrona para no bloquear el timer
        Future.microtask(() async {
          await ref
              .read(statsControllerProvider.notifier)
              .markPomodoroCompleted(workSeconds: workSeconds);
          debugPrint(
              '📊 Work session recorded: ${state.workDurationMinutes} minutes');
        });
      }

      // También registrar en el servicio legacy para compatibilidad
      final durationMinutes = state.workDurationMinutes;
      Future.microtask(() async {
        await _userStatsService.recordFocusSession(durationMinutes);
      });
    } catch (e) {
      debugPrint('❌ Error recording work session stats: $e');
    }
  }

  // ======= Lifecycle: retomar cálculo exacto (principio clave: manejo de lifecycle) =======
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed && state.isActive) {
      // Recalcular remaining cuando la app vuelve al foreground
      state = state.copyWith(remaining: _remainingFromEnds());
      debugPrint(
          '📱 App resumed, recalculated remaining time: ${state.remaining}');
    }
  }
}
