import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SessionCompleteNotification extends StatefulWidget {
  final String sessionType;
  final String nextSessionType;
  final VoidCallback? onDismiss;

  const SessionCompleteNotification({
    super.key,
    required this.sessionType,
    required this.nextSessionType,
    this.onDismiss,
  });

  @override
  State<SessionCompleteNotification> createState() =>
      _SessionCompleteNotificationState();
}

class _SessionCompleteNotificationState
    extends State<SessionCompleteNotification> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _slideController.forward();
    _pulseController.repeat(reverse: true);

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _slideController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWorkSession = widget.sessionType.toLowerCase().contains('work');

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF8B4513),
              const Color(0xFF654321),
              const Color(0xFF3E2723),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFD4AF37),
              width: 2,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                // Icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWorkSession
                              ? Icons.celebration
                              : Icons.self_improvement,
                          color: const Color(0xFFD4AF37),
                          size: 20.sp,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(width: 3.w),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.sessionType} Complete!',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4AF37),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Next: ${widget.nextSessionType}',
                        style: GoogleFonts.roboto(
                          fontSize: 9.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Close button
                GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
