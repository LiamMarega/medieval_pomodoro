import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MedievalKnightIllustration extends StatefulWidget {
  final bool isActive;
  final String sessionType;
  final double progress;

  const MedievalKnightIllustration({
    super.key,
    required this.isActive,
    required this.sessionType,
    required this.progress,
  });

  @override
  State<MedievalKnightIllustration> createState() =>
      _MedievalKnightIllustrationState();
}

class _MedievalKnightIllustrationState extends State<MedievalKnightIllustration>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _progressController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    if (widget.isActive) {
      _breathingController.repeat(reverse: true);
    }
    _progressController.forward();
  }

  @override
  void didUpdateWidget(MedievalKnightIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _breathingController.repeat(reverse: true);
      } else {
        _breathingController.stop();
      }
    }
    if (widget.progress != oldWidget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOut,
      ));
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: 30.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Background castle silhouette
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 15.h,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.1),
                    AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: CustomPaint(
                painter: CastlePainter(),
              ),
            ),
          ),
          // Knight character GIF
          Center(
            child: AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isActive ? _breathingAnimation.value : 1.0,
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/images/knight.gif',
                        fit: BoxFit.cover,
                        width: 40.w,
                        height: 40.w,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Progress indicator
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Container(
                  height: 1.h,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryLight,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppTheme.secondaryLight.withValues(alpha: 0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CastlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.borderColor
      ..style = PaintingStyle.fill;

    final path = Path();

    // Castle silhouette
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.6);
    path.lineTo(size.width * 0.1, size.height * 0.5);
    path.lineTo(size.width * 0.15, size.height * 0.3);
    path.lineTo(size.width * 0.25, size.height * 0.4);
    path.lineTo(size.width * 0.4, size.height * 0.2);
    path.lineTo(size.width * 0.6, size.height * 0.2);
    path.lineTo(size.width * 0.75, size.height * 0.4);
    path.lineTo(size.width * 0.85, size.height * 0.3);
    path.lineTo(size.width * 0.9, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.6);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
