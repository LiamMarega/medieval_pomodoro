import 'dart:async';
import 'package:flutter/foundation.dart';
import 'youtube_audio_service.dart';

class PlaylistAudioService {
  static PlaylistAudioService? _instance;
  static PlaylistAudioService get instance =>
      _instance ??= PlaylistAudioService._();

  PlaylistAudioService._();

  final YouTubeAudioService _youtubeService = YouTubeAudioService.instance;

  // Getters
  bool get isInitialized => _youtubeService.isInitialized;
  bool get isPlaying => _youtubeService.isPlaying;
  bool get isMusicEnabled => _youtubeService.isMusicEnabled;
  Duration get currentPosition => _youtubeService.currentPosition;
  Duration get totalDuration => Duration.zero; // Los streams no tienen duración fija
  int get currentIndex => 0; // Solo hay un stream
  double get currentVolume => _youtubeService.currentVolume;

  String get currentSongTitle => _youtubeService.currentSongTitle;

  Future<void> initialize() async {
    debugPrint('🎵 Initializing PlaylistAudioService (YouTube Stream)...');
    
    try {
      await _youtubeService.initialize();
      debugPrint('✅ PlaylistAudioService initialized successfully with YouTube stream');
    } catch (e) {
      debugPrint('❌ Error initializing PlaylistAudioService: $e');
      rethrow;
    }
  }



  Future<void> play() async {
    debugPrint('▶️ PlaylistAudioService.play() called');
    await _youtubeService.play();
  }

  Future<void> pause() async {
    debugPrint('⏸️ PlaylistAudioService.pause() called');
    await _youtubeService.pause();
  }

  Future<void> stop() async {
    debugPrint('⏹️ PlaylistAudioService.stop() called');
    await _youtubeService.stop();
  }

  Future<void> nextSong() async {
    // No aplicable para streams de YouTube
    debugPrint('⏭️ Next song not available for YouTube streams');
  }

  Future<void> previousSong() async {
    // No aplicable para streams de YouTube
    debugPrint('⏮️ Previous song not available for YouTube streams');
  }

  Future<void> restartCurrentSong() async {
    // Para streams, simplemente reiniciamos la reproducción
    await _youtubeService.stop();
    await _youtubeService.play();
    debugPrint('🔄 Restarted YouTube stream');
  }

  Future<void> setVolume(double volume) async {
    await _youtubeService.setVolume(volume);
  }

  void setMusicEnabled(bool enabled) {
    _youtubeService.setMusicEnabled(enabled);
  }

  Future<void> dispose() async {
    debugPrint('🗑️ Disposing PlaylistAudioService...');
    await _youtubeService.dispose();
    debugPrint('✅ PlaylistAudioService disposed successfully');
  }

  // Método para obtener información del stream
  List<String> getPlaylistInfo() {
    return [_youtubeService.currentSongTitle];
  }

  // Método para verificar si el stream está disponible
  Future<bool> validatePlaylist() async {
    return await _youtubeService.validateStream();
  }
}
