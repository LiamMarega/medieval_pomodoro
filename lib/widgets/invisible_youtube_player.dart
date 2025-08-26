import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../services/youtube_audio_service.dart';

/// Widget invisible que contiene el YoutubePlayer para reproducir solo el audio
/// Este widget debe estar presente en la aplicación para que funcione el servicio de audio
class InvisibleYouTubePlayer extends StatefulWidget {
  const InvisibleYouTubePlayer({super.key});

  @override
  State<InvisibleYouTubePlayer> createState() => _InvisibleYouTubePlayerState();
}

class _InvisibleYouTubePlayerState extends State<InvisibleYouTubePlayer> {
  @override
  Widget build(BuildContext context) {
    final controller = YouTubeAudioService.instance.controller;
    
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: -1000, // Posicionar fuera de la pantalla
      top: -1000,
      child: SizedBox(
        width: 1,
        height: 1,
        child: YoutubePlayer(
          controller: controller,
          showVideoProgressIndicator: false,
          progressIndicatorColor: Colors.transparent,
          progressColors: const ProgressBarColors(
            playedColor: Colors.transparent,
            handleColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}