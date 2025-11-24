import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_provider.g.dart';

/// Provider for the AudioHandler instance.
/// Must be overridden in main.dart with the initialized instance.
final audioHandlerProvider = Provider<AudioHandler>((ref) {
  throw UnimplementedError('AudioHandler has not been initialized');
});

@Riverpod(keepAlive: true)
class AudioController extends _$AudioController {
  late final AudioHandler _audioHandler;
  StreamSubscription? _playbackStateSubscription;
  StreamSubscription? _mediaItemSubscription;

  @override
  AudioState build() {
    try {
      _audioHandler = ref.watch(audioHandlerProvider);
      _setupListeners();
    } catch (e) {
      // Handle case where provider is not overridden yet (during test/init)
      debugPrint('AudioHandler provider not ready: $e');
    }

    // Clean up subscriptions when provider is destroyed
    ref.onDispose(() {
      _playbackStateSubscription?.cancel();
      _mediaItemSubscription?.cancel();
    });

    return const AudioState();
  }

  void _setupListeners() {
    _playbackStateSubscription?.cancel();
    _playbackStateSubscription =
        _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;

      state = state.copyWith(
        isPlaying: isPlaying,
        isLoading: processingState == AudioProcessingState.loading ||
            processingState == AudioProcessingState.buffering,
      );
    });

    _mediaItemSubscription?.cancel();
    _mediaItemSubscription = _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        state = state.copyWith(
          currentSongTitle: mediaItem.title,
          // Update navigation state based on queue if needed
        );
      }
    });
  }

  Future<void> initialize() async {
    // No-op if handled by provider injection, but kept for compatibility
    debugPrint('🎵 AudioController initialized');
    state = state.copyWith(isInitialized: true);
  }

  Future<void> play() async {
    try {
      await _audioHandler.play();
    } catch (e) {
      _setError('Failed to play: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _audioHandler.pause();
    } catch (e) {
      _setError('Failed to pause: $e');
    }
  }

  Future<void> togglePlayPause() async {
    final playing = state.isPlaying;
    if (playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> stop() async {
    try {
      await _audioHandler.stop();
    } catch (e) {
      _setError('Failed to stop: $e');
    }
  }

  Future<void> nextSong() async {
    try {
      await _audioHandler.skipToNext();
    } catch (e) {
      _setError('Failed to skip next: $e');
    }
  }

  Future<void> previousSong() async {
    try {
      await _audioHandler.skipToPrevious();
    } catch (e) {
      _setError('Failed to skip previous: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _audioHandler.customAction('setVolume', {'volume': volume});
      state = state.copyWith(currentVolume: volume);
    } catch (e) {
      _setError('Failed to set volume: $e');
    }
  }

  Future<void> mute() async {
    try {
      await _audioHandler.customAction('mute');
      // Guardamos el estado de habilitado/deshabilitado si queremos
    } catch (e) {
      _setError('Failed to mute: $e');
    }
  }

  Future<void> unmute() async {
    try {
      await _audioHandler.customAction('unmute');
    } catch (e) {
      _setError('Failed to unmute: $e');
    }
  }

  void setMusicEnabled(bool enabled) {
    state = state.copyWith(isMusicEnabled: enabled);
    if (enabled) {
      play();
    } else {
      pause();
    }
  }

  void _setError(String error) {
    state = state.copyWith(error: error);
    debugPrint('❌ AudioController Error: $error');
  }

  // Getters for backward compatibility
  bool get isInitialized => state.isInitialized;
  bool get isPlaying => state.isPlaying;
  bool get isMusicEnabled => state.isMusicEnabled;
  double get currentVolume => state.currentVolume;
  String get currentSongTitle => state.currentSongTitle;
  bool get hasNext => state.hasNext;
  bool get hasPrevious => state.hasPrevious;

  Future<void> restartCurrentSong() async {
    try {
      await _audioHandler.seek(Duration.zero);
    } catch (e) {
      _setError('Failed to restart song: $e');
    }
  }
}

class AudioState {
  final bool isInitialized;
  final bool isLoading;
  final bool isPlaying;
  final bool isMusicEnabled;
  final double currentVolume;
  final bool hasNext;
  final bool hasPrevious;
  final String currentSongTitle;
  final String? error;

  const AudioState({
    this.isInitialized = false,
    this.isLoading = false,
    this.isPlaying = false,
    this.isMusicEnabled = true,
    this.currentVolume = 0.7,
    this.hasNext = true,
    this.hasPrevious = true,
    this.currentSongTitle = 'Medieval Lofi',
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
    String? currentSongTitle,
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
      currentSongTitle: currentSongTitle ?? this.currentSongTitle,
      error: error ?? this.error,
    );
  }
}
