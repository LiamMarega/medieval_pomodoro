import 'package:flutter/material.dart';

/// A sophisticated widget that creates pixel-perfect medieval borders using the provided sprites.
/// This system uses corner, edge, and border sprites to create seamless frames that match
/// the medieval aesthetic of the reference image.
class PixelFrame extends StatelessWidget {
  final Widget child;
  final double cornerSize; // Size of corner pieces (e.g., 16, 24, 32)
  final double edgeThickness; // Thickness of edge borders (e.g., 4, 6, 8)
  final double padding; // Internal padding for content
  final MedievalBorderStyle borderStyle; // Different border styles
  final bool showTopBorder;
  final bool showBottomBorder;
  final bool showLeftBorder;
  final bool showRightBorder;
  final bool showBorder;
  final bool showLeftShadow;
  final bool showRightShadow;

  const PixelFrame({
    super.key,
    required this.child,
    this.cornerSize = 24,
    this.edgeThickness = 6,
    this.padding = 12,
    this.borderStyle = MedievalBorderStyle.stone,
    this.showTopBorder = true,
    this.showBottomBorder = true,
    this.showLeftBorder = true,
    this.showRightBorder = true,
    this.showBorder = true,
    this.showLeftShadow = true,
    this.showRightShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final assets = _getBorderAssets();

    return LayoutBuilder(
      builder: (_, constraints) {
        return Stack(
          children: [
            // Content with proper padding (no background color)
            Padding(
              padding: EdgeInsets.only(
                top: showTopBorder ? padding : 0,
                bottom: showBottomBorder ? padding : 0,
                left: showLeftBorder ? padding : 0,
                right: showRightBorder ? padding : 0,
              ),
              child: child,
            ),

            // --- CORNER PIECES ---
            // Top-left corner (only if top and left borders are enabled)
            if (showTopBorder && showLeftBorder)
              Positioned(
                left: 0,
                top: 0,
                width: 20,
                height: 20,
                child: IgnorePointer(
                  child: _pixelPerfect(Image.asset(
                    assets.corner,
                    filterQuality: FilterQuality.none,
                    fit: BoxFit.fill,
                  )),
                ),
              ),

            // Top-right corner (only if top and right borders are enabled)
            if (showTopBorder && showRightBorder)
              Positioned(
                right: 0,
                top: 0,
                width: 20,
                height: 20,
                child: IgnorePointer(
                  child: _pixelPerfect(Transform.flip(
                    flipX: true,
                    child: Image.asset(
                      assets.corner,
                      filterQuality: FilterQuality.none,
                      fit: BoxFit.fill,
                    ),
                  )),
                ),
              ),

            // Bottom-left corner (only if bottom and left borders are enabled)
            if (showBottomBorder && showLeftBorder)
              Positioned(
                left: 0,
                bottom: 0,
                width: 20,
                height: 20,
                child: IgnorePointer(
                  child: _pixelPerfect(Transform.flip(
                    flipY: true,
                    child: Image.asset(
                      assets.corner,
                      filterQuality: FilterQuality.none,
                      fit: BoxFit.fill,
                    ),
                  )),
                ),
              ),

            // Bottom-right corner (only if bottom and right borders are enabled)
            if (showBottomBorder && showRightBorder)
              Positioned(
                right: 0,
                bottom: 0,
                width: 20,
                height: 20,
                child: IgnorePointer(
                  child: _pixelPerfect(Transform.flip(
                    flipX: true,
                    flipY: true,
                    child: Image.asset(
                      assets.corner,
                      filterQuality: FilterQuality.none,
                      fit: BoxFit.fill,
                    ),
                  )),
                ),
              ),

            // --- HORIZONTAL EDGES ---
            // Top horizontal edge
            if (showTopBorder)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 20, // Fixed brick height
                child: IgnorePointer(
                  child: _buildRepeatingEdge(
                      assets.horizontalEdge, ImageRepeat.repeatX),
                ),
              ),

            // Bottom horizontal edge
            if (showBottomBorder)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 20, // Fixed brick height
                child: IgnorePointer(
                  child: Transform.flip(
                    flipY: true,
                    child: _buildRepeatingEdge(
                        assets.horizontalEdge, ImageRepeat.repeatX),
                  ),
                ),
              ),

            // --- VERTICAL EDGES ---
            // Left vertical edge
            if (showLeftBorder)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: 20, // Fixed brick width
                child: IgnorePointer(
                  child: _buildRepeatingEdge(
                      assets.verticalEdge, ImageRepeat.repeatY),
                ),
              ),

            // Right vertical edge
            if (showRightBorder)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: 20, // Fixed brick width
                child: IgnorePointer(
                  child: Transform.flip(
                    flipX: true,
                    child: _buildRepeatingEdge(
                        assets.verticalEdge, ImageRepeat.repeatY),
                  ),
                ),
              ),

            // Black border (on top of everything)
            if (showBorder)
              Positioned(
                top: showTopBorder ? 20 : 0,
                bottom: showBottomBorder ? 20 : 0,
                left: showLeftBorder ? 20 : 0,
                right: showRightBorder ? 20 : 0,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: showTopBorder
                            ? BorderSide(
                                color: Colors.black.withValues(alpha: 1),
                                width: 5.0)
                            : BorderSide.none,
                        bottom: BorderSide(
                            color: Colors.black.withValues(alpha: 1),
                            width: 5.0),
                        left: showLeftBorder || showLeftShadow
                            ? BorderSide(
                                color: Colors.black.withValues(alpha: 1),
                                width: 5.0)
                            : BorderSide.none,
                        right: showRightBorder || showRightShadow
                            ? BorderSide(
                                color: Colors.black.withValues(alpha: 1),
                                width: 5.0)
                            : BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

            // Second black border with opacity (more inward)
            if (showBorder)
              Positioned(
                top: showTopBorder ? 25 : 5,
                bottom: showBottomBorder ? 25 : 5,
                left: showLeftBorder ? 25 : 5,
                right: showRightBorder ? 25 : 5,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                      top: showTopBorder
                          ? BorderSide(
                              color: Colors.black.withValues(alpha: 0.5),
                              width: 5.0)
                          : BorderSide.none,
                      bottom: BorderSide(
                          color: Colors.black.withValues(alpha: 0.5),
                          width: 5.0),
                      left: showLeftBorder || showLeftShadow
                          ? BorderSide(
                              color: Colors.black.withValues(alpha: 0.5),
                              width: 5.0)
                          : BorderSide.none,
                      right: showRightBorder || showRightShadow
                          ? BorderSide(
                              color: Colors.black.withValues(alpha: 0.5),
                              width: 5.0)
                          : BorderSide.none,
                    )),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRepeatingEdge(String assetPath, ImageRepeat repeat) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isHorizontal = repeat == ImageRepeat.repeatX;

        if (isHorizontal) {
          // For horizontal edges, use individual bricks
          final brickSize = 20.0;
          final containerSize = constraints.maxWidth;
          final brickCount = (containerSize / brickSize).floor();

          return ClipRect(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(brickCount, (index) {
                return SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(
                    assetPath,
                    filterQuality: FilterQuality.none,
                    fit: BoxFit.fill,
                  ),
                );
              }),
            ),
          );
        } else {
          // For vertical edges, use individual bricks rotated
          final brickSize = 20.0;
          final containerSize = constraints.maxHeight;
          final brickCount = (containerSize / brickSize).floor();

          return ClipRect(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(brickCount, (index) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: 20,
                  child: Transform.rotate(
                    angle: 1.5708, // 90 degrees in radians (π/2)
                    child: Image.asset(
                      assetPath,
                      filterQuality: FilterQuality.none,
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              }),
            ),
          );
        }
      },
    );
  }

  /// Ensures pixel-perfect rendering
  Widget _pixelPerfect(Widget child) => FittedBox(
        fit: BoxFit.fill,
        child: child,
      );

  /// Get the appropriate border assets based on the style
  _BorderAssets _getBorderAssets() {
    return _BorderAssets(
      corner: 'assets/sprites/brick.png',
      horizontalEdge: 'assets/sprites/brick.png',
      verticalEdge: 'assets/sprites/brick.png',
      borderBlock: 'assets/sprites/brick.png',
    );
  }
}

/// Different medieval border styles
enum MedievalBorderStyle {
  stone,
}

/// Container for border asset paths
class _BorderAssets {
  final String corner;
  final String horizontalEdge;
  final String verticalEdge;
  final String borderBlock;

  _BorderAssets({
    required this.corner,
    required this.horizontalEdge,
    required this.verticalEdge,
    required this.borderBlock,
  });
}
