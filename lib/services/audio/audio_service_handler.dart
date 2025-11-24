import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Handler principal de audio que conecta just_audio con audio_service
/// Maneja la lista de reproducción, los eventos de sistema y las notificaciones
class AudioServiceHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  
  // Lista de canciones disponibles
  final List<MediaItem> _mediaLibrary = [
    MediaItem(
      id: 'assets/songs/castle_dreams_2.mp3',
      album: 'Medieval Lofi',
      title: 'Castle Dreams 2',
      artist: 'Focus Knight',
      artUri: Uri.file('assets/images/knight_icon.png'), // Placeholder
      duration: null, // Se obtendrá al cargar
    ),
    MediaItem(
      id: 'assets/songs/the_last_knight.mp3',
      album: 'Medieval Lofi',
      title: 'The Last Knight',
      artist: 'Focus Knight',
      artUri: Uri.file('assets/images/knight_icon.png'),
    ),
    MediaItem(
      id: 'assets/songs/medieval_lofi.mp3',
      album: 'Medieval Lofi',
      title: 'Medieval Lofi',
      artist: 'Focus Knight',
      artUri: Uri.file('assets/images/knight_icon.png'),
    ),
    MediaItem(
      id: 'assets/songs/castle_dreams.mp3',
      album: 'Medieval Lofi',
      title: 'Castle Dreams',
      artist: 'Focus Knight',
      artUri: Uri.file('assets/images/knight_icon.png'),
    ),
    MediaItem(
      id: 'assets/songs/the_rusty_knight_tale.mp3',
      album: 'Medieval Lofi',
      title: 'The Rusty Knight Tale',
      artist: 'Focus Knight',
      artUri: Uri.file('assets/images/knight_icon.png'),
    ),
    MediaItem(
      id: 'assets/songs/the_wandering_star.mp3',
      album: 'Medieval Lofi',
      title: 'The Wandering Star',
      artist: 'Focus Knight',
      artUri: Uri.file('assets/images/knight_icon.png'),
    ),
  ];

  AudioServiceHandler() {
    _init();
  }

  Future<void> _init() async {
    // Configurar el audio session para que siga reproduciendo en background
    // y maneje interrupciones (llamadas, etc)
    
    // Cargar la playlist inicial
    await _loadPlaylist();
    
    // Escuchar cambios en el estado de reproducción del player
    _player.playbackEventStream.listen(_broadcastState);
    
    // Escuchar cambios en la canción actual
    _player.currentIndexStream.listen((index) {
      if (index != null && queue.value.isNotEmpty && index < queue.value.length) {
        mediaItem.add(queue.value[index]);
      }
    });

    // Propagar errores
    _player.playerStateStream.listen((state) {
      _broadcastState(_player.playbackEvent);
    });
    
    // Manejar finalización de canción/lista
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        stop();
      }
    });
  }

  Future<void> _loadPlaylist() async {
    try {
      // Mezclar canciones para variedad
      final shuffled = List<MediaItem>.from(_mediaLibrary)..shuffle();
      
      // Crear fuentes de audio
      final audioSources = shuffled.map((item) => 
        AudioSource.asset(item.id, tag: item)
      ).toList();
      
      // Actualizar la cola en audio_service
      await updateQueue(shuffled);
      
      // Cargar en el player
      await _player.setAudioSource(
        ConcatenatingAudioSource(children: audioSources),
        preload: true,
      );
      
      // Configurar loop mode
      await _player.setLoopMode(LoopMode.all);
      
      debugPrint('🎵 Playlist loaded with ${shuffled.length} songs');
    } catch (e) {
      debugPrint('❌ Error loading playlist: $e');
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setVolume(double volume) async {
     // El BaseAudioHandler no tiene setVolume nativo en su interfaz pública estándar,
     // pero podemos implementarlo como custom action o exponerlo si casteamos.
     // Para cumplir con el requisito, lo implementamos y lo llamamos desde customAction si es necesario,
     // o directamente si tenemos la instancia.
     await _player.setVolume(volume);
     // Notificamos cambio de volumen si fuera necesario (custom event)
  }

  // Implementación de Custom Actions para funcionalidades extra
  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'setVolume':
        if (extras != null && extras['volume'] != null) {
          final volume = extras['volume'] as double;
          await setVolume(volume);
        }
        break;
      case 'mute':
        await _player.setVolume(0.0);
        break;
      case 'unmute':
        await _player.setVolume(1.0); // O el valor anterior guardado
        break;
      case 'toggleLoop':
        // Lógica de toggle loop
        break;
    }
    return super.customAction(name, extras);
  }

  /// Transmite el estado actual a los clientes (UI, notificaciones)
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final queueIndex = _player.currentIndex;
    
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: queueIndex,
    ));
  }
}

