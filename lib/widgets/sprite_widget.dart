import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget para mostrar un sprite individual de un spritesheet
/// 
/// Uso:
/// ```dart
/// SpriteWidget(
///   imagePath: 'assets/sprites/medieval.png',
///   srcX: 0,
///   srcY: 0,
///   srcWidth: 64,
///   srcHeight: 64,
///   width: 128,
///   height: 128,
/// )
/// ```
class SpriteWidget extends StatefulWidget {
  final String imagePath;
  final double srcX;
  final double srcY;
  final double srcWidth;
  final double srcHeight;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SpriteWidget({
    required this.imagePath,
    required this.srcX,
    required this.srcY,
    required this.srcWidth,
    required this.srcHeight,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    super.key,
  });

  @override
  State<SpriteWidget> createState() => _SpriteWidgetState();
}

class _SpriteWidgetState extends State<SpriteWidget> {
  ui.Image? _image;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(SpriteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final ByteData data = await rootBundle.load(widget.imagePath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    
    if (mounted) {
      setState(() {
        _image = frame.image;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _image == null) {
      return SizedBox(
        width: widget.width ?? widget.srcWidth,
        height: widget.height ?? widget.srcHeight,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return CustomPaint(
      size: Size(
        widget.width ?? widget.srcWidth,
        widget.height ?? widget.srcHeight,
      ),
      painter: _SpritePainter(
        image: _image!,
        srcRect: Rect.fromLTWH(
          widget.srcX,
          widget.srcY,
          widget.srcWidth,
          widget.srcHeight,
        ),
        fit: widget.fit,
      ),
    );
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }
}

class _SpritePainter extends CustomPainter {
  final ui.Image image;
  final Rect srcRect;
  final BoxFit fit;

  _SpritePainter({
    required this.image,
    required this.srcRect,
    required this.fit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    final Paint paint = Paint()
      ..filterQuality = FilterQuality.none; // Mantiene el estilo pixel art
    
    canvas.drawImageRect(image, srcRect, dstRect, paint);
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) {
    return oldDelegate.image != image || 
           oldDelegate.srcRect != srcRect ||
           oldDelegate.fit != fit;
  }
}

/// Helper para precarga de imágenes (opcional, mejora performance)
class SpriteSheetCache {
  static final Map<String, ui.Image> _cache = {};
  
  static Future<ui.Image> loadImage(String path) async {
    if (_cache.containsKey(path)) {
      return _cache[path]!;
    }
    
    final ByteData data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final image = frame.image;
    
    _cache[path] = image;
    return image;
  }
  
  static void clearCache() {
    for (var image in _cache.values) {
      image.dispose();
    }
    _cache.clear();
  }
}

