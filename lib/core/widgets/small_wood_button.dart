import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../constants/colors.dart';

class SmallWoodButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final double? width;
  final double? height;

  const SmallWoodButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.width,
    this.height,
  });

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

              // Text Content
              // Adjusted padding to center text visually on the signboard
              Padding(
                padding: EdgeInsets.only(top: 1.0.h),
                child: Text(
                  widget.label,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 14.sp, // Increased font size
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
}
