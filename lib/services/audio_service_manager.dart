import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'simple_audio_handler.dart';

class AudioServiceManager {
  static AudioServiceManager? _instance;
  static AudioHandler? _audioHandler;
  static bool _isInitialized = false;

  AudioServiceManager._();

  static AudioServiceManager get instance {
    _instance ??= AudioServiceManager._();
    return _instance!;
  }

  static AudioHandler? get audioHandler => _audioHandler;

  Future<void> initialize() async {
    debugPrint('AudioServiceManager.initialize() called');
    
    if (_isInitialized) {
      debugPrint('Audio service already initialized');
      return;
    }

    try {
      debugPrint('Starting AudioService.init()...');
      _audioHandler = await AudioService.init(
        builder: () {
          debugPrint('Creating SimpleMedievalAudioHandler...');
          return SimpleMedievalAudioHandler();
        },
        config: AudioServiceConfig(
          androidNotificationChannelId: 'com.medieval_pomodoro.channel.audio',
          androidNotificationChannelName: 'Medieval Pomodoro Music',
          androidNotificationChannelDescription: 'Background music for Medieval Pomodoro timer',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: false, // Keep service running when paused
          notificationColor: const Color(0xFFDAA520), // Medieval gold color
        ),
      );

      _isInitialized = true;
      debugPrint('Audio service initialized successfully. Handler: $_audioHandler');
    } catch (e) {
      debugPrint('Error initializing audio service: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      _isInitialized = false;
    }
  }

  Future<void> play() async {
    if (!_isInitialized || _audioHandler == null) {
      debugPrint('Audio service not initialized');
      return;
    }

    try {
      await _audioHandler!.play();
      debugPrint('Audio service play command sent');
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> pause() async {
    if (!_isInitialized || _audioHandler == null) {
      debugPrint('Audio service not initialized');
      return;
    }

    try {
      await _audioHandler!.pause();
      debugPrint('Audio service pause command sent');
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  Future<void> stop() async {
    if (!_isInitialized || _audioHandler == null) {
      debugPrint('Audio service not initialized');
      return;
    }

    try {
      await _audioHandler!.stop();
      debugPrint('Audio service stop command sent');
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  void setMusicEnabled(bool enabled) {
    debugPrint('setMusicEnabled called with: $enabled');
    // For now, just log the call
  }

  bool get isMusicEnabled {
    return true; // Always enabled for testing
  }

  bool get isPlaying {
    if (_audioHandler != null) {
      return _audioHandler!.playbackState.value.playing;
    }
    return false;
  }

  bool get isInitialized => _isInitialized;

  Future<void> dispose() async {
    if (_audioHandler != null) {
      _audioHandler = null;
    }
    _isInitialized = false;
    debugPrint('Audio service disposed');
  }
}
