import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medieval_pomodoro/providers/audio_provider.dart';
import 'package:sizer/sizer.dart';

class AudioControlWidget extends ConsumerWidget {
  const AudioControlWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioControllerProvider);
    final audioController = ref.read(audioControllerProvider.notifier);

    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1810), // Color medieval oscuro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37), // Dorado
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título de la canción
          Text(
            audioState.currentSongTitle,
            style: TextStyle(
              color: const Color(0xFFD4AF37),
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),

          // Controles de reproducción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: audioState.hasPrevious
                    ? () => audioController.previousSong()
                    : null,
                icon: Icon(
                  Icons.skip_previous_rounded,
                  color: audioState.hasPrevious
                      ? const Color(0xFFD4AF37)
                      : Colors.white24,
                  size: 24.sp,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD4AF37),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => audioController.togglePlayPause(),
                  icon: Icon(
                    audioState.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: const Color(0xFF2D1810),
                    size: 32.sp,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => audioController
                    .nextSong(), // Siempre habilitado si hay loop
                icon: Icon(
                  Icons.skip_next_rounded,
                  color: const Color(0xFFD4AF37),
                  size: 24.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Control de volumen
          Row(
            children: [
              Icon(
                audioState.currentVolume == 0
                    ? Icons.volume_off
                    : Icons.volume_down,
                color: Colors.white70,
                size: 14.sp,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFD4AF37),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: const Color(0xFFD4AF37),
                    overlayColor: const Color(0xFFD4AF37).withOpacity(0.2),
                  ),
                  child: Slider(
                    value: audioState.currentVolume,
                    onChanged: (value) => audioController.setVolume(value),
                    min: 0.0,
                    max: 1.0,
                  ),
                ),
              ),
              Icon(
                Icons.volume_up,
                color: Colors.white70,
                size: 14.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
