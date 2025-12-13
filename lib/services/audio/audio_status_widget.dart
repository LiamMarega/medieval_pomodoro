// audio_status_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medieval_pomodoro/providers/audio_provider.dart';

class AudioStatusWidget extends ConsumerWidget {
  const AudioStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioControllerProvider);
    final audioController = ref.read(audioControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                audioState.isUsingYouTube ? Icons.wifi : Icons.music_note,
                color: audioState.isUsingYouTube ? Colors.green : Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                audioState.isUsingYouTube
                    ? 'YouTube Stream (Live)'
                    : 'Local Files',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Now playing: ${audioState.currentSongTitle}',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  audioState.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: audioController.togglePlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed:
                    audioState.isUsingYouTube ? null : audioController.nextSong,
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: audioState.isUsingYouTube
                    ? null
                    : audioController.previousSong,
              ),
              const Spacer(),
              Icon(
                audioState.isMusicEnabled ? Icons.volume_up : Icons.volume_off,
                color: audioState.isMusicEnabled ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
