import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/audio_service_manager.dart';

part 'audio_provider.g.dart';

@riverpod
class AudioController extends _$AudioController {
  final AudioServiceManager _audioManager = AudioServiceManager.instance;

  @override
  AudioState build() {
    return const AudioState();
  }

  Future<void> initialize() async {
    if (!_audioManager.isInitialized) {
      state = state.copyWith(isLoading: true);
      try {
        await _audioManager.initialize();
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
        );
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

  // Getter methods for external access
  bool get isInitialized => _audioManager.isInitialized;
  bool get isPlaying => _audioManager.isPlaying;
  bool get isMusicEnabled => _audioManager.isMusicEnabled;
}

class AudioState {
  final bool isInitialized;
  final bool isLoading;
  final bool isPlaying;
  final bool isMusicEnabled;
  final String? error;

  const AudioState({
    this.isInitialized = false,
    this.isLoading = false,
    this.isPlaying = false,
    this.isMusicEnabled = true, // Music always ON by default
    this.error,
  });

  AudioState copyWith({
    bool? isInitialized,
    bool? isLoading,
    bool? isPlaying,
    bool? isMusicEnabled,
    String? error,
  }) {
    return AudioState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      isPlaying: isPlaying ?? this.isPlaying,
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      error: error ?? this.error,
    );
  }
}
