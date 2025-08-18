import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class MedievalAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;
  bool _isMusicEnabled = true;
  double _currentVolume = 0.0;
  static const double _maxVolume = 1.0;
  static const double _volumeStep = 0.05;
  static const int _volumeStepDuration = 500;

  MedievalAudioHandler() {
    debugPrint('MedievalAudioHandler constructor called');
    _initializeAudio();
    _setupPlayerListeners();
  }

  Future<void> _initializeAudio() async {
    debugPrint('_initializeAudio() called');
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
        duration: const Duration(minutes: 30), // Approximate duration
        artUri: Uri.parse('asset:///assets/images/img_app_logo.svg'),
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

      debugPrint('Audio handler initialized successfully');
    } catch (e) {
      debugPrint('Error initializing audio handler: $e');
    }
  }

  void _setupPlayerListeners() {
    _player.playerStateStream.listen((state) {
      final isPlaying = state.playing;
      final processingState = {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[state.processingState]!;

      playbackState.add(playbackState.value.copyWith(
        controls: [
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1],
        processingState: processingState,
        playing: isPlaying,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: 0,
      ));
    });

    _player.positionStream.listen((position) {
      final currentState = playbackState.value;
      if (currentState.playing) {
        playbackState.add(currentState.copyWith(
          updatePosition: position,
        ));
      }
    });
  }

  @override
  Future<void> play() async {
    if (!_isInitialized) {
      debugPrint('Audio handler not initialized yet');
      return;
    }

    if (!_isMusicEnabled) {
      debugPrint('Music is disabled');
      return;
    }

    try {
      await _startMusicWithFadeIn();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _stopMusicWithFadeOut();
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
      ));
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('Error seeking audio: $e');
    }
  }

  Future<void> _startMusicWithFadeIn() async {
    if (!_isMusicEnabled || !_isInitialized) return;

    try {
      // Set volume to max and start playing
      await _player.setVolume(_maxVolume);
      await _player.play();
      _currentVolume = _maxVolume;

      playbackState.add(playbackState.value.copyWith(
        playing: true,
        processingState: AudioProcessingState.ready,
      ));

      debugPrint('Music started with fade in');
    } catch (e) {
      debugPrint('Error starting music with fade in: $e');
    }
  }

  Future<void> _stopMusicWithFadeOut() async {
    if (!_isInitialized) return;

    try {
      // Gradual fade out
      Timer.periodic(
        Duration(milliseconds: _volumeStepDuration),
        (timer) async {
          if (_currentVolume > 0.0) {
            _currentVolume =
                (_currentVolume - _volumeStep).clamp(0.0, _maxVolume);
            await _player.setVolume(_currentVolume);
          } else {
            timer.cancel();
            await _player.pause();
            playbackState.add(playbackState.value.copyWith(
              playing: false,
              processingState: AudioProcessingState.ready,
            ));
            debugPrint('Music stopped with fade out');
          }
        },
      );
    } catch (e) {
      debugPrint('Error stopping music with fade out: $e');
    }
  }

  // Public methods for external control
  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled && _player.playing) {
      _stopMusicWithFadeOut();
    }
  }

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isPlaying => _player.playing;
  bool get isInitialized => _isInitialized;

  Future<void> dispose() async {
    await _player.dispose();
  }
}
