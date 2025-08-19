import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/timer_state.dart';
// Importa el nuevo servicio de audio
import '../services/audio_service_manager.dart';

part 'timer_provider.g.dart';

@riverpod
class TimerController extends _$TimerController {
  Timer? _timer;
  PlaylistAudioService? _audioService;

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

    _timer?.cancel();
    state = state.copyWith(
      isActive: false,
      sessionNumber: state.sessionNumber + 1,
    );

    // Detener música
    if (_audioService?.isPlaying ?? false) {
      debugPrint('🔇 Stopping music for session completion...');
      _stopMusic();
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _determineNextSession();
    HapticFeedback.heavyImpact();

    debugPrint('✅ Session completed successfully');
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

    debugPrint(
        '📋 Next session determined: $newSessionType (${newTotalSeconds}s)');
  }

  void _updateMotivationalMessage() {
    final random =
        DateTime.now().millisecondsSinceEpoch % _motivationalMessages.length;
    state = state.copyWith(
      currentMotivationalMessage: _motivationalMessages[random],
    );
    debugPrint(
        '💭 Motivational message updated: ${_motivationalMessages[random]}');
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

    state = state.copyWith(
      workDurationMinutes: workDurationMinutes,
      shortBreakMinutes: shortBreakMinutes,
      longBreakMinutes: longBreakMinutes,
      isMusicEnabled: isMusicEnabled,
    );

    // Actualizar el servicio de audio
    _audioService?.setMusicEnabled(isMusicEnabled);

    // Si estamos en una sesión de trabajo, actualizar el tiempo total
    if (state.sessionType == 'Work') {
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
}
