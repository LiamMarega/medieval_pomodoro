import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class PlaylistAudioService {
  static PlaylistAudioService? _instance;
  static PlaylistAudioService get instance =>
      _instance ??= PlaylistAudioService._();

  PlaylistAudioService._();

  AudioPlayer? _player;
  bool _isInitialized = false;
  bool _isMusicEnabled = true;
  final List<AudioSource> _audioSources = [];
  Timer? _fadeTimer;

  // Lista de canciones lofi medievales (agrega más archivos según tengas)
  final List<String> _songPaths = [
    'assets/songs/castle_dreams_2.mp3',
    'assets/songs/the_last_knight.mp3',
    'assets/songs/medieval_lofi.mp3',
    'assets/songs/castle_dreams.mp3',
    'assets/songs/the_rusty_knight_tale.mp3',
  ];

  // Lista de nombres de canciones para mostrar
  final List<String> _songNames = [
    'The Last Knight',
    'Castle Dreams',
    'Castle Dreams 2',
    'The Rusty Knight Tale',
  ];

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _player?.playing ?? false;
  bool get isMusicEnabled => _isMusicEnabled;
  Duration get currentPosition => _player?.position ?? Duration.zero;
  Duration get totalDuration => _player?.duration ?? Duration.zero;
  int get currentIndex => _player?.currentIndex ?? 0;

  String get currentSongTitle {
    if (_player?.currentIndex != null &&
        _player!.currentIndex! < _songNames.length) {
      return _songNames[_player!.currentIndex!];
    }
    return 'Medieval Lofi Music';
  }

  Future<void> initialize() async {
    debugPrint('🎵 Initializing PlaylistAudioService...');

    try {
      if (_player != null) {
        await _player!.dispose();
      }

      _player = AudioPlayer();

      // Crear playlist con todas las canciones disponibles
      await _createPlaylist();

      // Configurar el player para loop infinito de la playlist
      await _player!.setLoopMode(LoopMode.all);

      // Configurar el volumen inicial
      await _player!.setVolume(0.7);

      // Configurar listeners
      _setupListeners();

      _isInitialized = true;
      debugPrint(
          '✅ PlaylistAudioService initialized successfully with ${_audioSources.length} songs');
    } catch (e) {
      debugPrint('❌ Error initializing PlaylistAudioService: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> _createPlaylist() async {
    try {
      _audioSources.clear();

      // Agregar todas las canciones disponibles a la playlist
      for (int i = 0; i < _songPaths.length; i++) {
        try {
          final audioSource = AudioSource.asset(_songPaths[i]);
          _audioSources.add(audioSource);
          debugPrint('📁 Added song to playlist: ${_songPaths[i]}');
        } catch (e) {
          // Si una canción no existe, continuar con las demás
          debugPrint('⚠️ Song not found, skipping: ${_songPaths[i]}');
        }
      }

      if (_audioSources.isEmpty) {
        // Si no hay canciones en la playlist, agregar al menos una por defecto
        debugPrint('⚠️ No songs found, adding default song');
        _audioSources.add(AudioSource.asset('assets/songs/medieval_lofi.mp3'));
      }

      // Establecer la playlist en el player
      await _player!.setAudioSources(_audioSources, preload: true);

      // Habilitar el modo shuffle para reproducción aleatoria
      await _player!.setShuffleModeEnabled(true);
      debugPrint('🎲 Shuffle mode enabled for random playback');

      debugPrint(
          '✅ Playlist created with ${_audioSources.length} songs and preloaded');
    } catch (e) {
      debugPrint('❌ Error creating playlist: $e');
      throw Exception('Failed to create playlist: $e');
    }
  }

  void _setupListeners() {
    _player!.playerStateStream.listen((state) {
      debugPrint(
          '🎵 Player state changed: ${state.playing ? "Playing" : "Paused"} - ${state.processingState}');
    });

    _player!.currentIndexStream.listen((index) {
      if (index != null && index < _songNames.length) {
        debugPrint(
            '🎵 Now playing: ${_songNames[index]} (${index + 1}/${_songNames.length})');
      }
    });

    _player!.positionStream.listen((position) {
      // Opcional: Log de posición cada 10 segundos para debug
      if (position.inSeconds % 10 == 0 && position.inSeconds > 0) {
        debugPrint(
            '🕐 Position: ${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}');
      }
    });
  }

  Future<void> play() async {
    debugPrint('▶️ PlaylistAudioService.play() called');

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
    debugPrint('⏸️ PlaylistAudioService.pause() called');

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
    debugPrint('⏹️ PlaylistAudioService.stop() called');

    if (!_isInitialized) {
      debugPrint('❌ Audio service not initialized in stop()');
      return;
    }

    try {
      _fadeTimer?.cancel();
      await _player!.stop();
      debugPrint('✅ Music stopped successfully');
    } catch (e) {
      debugPrint('❌ Error stopping music: $e');
      throw Exception('Failed to stop music: $e');
    }
  }

  Future<void> _startWithFadeIn() async {
    try {
      // Iniciar reproducción con volumen máximo (sin fade in por simplicidad)
      await _player!.setVolume(0.7);
      await _player!.play();
      debugPrint('🎵 Music started with volume 0.7');
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

      final currentVolume = _player!.volume;
      final volumeStep = currentVolume / steps;

      _fadeTimer =
          Timer.periodic(Duration(milliseconds: stepDuration), (timer) async {
        try {
          final newVolume = _player!.volume - volumeStep;
          if (newVolume <= 0.0) {
            timer.cancel();
            await _player!.pause();
            await _player!.setVolume(
                0.7); // Restaurar volumen para la próxima reproducción
            debugPrint('🔇 Fade out completed and music paused');
          } else {
            await _player!.setVolume(newVolume);
          }
        } catch (e) {
          timer.cancel();
          debugPrint('❌ Error during fade out: $e');
          await _player!.pause();
        }
      });
    } catch (e) {
      debugPrint('❌ Error in _stopWithFadeOut: $e');
      await _player!.pause();
    }
  }

  Future<void> nextSong() async {
    if (!_isInitialized) return;

    try {
      if (_player!.hasNext) {
        await _player!.seekToNext();
        debugPrint('⏭️ Skipped to next song');
      }
    } catch (e) {
      debugPrint('❌ Error skipping to next song: $e');
    }
  }

  Future<void> previousSong() async {
    if (!_isInitialized) return;

    try {
      if (_player!.hasPrevious) {
        await _player!.seekToPrevious();
        debugPrint('⏮️ Skipped to previous song');
      }
    } catch (e) {
      debugPrint('❌ Error skipping to previous song: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;

    try {
      await _player!.setVolume(volume.clamp(0.0, 1.0));
      debugPrint('🔊 Volume set to: ${(volume * 100).round()}%');
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
    debugPrint('🗑️ Disposing PlaylistAudioService...');

    try {
      _fadeTimer?.cancel();
      if (_player != null) {
        await _player!.dispose();
        _player = null;
      }
      _audioSources.clear();
      _isInitialized = false;
      debugPrint('✅ PlaylistAudioService disposed successfully');
    } catch (e) {
      debugPrint('❌ Error disposing PlaylistAudioService: $e');
    }
  }

  // Método para obtener información de la playlist
  List<String> getPlaylistInfo() {
    return List.from(_songNames);
  }

  // Método para verificar si hay errores de carga
  Future<bool> validatePlaylist() async {
    if (!_isInitialized) return false;

    try {
      // Intentar cargar cada canción para verificar que exista
      int validSongs = 0;
      for (String path in _songPaths) {
        try {
          final tempPlayer = AudioPlayer();
          await tempPlayer.setAsset(path);
          await tempPlayer.dispose();
          validSongs++;
        } catch (e) {
          debugPrint('⚠️ Invalid song: $path');
        }
      }

      debugPrint(
          '✅ Playlist validation: $validSongs/${_songPaths.length} songs are valid');
      return validSongs > 0;
    } catch (e) {
      debugPrint('❌ Error validating playlist: $e');
      return false;
    }
  }
}
