import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../constants/colors.dart';

class SmallWoodButton extends StatefulWidget {
  final String? label;
  final String? iconPath;
  final bool isMuted;
  final VoidCallback onTap;
  final bool isSelected;
  final double? width;
  final double? height;

  const SmallWoodButton({
    super.key,
    this.label,
    this.iconPath,
    this.isMuted = false,
    required this.onTap,
    this.isSelected = false,
    this.width,
    this.height,
  }) : assert(label != null || iconPath != null,
            'Either label or iconPath must be provided');

  @override
  State<SmallWoodButton> createState() => _SmallWoodButtonState();
}

class _SmallWoodButtonState extends State<SmallWoodButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (!_isPressed) {
      setState(() => _isPressed = true);
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: widget.width ?? 35.w,
          height: widget.height ?? 10.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Sprite
              Image.asset(
                'assets/sprites/rope-signboard.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                filterQuality: FilterQuality.none,
              ),

              // Content - Icon or Text
              Padding(
                padding: EdgeInsets.only(top: 1.0.h),
                child: widget.iconPath != null
                    ? _buildIconContent()
                    : Text(
                        widget.label!,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 14.sp,
                          color: widget.isSelected
                              ? AppColors.primaryGold
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContent() {
    final iconSize = 5.h;
    final isSvg = widget.iconPath!.toLowerCase().endsWith('.svg');

    Widget iconWidget;
    if (isSvg) {
      iconWidget = SvgPicture.asset(
        widget.iconPath!,
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(
          widget.isMuted
              ? AppColors.textSecondary.withValues(alpha: 0.6)
              : (widget.isSelected ? AppColors.primaryGold : AppColors.textPrimary),
          BlendMode.srcIn,
        ),
      );
    } else {
      iconWidget = Image.asset(
        widget.iconPath!,
        width: iconSize,
        height: iconSize,
        filterQuality: FilterQuality.none,
      );
      
      // Apply grayscale + reduced opacity when muted (preserves transparency)
      if (widget.isMuted) {
        iconWidget = ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0,      0,      0,      0.6, 0,
          ]),
          child: iconWidget,
        );
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        iconWidget,
        // Diagonal line when muted
        if (widget.isMuted)
          CustomPaint(
            size: Size(iconSize, iconSize),
            painter: _MutedLinePainter(),
          ),
      ],
    );
  }
}

/// Custom painter to draw a diagonal line across the icon when muted
class _MutedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.error
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw diagonal line from top-right to bottom-left
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.85),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
