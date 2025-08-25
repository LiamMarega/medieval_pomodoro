import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../providers/audio_provider.dart';

class AudioControlsWidget extends ConsumerStatefulWidget {
  const AudioControlsWidget({super.key});

  @override
  ConsumerState<AudioControlsWidget> createState() =>
      _AudioControlsWidgetState();
}

class _AudioControlsWidgetState extends ConsumerState<AudioControlsWidget>
    with TickerProviderStateMixin {
  late AnimationController _volumeAnimationController;
  late Animation<double> _volumeScaleAnimation;

  // Variables para manejar el doble tap del botón de retroceder
  int _previousButtonTapCount = 0;
  Timer? _previousButtonTimer;

  @override
  void initState() {
    super.initState();
    _volumeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _volumeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _volumeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _volumeAnimationController.dispose();
    _previousButtonTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioControllerProvider);
    final audioController = ref.read(audioControllerProvider.notifier);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B0E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDAA520),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDAA520).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Título de la sección
          Text(
            'CONTROLES DE AUDIO',
            style: GoogleFonts.pressStart2p(
              fontSize: 14.sp,
              color: const Color(0xFFDAA520),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),

          // Información de la canción actual
          if (audioState.isInitialized) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: const Color(0xFF4A3728),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFDAA520).withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'REPRODUCIENDO AHORA',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10.sp,
                      color: const Color(0xFFDAA520).withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    audioController.currentSongTitle,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 12.sp,
                      color: const Color(0xFFDAA520),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Controles de navegación de canciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildVolumeButton(
                icon: Icons.volume_down,
                onPressed: audioState.currentVolume > 0.0
                    ? () => _adjustVolume(audioController, -0.1)
                    : null,
              ),
              _buildVolumeButton(
                icon: Icons.volume_up,
                onPressed: audioState.currentVolume < 1.0
                    ? () => _adjustVolume(audioController, 0.1)
                    : null,
              ),
              _buildNavigationButton(
                icon: Icons.skip_previous,
                onPressed: audioController.hasPrevious
                    ? () => _handlePreviousButtonTap(audioController)
                    : null,
              ),
              _buildNavigationButton(
                icon: Icons.skip_next,
                onPressed: audioController.hasNext
                    ? () => audioController.nextSong()
                    : null,
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Control de volumen
          Column(
            children: [
              Text(
                'VOLUMEN',
                style: GoogleFonts.pressStart2p(
                  fontSize: 12.sp,
                  color: const Color(0xFFDAA520),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),

              // Indicador de volumen
              AnimatedBuilder(
                animation: _volumeScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _volumeScaleAnimation.value,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A3728),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFDAA520),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${(audioState.currentVolume * 100).round()}%',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 16.sp,
                          color: const Color(0xFFDAA520),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Botones de control de volumen
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [],
              ),
            ],
          ),

          // Mostrar errores si los hay
          if (audioState.error != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Text(
                audioState.error!,
                style: GoogleFonts.pressStart2p(
                  fontSize: 8.sp,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return _AnimatedControlButton(
      onPressed: onPressed,
      child: Icon(
        icon,
        size: 24.sp,
        color: isEnabled
            ? const Color(0xFFDAA520)
            : const Color(0xFFDAA520).withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildVolumeButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return _AnimatedControlButton(
      onPressed: onPressed,
      child: Icon(
        icon,
        size: 20.sp,
        color: isEnabled
            ? const Color(0xFFDAA520)
            : const Color(0xFFDAA520).withValues(alpha: 0.5),
      ),
    );
  }

  void _adjustVolume(AudioController audioController, double delta) {
    final newVolume = (audioController.currentVolume + delta).clamp(0.0, 1.0);
    audioController.setVolume(newVolume);

    // Animación visual del cambio de volumen
    _volumeAnimationController.forward().then((_) {
      _volumeAnimationController.reverse();
    });

    // Feedback háptico
    HapticFeedback.lightImpact();
  }

  void _handlePreviousButtonTap(AudioController audioController) {
    _previousButtonTapCount++;

    // Cancelar el timer anterior si existe
    _previousButtonTimer?.cancel();

    if (_previousButtonTapCount == 1) {
      // Primer tap: configurar timer para reiniciar la canción
      _previousButtonTimer = Timer(const Duration(milliseconds: 300), () {
        // Si solo hubo un tap, reiniciar la canción actual
        audioController.restartCurrentSong();
        _previousButtonTapCount = 0;
        HapticFeedback.lightImpact();
      });
    } else if (_previousButtonTapCount == 2) {
      // Segundo tap: ir a la canción anterior
      _previousButtonTimer?.cancel();
      audioController.previousSong();
      _previousButtonTapCount = 0;
      HapticFeedback.mediumImpact();
    }
  }
}

class _AnimatedControlButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const _AnimatedControlButton({
    required this.child,
    this.onPressed,
  });

  @override
  State<_AnimatedControlButton> createState() => _AnimatedControlButtonState();
}

class _AnimatedControlButtonState extends State<_AnimatedControlButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 6.h,
              height: 6.h,
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isEnabled
                    ? const Color(0xFF4A3728)
                    : const Color(0xFF4A3728).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEnabled
                      ? const Color(0xFFDAA520)
                      : const Color(0xFFDAA520).withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: const Color(0xFFDAA520)
                              .withValues(alpha: 0.3 * _shadowAnimation.value),
                          blurRadius: 6 * _shadowAnimation.value,
                          offset: Offset(0, 3 * _shadowAnimation.value),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
