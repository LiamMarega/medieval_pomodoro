// unified_audio_service.dart
import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:medieval_pomodoro/services/audio/audio_config.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class UnifiedAudioService {
  static UnifiedAudioService? _instance;
  static UnifiedAudioService get instance =>
      _instance ??= UnifiedAudioService._();

  UnifiedAudioService._();

  // Para reproducción local
  AudioPlayer? _localPlayer;

  // Para reproducción de YouTube
  YoutubePlayerController? _youtubeController;

  // Estado
  bool _isInitialized = false;
  bool _isMusicEnabled = true;
  bool _isUsingYouTube = false;
  Timer? _fadeTimer;
  final Random _random = Random();

  // Listas
  List<String> _shuffledSongNames = [];
  List<String> _shuffledSongPaths = [];

  // YouTube
  static const String _youtubeStreamUrl =
      'https://www.youtube.com/watch?v=IxPANmjPaek';

  // Local songs
  final List<String> _localSongPaths = AudioConfig.localSongs;
  final List<String> _localSongNames = AudioConfig.localSongNames;

  // Conectividad
  final Connectivity _connectivity = Connectivity();
  bool _isWiFiConnected = false;
  StreamSubscription? _connectivitySubscription;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isUsingYouTube
      ? (_youtubeController?.value.isPlaying ?? false)
      : (_localPlayer?.playing ?? false);
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isUsingYouTube => _isUsingYouTube;

  String get currentSongTitle {
    if (_isUsingYouTube) {
      return 'YouTube Lofi Stream (Live)';
    } else if (_localPlayer?.currentIndex != null &&
        _localPlayer!.currentIndex! < _shuffledSongNames.length) {
      return _shuffledSongNames[_localPlayer!.currentIndex!];
    }
    return 'Medieval Lofi Music';
  }

  Future<void> initialize() async {
    debugPrint('🎵 Initializing UnifiedAudioService...');

    try {
      // Initialize connectivity monitoring
      await _initializeConnectivity();

      // Initialize appropriate player based on connectivity
      await _initializeAppropriatePlayer();

      _isInitialized = true;
      debugPrint('✅ UnifiedAudioService initialized successfully');
      debugPrint(
          '   Using: ${_isUsingYouTube ? "YouTube Stream" : "Local Files"}');
    } catch (e) {
      debugPrint('❌ Error initializing UnifiedAudioService: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> _initializeConnectivity() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isWiFiConnected = (result == ConnectivityResult.wifi);

    // Listen for changes
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      final wasWiFi = _isWiFiConnected;
      _isWiFiConnected = (result == ConnectivityResult.wifi);

      if (wasWiFi != _isWiFiConnected) {
        debugPrint('📶 WiFi status changed: $_isWiFiConnected');
        _onConnectivityChanged();
      }
    });
  }

  Future<void> _initializeAppropriatePlayer() async {
    if (_isWiFiConnected) {
      await _initializeYouTubePlayer();
    } else {
      await _initializeLocalPlayer();
    }
  }

  Future<void> _initializeYouTubePlayer() async {
    debugPrint('📡 Initializing YouTube player...');

    try {
      // Clean up local player if exists
      await _cleanupLocalPlayer();

      // Extract video ID
      final videoId = YoutubePlayer.convertUrlToId(_youtubeStreamUrl);
      if (videoId == null) {
        throw Exception('Invalid YouTube URL');
      }

      // Create YouTube controller (audio only mode)
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: true,
          loop: true,
          isLive: true,
          enableCaption: false,
          hideControls: true,
          controlsVisibleAtStart: false,
          hideThumbnail: true,
        ),
      );

      _isUsingYouTube = true;
      debugPrint('✅ YouTube player initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize YouTube player: $e');
      // Fallback to local player
      await _initializeLocalPlayer();
    }
  }

  Future<void> _initializeLocalPlayer() async {
    debugPrint('📁 Initializing local audio player...');

    try {
      // Clean up YouTube player if exists
      await _cleanupYouTubePlayer();

      _localPlayer = AudioPlayer();

      // Create shuffled playlist
      await _createShuffledPlaylist();

      // Set loop mode
      await _localPlayer!.setLoopMode(LoopMode.all);

      // Set initial volume
      await _localPlayer!.setVolume(0.7);

      // Setup listeners
      _setupLocalPlayerListeners();

      _isUsingYouTube = false;
      debugPrint(
          '✅ Local player initialized with ${_shuffledSongPaths.length} songs');
    } catch (e) {
      debugPrint('❌ Failed to initialize local player: $e');
      throw Exception('No audio source available');
    }
  }

  Future<void> _createShuffledPlaylist() async {
    _shuffledSongPaths = List.from(_localSongPaths);
    _shuffledSongNames = List.from(_localSongNames);

    // Shuffle both lists in the same order
    for (int i = _shuffledSongPaths.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);

      // Swap paths
      final tempPath = _shuffledSongPaths[i];
      _shuffledSongPaths[i] = _shuffledSongPaths[j];
      _shuffledSongPaths[j] = tempPath;

      // Swap names
      final tempName = _shuffledSongNames[i];
      _shuffledSongNames[i] = _shuffledSongNames[j];
      _shuffledSongNames[j] = tempName;
    }

    // Create audio sources
    final audioSources = <AudioSource>[];
    for (int i = 0; i < _shuffledSongPaths.length; i++) {
      try {
        audioSources.add(AudioSource.asset(_shuffledSongPaths[i]));
      } catch (e) {
        debugPrint('⚠️ Failed to load song: ${_shuffledSongPaths[i]}');
      }
    }

    if (audioSources.isEmpty) {
      throw Exception('No valid songs found');
    }

    await _localPlayer!.setAudioSources(audioSources, preload: true);
  }

  void _setupLocalPlayerListeners() {
    _localPlayer!.playerStateStream.listen((state) {
      debugPrint(
          '🎵 Local player state: ${state.playing ? "Playing" : "Paused"}');
    });

    _localPlayer!.currentIndexStream.listen((index) {
      if (index != null && index < _shuffledSongNames.length) {
        debugPrint('🎵 Now playing: ${_shuffledSongNames[index]}');
      }
    });
  }

  Future<void> _onConnectivityChanged() async {
    if (!_isInitialized) return;

    final wasPlaying = isPlaying;

    debugPrint('🔄 Switching audio source due to connectivity change');
    debugPrint('   WiFi: $_isWiFiConnected');

    try {
      if (_isWiFiConnected) {
        // Switch to YouTube
        await _initializeYouTubePlayer();
        if (wasPlaying) {
          await play();
        }
      } else {
        // Switch to local
        await _initializeLocalPlayer();
        if (wasPlaying) {
          await play();
        }
      }
    } catch (e) {
      debugPrint('❌ Error switching audio source: $e');
    }
  }

  Future<void> play() async {
    if (!_isInitialized || !_isMusicEnabled) return;

    try {
      if (_isUsingYouTube) {
        _youtubeController?.play();
      } else {
        _fadeTimer?.cancel();
        _localPlayer!.play();
      }
      debugPrint('▶️ Playing (${_isUsingYouTube ? "YouTube" : "Local"})');
    } catch (e) {
      debugPrint('❌ Error playing: $e');
    }
  }

  Future<void> pause() async {
    if (!_isInitialized) return;

    try {
      if (_isUsingYouTube) {
        _youtubeController?.pause();
      } else {
        await _stopWithFadeOut();
      }
      debugPrint('⏸️ Paused');
    } catch (e) {
      debugPrint('❌ Error pausing: $e');
    }
  }

  Future<void> _stopWithFadeOut() async {
    if (_localPlayer == null) return;

    try {
      const int fadeDuration = 1000;
      const int steps = 20;
      const int stepDuration = fadeDuration ~/ steps;

      final currentVolume = _localPlayer!.volume;
      final volumeStep = currentVolume / steps;

      _fadeTimer = Timer.periodic(
        Duration(milliseconds: stepDuration),
        (timer) async {
          try {
            final newVolume = _localPlayer!.volume - volumeStep;
            if (newVolume <= 0.0) {
              timer.cancel();
              await _localPlayer!.pause();
              await _localPlayer!.setVolume(0.7);
            } else {
              await _localPlayer!.setVolume(newVolume);
            }
          } catch (e) {
            timer.cancel();
            await _localPlayer!.pause();
          }
        },
      );
    } catch (e) {
      await _localPlayer!.pause();
    }
  }

  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      if (_isUsingYouTube) {
        _youtubeController?.pause();
      } else {
        await _localPlayer!.stop();
      }
      debugPrint('⏹️ Stopped');
    } catch (e) {
      debugPrint('❌ Error stopping: $e');
    }
  }

  Future<void> nextSong() async {
    if (!_isInitialized || _isUsingYouTube) return;

    try {
      if (_localPlayer!.hasNext) {
        await _localPlayer!.seekToNext();
        debugPrint('⏭️ Next song');
      }
    } catch (e) {
      debugPrint('❌ Error skipping to next: $e');
    }
  }

  Future<void> previousSong() async {
    if (!_isInitialized || _isUsingYouTube) return;

    try {
      if (_localPlayer!.hasPrevious) {
        await _localPlayer!.seekToPrevious();
        debugPrint('⏮️ Previous song');
      }
    } catch (e) {
      debugPrint('❌ Error skipping to previous: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;

    try {
      if (_isUsingYouTube) {
        // YouTube volume control (0-100)
        _youtubeController?.setVolume((volume * 100).round());
      } else {
        await _localPlayer!.setVolume(volume.clamp(0.0, 1.0));
      }
      debugPrint('🔊 Volume: ${(volume * 100).round()}%');
    } catch (e) {
      debugPrint('❌ Error setting volume: $e');
    }
  }

  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    debugPrint('🎵 Music enabled: $enabled');

    if (!enabled && isPlaying) {
      pause();
    } else if (enabled && !isPlaying) {
      play();
    }
  }

  Future<void> _cleanupLocalPlayer() async {
    _fadeTimer?.cancel();
    if (_localPlayer != null) {
      await _localPlayer!.dispose();
      _localPlayer = null;
    }
  }

  Future<void> _cleanupYouTubePlayer() async {
    if (_youtubeController != null) {
      _youtubeController!.pause();
      _youtubeController!.dispose();
      _youtubeController = null;
    }
  }

  Future<void> dispose() async {
    debugPrint('🗑️ Disposing UnifiedAudioService...');

    await _connectivitySubscription?.cancel();
    await _cleanupLocalPlayer();
    await _cleanupYouTubePlayer();

    _isInitialized = false;
    debugPrint('✅ UnifiedAudioService disposed');
  }

  // Get current audio source info
  String get audioSourceInfo {
    return _isUsingYouTube
        ? 'YouTube Stream (Live)'
        : 'Local Files (${_shuffledSongPaths.length} songs)';
  }

  // Check if we can switch to YouTube
  Future<bool> canUseYouTube() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }
}
