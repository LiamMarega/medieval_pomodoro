import 'dart:async';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'audio_provider.g.dart';

/// Configuración de audio
class AudioConfig {
  static const String youtubeStreamUrl =
      'https://www.youtube.com/watch?v=IxPANmjPaek';

  static const List<String> localSongPaths = [
    'assets/songs/castle_dreams_2.mp3',
    'assets/songs/the_last_knight.mp3',
    'assets/songs/medieval_lofi.mp3',
    'assets/songs/castle_dreams.mp3',
    'assets/songs/the_rusty_knight_tale.mp3',
    'assets/songs/the_wandering_star.mp3'
  ];

  static const List<String> localSongNames = [
    'Castle Dreams 2',
    'The Last Knight',
    'Medieval Lofi',
    'Castle Dreams',
    'The Rusty Knight Tale',
    'The Wandering Star',
  ];
}

/// Handler de audio unificado que maneja YouTube y local
class UnifiedAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  // Reproducción local
  late final AudioPlayer _localPlayer;

  // Reproducción YouTube
  // YouTube Explode instance
  final _yt = YoutubeExplode();

  // Estado
  bool _isInitialized = false;
  bool _isMusicEnabled = true;
  bool _isUsingYouTube = false;

  // Conectividad
  final Connectivity _connectivity = Connectivity();
  bool _isWiFiConnected = false;
  StreamSubscription? _connectivitySubscription;

  // Playlist local
  final List<AudioSource> _audioSources = [];
  List<String> _shuffledSongNames = [];

  UnifiedAudioHandler() {
    _initialize();
  }

  Future<void> _initialize() async {
    debugPrint('🎵 Initializing UnifiedAudioHandler...');

    try {
      // Inicializar conectividad
      await _initializeConnectivity();

      // Inicializar reproductor local
      _localPlayer = AudioPlayer();

      // Crear playlist local
      await _createLocalPlaylist();

      // Configurar listeners del player local
      _setupLocalPlayerListeners();

      // Inicializar según conectividad
      await _initializeBasedOnConnectivity();

      _isInitialized = true;
      debugPrint('✅ UnifiedAudioHandler initialized successfully');
      debugPrint('   Mode: ${_isUsingYouTube ? "YouTube" : "Local"}');

      // Configurar estado inicial
      _updateMediaItem();
      _updatePlaybackState();
    } catch (e) {
      debugPrint('❌ Error initializing UnifiedAudioHandler: $e');
    }
  }

  Future<void> _initializeConnectivity() async {
    // Estado inicial
    final result = await _connectivity.checkConnectivity();
    _isWiFiConnected = (result.contains(ConnectivityResult.wifi));

    // Escuchar cambios
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      final wasWiFi = _isWiFiConnected;
      _isWiFiConnected = (result.contains(ConnectivityResult.wifi));

      if (wasWiFi != _isWiFiConnected) {
        debugPrint('📶 WiFi status changed: $_isWiFiConnected');
        _onConnectivityChanged();
      }
    });
  }

  Future<void> _initializeBasedOnConnectivity() async {
    if (_isWiFiConnected) {
      debugPrint('📶 WiFi request: Switch to YouTube');
      await _switchToYouTube();
    } else {
      debugPrint('📶 WiFi lost/unavailable: Switch to Local');
      await _switchToLocal();
    }
  }

  Future<void> _createLocalPlaylist() async {
    try {
      _audioSources.clear();
      _shuffledSongNames = List.from(AudioConfig.localSongNames);

      // Mezclar nombres
      final random = Random();
      for (int i = _shuffledSongNames.length - 1; i > 0; i--) {
        final j = random.nextInt(i + 1);
        final temp = _shuffledSongNames[i];
        _shuffledSongNames[i] = _shuffledSongNames[j];
        _shuffledSongNames[j] = temp;
      }

      // Crear fuentes de audio
      for (int i = 0; i < AudioConfig.localSongPaths.length; i++) {
        try {
          _audioSources.add(AudioSource.asset(AudioConfig.localSongPaths[i]));
        } catch (e) {
          debugPrint(
              '⚠️ Failed to load song: ${AudioConfig.localSongPaths[i]}');
        }
      }

      if (_audioSources.isEmpty) {
        throw Exception('No valid local songs found');
      }

      await _localPlayer.setAudioSources(_audioSources, preload: true);
      await _localPlayer.setLoopMode(LoopMode.all);
      await _localPlayer.setVolume(0.7);

      debugPrint('✅ Local playlist created with ${_audioSources.length} songs');
    } catch (e) {
      debugPrint('❌ Error creating local playlist: $e');
    }
  }

  Future<void> _switchToLocal() async {
    if (!_isUsingYouTube && _localPlayer.audioSource != null) return;

    try {
      _isUsingYouTube = false;
      await _localPlayer.setAudioSource(
        ConcatenatingAudioSource(children: _audioSources),
        initialIndex: 0,
        initialPosition: Duration.zero,
      );
      _updateMediaItem();
      _updatePlaybackState();
    } catch (e) {
      debugPrint('❌ Error switching to local: $e');
    }
  }

  Future<void> _switchToYouTube() async {
    if (_isUsingYouTube) return;

    try {
      final videoId = VideoId(AudioConfig.youtubeStreamUrl);
      StreamManifest? manifest;
      try {
        var video = await _yt.videos.get(videoId);
        if (video.isLive) {
          var streamUrl =
              await _yt.videos.streamsClient.getHttpLiveStreamUrl(videoId);
          await _localPlayer.setUrl(streamUrl);
        } else {
          manifest = await _yt.videos.streamsClient.getManifest(videoId);
          // Priorizar calidad baja/media para carga rápida
          final audioStream = manifest.audioOnly.sortByBitrate().first;
          await _localPlayer.setUrl(audioStream.url.toString());
        }

        _isUsingYouTube = true;
        _updateMediaItem();
        _updatePlaybackState();

        // Auto-play si corresponde
        if (_isMusicEnabled) {
          _localPlayer.play();
        }
      } catch (e) {
        debugPrint('❌ Could not get YouTube stream: $e');
        // Fallback a local si falla YouTube
        await _switchToLocal();
      }
    } catch (e) {
      debugPrint('❌ Error switching to YouTube: $e');
      _isUsingYouTube = false;
    }
  }

  void _setupLocalPlayerListeners() {
    _localPlayer.playerStateStream.listen((state) {
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
        updatePosition: _localPlayer.position,
        bufferedPosition: _localPlayer.bufferedPosition,
        speed: _localPlayer.speed,
        queueIndex: _localPlayer.currentIndex ?? 0,
      ));
    });

    _localPlayer.positionStream.listen((position) {
      final currentState = playbackState.value;
      if (currentState.playing) {
        playbackState.add(currentState.copyWith(
          updatePosition: position,
        ));
      }
    });

    _localPlayer.currentIndexStream.listen((index) {
      if (index != null && index < _shuffledSongNames.length) {
        _updateMediaItem();
      }
    });
  }

  Future<void> _onConnectivityChanged() async {
    if (!_isInitialized) return;

    final wasPlaying = playbackState.value.playing;

    debugPrint('🔄 Switching audio source due to connectivity change');

    try {
      if (_isWiFiConnected) {
        await _switchToYouTube();
      } else {
        await _switchToLocal();
      }

      // Si estaba reproduciendo, continuar en el nuevo modo
      if (wasPlaying) {
        await play();
      }

      _updateMediaItem();
      _updatePlaybackState();
    } catch (e) {
      debugPrint('❌ Error switching audio source: $e');
    }
  }

  void _updateMediaItem() {
    if (_isUsingYouTube) {
      mediaItem.add(MediaItem(
        id: 'youtube_live',
        album: 'YouTube Live Stream',
        title: 'Lofi Beats Radio 📻',
        artist: '24/7 Live Stream',
        duration: const Duration(hours: 24),
      ));
    } else if (_localPlayer.currentIndex != null &&
        _localPlayer.currentIndex! < _shuffledSongNames.length) {
      final index = _localPlayer.currentIndex!;
      mediaItem.add(MediaItem(
        id: 'local_song_$index',
        album: 'Medieval Pomodoro',
        title: _shuffledSongNames[index],
        artist: 'Background Music',
        duration: _localPlayer.duration ?? const Duration(minutes: 3),
      ));
    } else {
      mediaItem.add(MediaItem(
        id: 'default',
        album: 'Medieval Pomodoro',
        title: 'Medieval Lofi Music',
        artist: 'Background Music',
        duration: const Duration(minutes: 30),
      ));
    }
  }

  void _updatePlaybackState() {
    final isPlaying = _localPlayer.playing;

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
      processingState: AudioProcessingState.ready,
      playing: isPlaying,
      updatePosition: Duration.zero,
      bufferedPosition: Duration.zero,
      speed: 1.0,
      queueIndex: _localPlayer.currentIndex ?? 0,
    ));
  }

  @override
  Future<void> play() async {
    if (!_isInitialized || !_isMusicEnabled) return;

    try {
      await _localPlayer.play();
      _updatePlaybackState();
      debugPrint('▶️ Playing (${_isUsingYouTube ? "YouTube" : "Local"})');
    } catch (e) {
      debugPrint('❌ Error playing: $e');
    }
  }

  @override
  Future<void> pause() async {
    if (!_isInitialized) return;

    try {
      await _localPlayer.pause();
      _updatePlaybackState();
      debugPrint('⏸️ Paused');
    } catch (e) {
      debugPrint('❌ Error pausing: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      if (_isUsingYouTube) {
        await _localPlayer.stop(); // Stop stream
      } else {
        await _localPlayer.stop();
      }
      _updatePlaybackState();
      debugPrint('⏹️ Stopped');
    } catch (e) {
      debugPrint('❌ Error stopping: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    // En vivo de youtube normalmente no se busca, pero si es VOD sí.
    // Asumimos que para Live Stream no permitimos seek.
    if (!_isInitialized) return;

    try {
      await _localPlayer.seek(position);
      _updatePlaybackState();
    } catch (e) {
      debugPrint('❌ Error seeking: $e');
    }
  }

  @override
  Future<void> skipToNext() async {
    if (!_isInitialized || _isUsingYouTube) return;

    try {
      if (_localPlayer.hasNext) {
        await _localPlayer.seekToNext();
        _updateMediaItem();
        _updatePlaybackState();
        debugPrint('⏭️ Next song');
      }
    } catch (e) {
      debugPrint('❌ Error skipping to next: $e');
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (!_isInitialized || _isUsingYouTube) return;

    try {
      if (_localPlayer.hasPrevious) {
        await _localPlayer.seekToPrevious();
        _updateMediaItem();
        _updatePlaybackState();
        debugPrint('⏮️ Previous song');
      }
    } catch (e) {
      debugPrint('❌ Error skipping to previous: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;

    try {
      await _localPlayer.setVolume(volume.clamp(0.0, 1.0));
      debugPrint('🔊 Volume: ${(volume * 100).round()}%');
    } catch (e) {
      debugPrint('❌ Error setting volume: $e');
    }
  }

  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    debugPrint('🎵 Music enabled: $enabled');

    if (!enabled) {
      pause();
    }
  }

  void dispose() {
    _yt.close();
  }

  // Getters
  bool get isUsingYouTube => _isUsingYouTube;
  bool get isMusicEnabled => _isMusicEnabled;

  // Custom actions
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'setVolume':
        if (extras != null && extras['volume'] != null) {
          await setVolume(extras['volume'] as double);
        }
        break;
      case 'mute':
        await setVolume(0.0);
        break;
      case 'unmute':
        await setVolume(0.7);
        break;
      case 'restartCurrentSong':
        if (!_isUsingYouTube) {
          await _localPlayer.seek(Duration.zero);
        }
        break;
    }
  }
}

/// Provider for the AudioHandler instance.
final audioHandlerProvider = Provider<AudioHandler>((ref) {
  return UnifiedAudioHandler();
});

@Riverpod(keepAlive: true)
class AudioController extends _$AudioController {
  late final AudioHandler _audioHandler;
  StreamSubscription? _playbackStateSubscription;
  StreamSubscription? _mediaItemSubscription;

  // Para obtener información adicional del handler unificado
  UnifiedAudioHandler get _unifiedHandler =>
      _audioHandler as UnifiedAudioHandler;

  @override
  AudioState build() {
    try {
      _audioHandler = ref.watch(audioHandlerProvider);
      _setupListeners();
    } catch (e) {
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
        );
      }
    });
  }

  Future<void> initialize() async {
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
      await _unifiedHandler.customAction('setVolume', {'volume': volume});
      state = state.copyWith(currentVolume: volume);
    } catch (e) {
      _setError('Failed to set volume: $e');
    }
  }

  Future<void> mute() async {
    try {
      await _unifiedHandler.customAction('mute');
    } catch (e) {
      _setError('Failed to mute: $e');
    }
  }

  Future<void> unmute() async {
    try {
      await _unifiedHandler.customAction('unmute');
    } catch (e) {
      _setError('Failed to unmute: $e');
    }
  }

  void setMusicEnabled(bool enabled) {
    _unifiedHandler.setMusicEnabled(enabled);
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

  // Nuevos getters
  bool get isUsingYouTube => _unifiedHandler.isUsingYouTube;

  Future<void> restartCurrentSong() async {
    try {
      await _unifiedHandler.customAction('restartCurrentSong');
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
  final bool isUsingYouTube;

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
    this.isUsingYouTube = false,
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
    bool? isUsingYouTube,
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
      isUsingYouTube: isUsingYouTube ?? this.isUsingYouTube,
    );
  }
}
