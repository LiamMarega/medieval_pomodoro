import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../constants/colors.dart';

class LargeWoodButton extends StatefulWidget {
  final String label;
  final String? icon;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? textColor;
  final double? width;
  final double? height;

  const LargeWoodButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isSelected = false,
    this.textColor,
    this.width,
    this.height,
  });

  @override
  State<LargeWoodButton> createState() => _LargeWoodButtonState();
}

class _LargeWoodButtonState extends State<LargeWoodButton> {
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
    // Determine text color
    final color = widget.textColor ??
        (widget.isSelected ? AppColors.primaryGold : AppColors.textPrimary);

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
                'assets/sprites/wall-signboard.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                filterQuality: FilterQuality.none,
              ),

              // Content
              Padding(
                padding: EdgeInsets.only(top: 1.5.h, left: 1.w, right: 1.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          widget.label,
                          maxLines: 3,
                          style: GoogleFonts.pressStart2p(
                            fontSize: 14.sp,
                            color: color,
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
