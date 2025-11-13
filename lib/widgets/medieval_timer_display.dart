import 'package:flutter/material.dart';
import 'sprite_widget.dart';
import '../constants/medieval_sprites.dart';

/// Ejemplo: Display de timer estilo medieval usando sprites
class MedievalTimerDisplay extends StatelessWidget {
  final String timeText;
  final double size;

  const MedievalTimerDisplay({
    required this.timeText,
    this.size = 200,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sprite = MedievalSprites.largeBoardTop;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Panel de fondo
        SpriteWidget(
          imagePath: MedievalSprites.imagePath,
          srcX: sprite.x,
          srcY: sprite.y,
          srcWidth: sprite.width,
          srcHeight: sprite.height,
          width: size,
          height: size * (sprite.height / sprite.width),
        ),
        // Texto del timer encima
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            timeText,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black54,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Ejemplo: Botón medieval personalizado
class MedievalButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final MedievalSprite sprite;
  final double width;

  const MedievalButton({
    required this.label,
    required this.onPressed,
    this.sprite = MedievalSprites.mediumWoodenPanel,
    this.width = 150,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SpriteWidget(
            imagePath: MedievalSprites.imagePath,
            srcX: sprite.x,
            srcY: sprite.y,
            srcWidth: sprite.width,
            srcHeight: sprite.height,
            width: width,
            height: width * (sprite.height / sprite.width),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Colors.black,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ejemplo: Panel de estadísticas medieval
class MedievalStatsPanel extends StatelessWidget {
  final String title;
  final String value;

  const MedievalStatsPanel({
    required this.title,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sprite = MedievalSprites.inventoryPanelMedium;
    
    return SizedBox(
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SpriteWidget(
            imagePath: MedievalSprites.imagePath,
            srcX: sprite.x,
            srcY: sprite.y,
            srcWidth: sprite.width,
            srcHeight: sprite.height,
            width: 120,
            height: 120,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ejemplo: Barra de progreso del Pomodoro
class MedievalProgressBar extends StatelessWidget {
  final double progress; // 0.0 a 1.0

  const MedievalProgressBar({
    required this.progress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final emptyBar = MedievalSprites.progressBarEmpty;
    final filledBar = MedievalSprites.progressBarRed;
    
    return SizedBox(
      width: 200,
      height: 32,
      child: Stack(
        children: [
          // Barra vacía (fondo)
          SpriteWidget(
            imagePath: MedievalSprites.imagePath,
            srcX: emptyBar.x,
            srcY: emptyBar.y,
            srcWidth: emptyBar.width,
            srcHeight: emptyBar.height,
            width: 200,
            height: 32,
          ),
          // Barra llena (progreso)
          ClipRect(
            clipper: _ProgressClipper(progress),
            child: SpriteWidget(
              imagePath: MedievalSprites.imagePath,
              srcX: filledBar.x,
              srcY: filledBar.y,
              srcWidth: filledBar.width,
              srcHeight: filledBar.height,
              width: 200,
              height: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressClipper extends CustomClipper<Rect> {
  final double progress;

  _ProgressClipper(this.progress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * progress, size.height);
  }

  @override
  bool shouldReclip(_ProgressClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

