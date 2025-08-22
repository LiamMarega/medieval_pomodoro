import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class InnerShadow extends SingleChildRenderObjectWidget {
  const InnerShadow({
    super.key,
    this.blur = 10,
    this.color = Colors.black38,
    this.offset = const Offset(10, 10),
    required Widget child,
  }) : super(child: child);

  final double blur;
  final Color color;
  final Offset offset;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final _RenderInnerShadow renderObject = _RenderInnerShadow();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderInnerShadow renderObject) {
    renderObject
      ..color = color
      ..blur = blur
      ..dx = offset.dx
      ..dy = offset.dy;
  }
}

class _RenderInnerShadow extends RenderProxyBox {
  double blur = 10;
  Color color = Colors.black38;
  double dx = 10;
  double dy = 10;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    try {
      final Rect rectOuter = offset & size;
      final Rect rectInner = Rect.fromLTWH(
        offset.dx,
        offset.dy,
        size.width - dx,
        size.height - dy,
      );

      // Check if the canvas is still valid
      final Canvas canvas = context.canvas;
      if (canvas == null) return;

      // Save the initial canvas state
      canvas.saveLayer(rectOuter, Paint());

      // Paint the child first
      context.paintChild(child as RenderObject, offset);

      // Create shadow paint
      final Paint shadowPaint = Paint()
        ..blendMode = BlendMode.srcATop
        ..imageFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur)
        ..colorFilter = ColorFilter.mode(color, BlendMode.srcOut);

      // Apply shadow effect
      canvas.saveLayer(rectOuter, shadowPaint);
      canvas.saveLayer(rectInner, Paint());
      canvas.translate(dx, dy);

      // Paint child again for shadow effect
      context.paintChild(child as RenderObject, offset);

      // Restore canvas state
      canvas.restore();
      canvas.restore();
      canvas.restore();
    } catch (e) {
      // If there's an error, just paint the child normally
      if (child != null) {
        context.paintChild(child as RenderObject, offset);
      }
    }
  }
}
