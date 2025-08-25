import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/audio_service_manager.dart';

part 'audio_provider.g.dart';

@Riverpod(keepAlive: true)
class AudioController extends _$AudioController {
  final PlaylistAudioService _audioManager = PlaylistAudioService.instance;

  @override
  AudioState build() {
    return const AudioState();
  }

  Future<void> initialize() async {
    debugPrint('🎵 AudioProvider.initialize() called');
    
    if (_audioManager.isInitialized) {
      debugPrint('🎵 Audio manager already initialized, updating state');
      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
      );
      _updateNavigationState();
      debugPrint('🎵 Audio provider state updated from existing initialization');
      return;
    }
    
    if (!_audioManager.isInitialized) {
      state = state.copyWith(isLoading: true);
      try {
        debugPrint('🎵 Initializing audio manager from provider');
        await _audioManager.initialize();
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
        );
        // Pequeño delay para asegurar que el audio player esté completamente listo
        await Future.delayed(const Duration(milliseconds: 100));
        _updateNavigationState();
        debugPrint('Audio provider initialized successfully');
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to initialize audio: $e',
        );
        debugPrint('Error initializing audio provider: $e');
      }
    }
  }

  Future<void> play() async {
    if (!_audioManager.isInitialized) {
      debugPrint('Audio service not initialized');
      return;
    }

    try {
      state = state.copyWith(isLoading: true);
      await _audioManager.play();
      state = state.copyWith(
        isLoading: false,
        isPlaying: true,
      );
      debugPrint('Audio started via provider');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to play audio: $e',
      );
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> pause() async {
    if (!_audioManager.isInitialized) {
      debugPrint('Audio service not initialized');
      return;
    }

    try {
      state = state.copyWith(isLoading: true);
      await _audioManager.pause();
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
      );
      debugPrint('Audio paused via provider');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to pause audio: $e',
      );
      debugPrint('Error pausing audio: $e');
    }
  }

  Future<void> stop() async {
    if (!_audioManager.isInitialized) {
      debugPrint('Audio service not initialized');
      return;
    }

    try {
      state = state.copyWith(isLoading: true);
      await _audioManager.stop();
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
      );
      debugPrint('Audio stopped via provider');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to stop audio: $e',
      );
      debugPrint('Error stopping audio: $e');
    }
  }

  void setMusicEnabled(bool enabled) {
    _audioManager.setMusicEnabled(enabled);
    state = state.copyWith(
      isMusicEnabled: enabled,
      error: null, // Clear any previous errors
    );
    debugPrint('Music enabled set to: $enabled');
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void _updateNavigationState() {
    if (_audioManager.isInitialized) {
      final playlistLength = _audioManager.getPlaylistInfo().length;
      final currentIndex = _audioManager.currentIndex;
      
      debugPrint('Updating navigation state: index=$currentIndex, length=$playlistLength');
      
      state = state.copyWith(
        hasNext: currentIndex < playlistLength - 1,
        hasPrevious: currentIndex > 0,
      );
      
      debugPrint('Navigation state updated: hasNext=${state.hasNext}, hasPrevious=${state.hasPrevious}');
    } else {
      debugPrint('Audio manager not initialized, setting navigation to false');
      state = state.copyWith(
        hasNext: false,
        hasPrevious: false,
      );
    }
  }

  Future<void> nextSong() async {
    if (!_audioManager.isInitialized) {
      debugPrint('Audio service not initialized');
      return;
    }

    try {
      await _audioManager.nextSong();
      _updateNavigationState();
      debugPrint('Skipped to next song via provider');
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to skip to next song: $e',
      );
      debugPrint('Error skipping to next song: $e');
    }
  }

  Future<void> previousSong() async {
    if (!_audioManager.isInitialized) {
      debugPrint('Audio service not initialized');
      return;
    }

    try {
      await _audioManager.previousSong();
      _updateNavigationState();
      debugPrint('Skipped to previous song via provider');
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to skip to previous song: $e',
      );
      debugPrint('Error skipping to previous song: $e');
    }
  }

  Future<void> restartCurrentSong() async {
    if (!_audioManager.isInitialized) {
      debugPrint('Audio service not initialized');
      return;
    }

    try {
      await _audioManager.restartCurrentSong();
      _updateNavigationState();
      debugPrint('Restarted current song via provider');
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to restart current song: $e',
      );
      debugPrint('Error restarting current song: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    if (!_audioManager.isInitialized) {
      debugPrint('Audio service not initialized');
      return;
    }

    try {
      await _audioManager.setVolume(volume);
      state = state.copyWith(
        currentVolume: volume,
      );
      debugPrint('Volume set to: ${(volume * 100).round()}% via provider');
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to set volume: $e',
      );
      debugPrint('Error setting volume: $e');
    }
  }

  // Getter methods for external access
  bool get isInitialized => _audioManager.isInitialized;
  bool get isPlaying => _audioManager.isPlaying;
  bool get isMusicEnabled => _audioManager.isMusicEnabled;
  double get currentVolume => _audioManager.currentVolume;
  String get currentSongTitle => _audioManager.currentSongTitle;
  bool get hasNext => state.hasNext;
  bool get hasPrevious => state.hasPrevious;
}

class AudioState {
  final bool isInitialized;
  final bool isLoading;
  final bool isPlaying;
  final bool isMusicEnabled;
  final double currentVolume;
  final bool hasNext;
  final bool hasPrevious;
  final String? error;

  const AudioState({
    this.isInitialized = false,
    this.isLoading = false,
    this.isPlaying = false,
    this.isMusicEnabled = true, // Music always ON by default
    this.currentVolume = 0.7,
    this.hasNext = false,
    this.hasPrevious = false,
    this.error,
  });

  AudioState copyWith({
    bool? isInitialized,
    bool? isLoading,
    bool? isPlaying,
    bool? isMusicEnabled,
    double? currentVolume,
    bool? hasNext,
    bool? hasPrevious,
    String? error,
  }) {
    return AudioState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      isPlaying: isPlaying ?? this.isPlaying,
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      currentVolume: currentVolume ?? this.currentVolume,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
      error: error ?? this.error,
    );
  }
}
