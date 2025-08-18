import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioTest {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    debugPrint('AudioTest.initialize() called');
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
      debugPrint('AudioTest initialized successfully');
    } catch (e) {
      debugPrint('Error initializing AudioTest: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  static Future<void> play() async {
    debugPrint('AudioTest.play() called');
    if (!_isInitialized) {
      debugPrint('AudioTest not initialized yet');
      return;
    }

    try {
      debugPrint('Starting playback...');
      await _player.setVolume(1.0);
      await _player.play();
      debugPrint('AudioTest play() completed successfully');
    } catch (e) {
      debugPrint('Error in AudioTest play(): $e');
    }
  }

  static Future<void> pause() async {
    debugPrint('AudioTest.pause() called');
    try {
      await _player.pause();
      debugPrint('AudioTest pause() completed successfully');
    } catch (e) {
      debugPrint('Error in AudioTest pause(): $e');
    }
  }

  static Future<void> stop() async {
    debugPrint('AudioTest.stop() called');
    try {
      await _player.stop();
      debugPrint('AudioTest stop() completed successfully');
    } catch (e) {
      debugPrint('Error in AudioTest stop(): $e');
    }
  }

  static Future<void> setVolume(double volume) async {
    debugPrint('AudioTest.setVolume() called with: $volume');
    try {
      await _player.setVolume(volume);
      debugPrint('AudioTest setVolume() completed successfully');
    } catch (e) {
      debugPrint('Error in AudioTest setVolume(): $e');
    }
  }

  static bool get isInitialized => _isInitialized;
  static bool get isPlaying => _player.playing;

  static Future<void> dispose() async {
    await _player.dispose();
  }
}
