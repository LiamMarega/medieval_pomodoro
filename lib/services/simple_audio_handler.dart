import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class SimpleMedievalAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  SimpleMedievalAudioHandler() {
    debugPrint('SimpleMedievalAudioHandler constructor called');
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    debugPrint('Simple _initializeAudio() called');
    try {
      debugPrint('Setting asset: assets/songs/medieval_lofi.mp3');
      await _player.setAsset('assets/songs/medieval_lofi.mp3');
      debugPrint('Asset set successfully');
      
      debugPrint('Setting loop mode to all');
      await _player.setLoopMode(LoopMode.all);
      debugPrint('Loop mode set successfully');
      
      debugPrint('Setting volume to 0.0');
      await _player.setVolume(0.0);
      debugPrint('Volume set successfully');
      
      _isInitialized = true;
      
      // Set initial media item
      final mediaItem = MediaItem(
        id: 'medieval_lofi',
        album: 'Medieval Pomodoro',
        title: 'Medieval Lofi Music',
        artist: 'Background Music',
        duration: const Duration(minutes: 30),
      );
      
      this.mediaItem.add(mediaItem);
      
      // Set initial playback state
      playbackState.add(PlaybackState(
        controls: [
          MediaControl.pause,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1],
        processingState: AudioProcessingState.ready,
        playing: false,
        updatePosition: Duration.zero,
        bufferedPosition: Duration.zero,
        speed: 1.0,
        queueIndex: 0,
      ));
      
      debugPrint('Simple audio handler initialized successfully');
    } catch (e) {
      debugPrint('Error initializing simple audio handler: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  @override
  Future<void> play() async {
    debugPrint('Simple play() called');
    if (!_isInitialized) {
      debugPrint('Simple audio handler not initialized yet');
      return;
    }

    try {
      debugPrint('Starting playback...');
      await _player.setVolume(1.0);
      await _player.play();
      
      playbackState.add(playbackState.value.copyWith(
        playing: true,
        processingState: AudioProcessingState.ready,
      ));
      
      debugPrint('Simple play() completed successfully');
    } catch (e) {
      debugPrint('Error in simple play(): $e');
    }
  }

  @override
  Future<void> pause() async {
    debugPrint('Simple pause() called');
    try {
      await _player.pause();
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.ready,
      ));
      debugPrint('Simple pause() completed successfully');
    } catch (e) {
      debugPrint('Error in simple pause(): $e');
    }
  }

  @override
  Future<void> stop() async {
    debugPrint('Simple stop() called');
    try {
      await _player.stop();
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
      ));
      debugPrint('Simple stop() completed successfully');
    } catch (e) {
      debugPrint('Error in simple stop(): $e');
    }
  }

  bool get isInitialized => _isInitialized;
  bool get isPlaying => _player.playing;

  Future<void> dispose() async {
    await _player.dispose();
  }
}
