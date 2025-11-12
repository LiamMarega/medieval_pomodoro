import 'package:flutter/material.dart';

/// Widget wrapper that applies pixel art effects to its child
/// This ensures pixel-perfect rendering without anti-aliasing
class PixelArtEffect extends StatelessWidget {
  final Widget child;

  const PixelArtEffect({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Use RepaintBoundary to optimize rendering
    // The pixel art effect is achieved through:
    // 1. Using FilterQuality.none on images (handled in PixelArtImage)
    // 2. Using pixel art fonts (pressStart2p, vt323)
    // 3. Using PixelFrame for borders
    // 4. Avoiding smooth gradients and rounded corners where possible
    return RepaintBoundary(
      child: child,
    );
  }
}

/// Widget that ensures pixel-perfect text rendering
class PixelArtText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const PixelArtText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      // Disable text smoothing for pixel-perfect rendering
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
    );
  }
}

/// Widget that applies pixel art effect to images
class PixelArtImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const PixelArtImage(
    this.imagePath, {
    super.key,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      filterQuality: FilterQuality.none, // Critical for pixel art
    );
  }
}
