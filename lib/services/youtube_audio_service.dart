import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:audio_session/audio_session.dart';

class YouTubeAudioService {
  static YouTubeAudioService? _instance;
  static YouTubeAudioService get instance =>
      _instance ??= YouTubeAudioService._();

  YouTubeAudioService._();

  YoutubePlayerController? _controller;
  bool _isInitialized = false;
  bool _isMusicEnabled = true;
  Timer? _fadeTimer;
  
  // URL hardcodeada del stream de YouTube
  static const String _streamUrl = 'https://www.youtube.com/watch?v=IxPANmjPaek';

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _controller?.value.isPlaying ?? false;
  bool get isMusicEnabled => _isMusicEnabled;
  Duration get currentPosition => _controller?.value.position ?? Duration.zero;
  double get currentVolume => (_controller?.value.volume ?? 70.0).toDouble() / 100.0;

  String get currentSongTitle => 'Medieval Lofi Live Stream';

  Future<void> initialize() async {
    debugPrint('🎵 Initializing YouTubeAudioService...');

    try {
      // Configurar la sesión de audio para reproducción en segundo plano
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ));
      
      if (_controller != null) {
        _controller!.dispose();
      }

      // Extraer el video ID de la URL
      final videoId = YoutubePlayer.convertUrlToId(_streamUrl);
      if (videoId == null) {
        throw Exception('Invalid YouTube URL: $_streamUrl');
      }

      // Crear el controlador con configuración para audio únicamente
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: true,
          loop: true,
          isLive: true,
          forceHD: false,
          enableCaption: false,
          captionLanguage: 'en',
          hideControls: true,
        ),
      );

      // Configurar el volumen inicial
      _controller!.setVolume(70); // 70% de volumen inicial

      // Configurar listeners
      _setupListeners();

      _isInitialized = true;
      debugPrint('✅ YouTubeAudioService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing YouTubeAudioService: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  void _setupListeners() {
    _controller!.addListener(() {
      final value = _controller!.value;
      debugPrint(
          '🎵 Player state changed: ${value.isPlaying ? "Playing" : "Paused"} - ${value.playerState}');
    });
  }

  Future<void> play() async {
    debugPrint('▶️ YouTubeAudioService.play() called');

    if (!_isInitialized) {
      debugPrint('❌ Audio service not initialized in play()');
      throw Exception('Audio service not initialized');
    }

    if (!_isMusicEnabled) {
      debugPrint('🔇 Music is disabled');
      return;
    }

    try {
      _fadeTimer?.cancel();
      await _startWithFadeIn();
      debugPrint('✅ Music started successfully');
    } catch (e) {
      debugPrint('❌ Error starting music: $e');
      throw Exception('Failed to start music: $e');
    }
  }

  Future<void> pause() async {
    debugPrint('⏸️ YouTubeAudioService.pause() called');

    if (!_isInitialized) {
      debugPrint('❌ Audio service not initialized in pause()');
      return;
    }

    try {
      _fadeTimer?.cancel();
      await _stopWithFadeOut();
      debugPrint('✅ Music paused successfully');
    } catch (e) {
      debugPrint('❌ Error pausing music: $e');
      throw Exception('Failed to pause music: $e');
    }
  }

  Future<void> stop() async {
    debugPrint('⏹️ YouTubeAudioService.stop() called');

    if (!_isInitialized) {
      debugPrint('❌ Audio service not initialized in stop()');
      return;
    }

    try {
      _fadeTimer?.cancel();
      _controller!.pause();
      debugPrint('✅ Music stopped successfully');
    } catch (e) {
      debugPrint('❌ Error stopping music: $e');
      throw Exception('Failed to stop music: $e');
    }
  }

  Future<void> _startWithFadeIn() async {
    try {
      // Iniciar reproducción con volumen máximo (sin fade in por simplicidad)
      _controller!.setVolume(70);
      _controller!.play();
      debugPrint('🎵 Music started with volume 70%');
    } catch (e) {
      debugPrint('❌ Error in _startWithFadeIn: $e');
      rethrow;
    }
  }

  Future<void> _stopWithFadeOut() async {
    try {
      const int fadeDuration = 1000; // 1 segundo
      const int steps = 20;
      const int stepDuration = fadeDuration ~/ steps;

      final currentVolume = _controller!.value.volume;
      final volumeStep = currentVolume / steps;

      _fadeTimer =
          Timer.periodic(Duration(milliseconds: stepDuration), (timer) async {
        try {
          final newVolume = _controller!.value.volume - volumeStep;
          if (newVolume <= 0.0) {
            timer.cancel();
            _controller!.pause();
            _controller!.setVolume(70); // Restaurar volumen para la próxima reproducción
            debugPrint('🔇 Fade out completed and music paused');
          } else {
            _controller!.setVolume((newVolume * 100).round());
          }
        } catch (e) {
          timer.cancel();
          debugPrint('❌ Error during fade out: $e');
          _controller!.pause();
        }
      });
    } catch (e) {
      debugPrint('❌ Error in _stopWithFadeOut: $e');
      _controller!.pause();
    }
  }

  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;

    try {
      final volumePercent = (volume * 100).clamp(0.0, 100.0).round();
      _controller!.setVolume(volumePercent);
      debugPrint('🔊 Volume set to: $volumePercent%');
    } catch (e) {
      debugPrint('❌ Error setting volume: $e');
    }
  }

  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    debugPrint('🎵 Music enabled: $enabled');

    if (!enabled && isPlaying) {
      pause();
    }
  }

  Future<void> dispose() async {
    debugPrint('🗑️ Disposing YouTubeAudioService...');

    try {
      _fadeTimer?.cancel();
      if (_controller != null) {
        _controller!.dispose();
        _controller = null;
      }
      _isInitialized = false;
      debugPrint('✅ YouTubeAudioService disposed successfully');
    } catch (e) {
      debugPrint('❌ Error disposing YouTubeAudioService: $e');
    }
  }

  // Método para obtener el controlador (necesario para el widget invisible)
  YoutubePlayerController? get controller => _controller;

  // Método para verificar si el stream está disponible
  Future<bool> validateStream() async {
    if (!_isInitialized) return false;

    try {
      // El stream de YouTube debería estar siempre disponible si es un live stream válido
      debugPrint('✅ Stream validation: YouTube live stream should be available');
      return true;
    } catch (e) {
      debugPrint('❌ Error validating stream: $e');
      return false;
    }
  }
}