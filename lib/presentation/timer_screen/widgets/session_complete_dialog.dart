import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../providers/timer_provider.dart';

class SessionCompleteDialog extends ConsumerStatefulWidget {
  const SessionCompleteDialog({super.key});

  @override
  ConsumerState<SessionCompleteDialog> createState() =>
      _SessionCompleteDialogState();
}

class _SessionCompleteDialogState extends ConsumerState<SessionCompleteDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _scaleController.forward();
    _pulseController.repeat(reverse: true);

    // Auto-advance after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _startNextSession();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startNextSession() {
    final timerController = ref.read(timerControllerProvider.notifier);
    Navigator.of(context).pop();
    timerController.startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerControllerProvider);
    final isWorkSession = timerState.sessionType == 'Work';
    final nextSessionType = isWorkSession ? 'Break' : 'Work';

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 85.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD4AF37),
                  width: 3,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with crown
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(17),
                        topRight: Radius.circular(17),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isWorkSession ? Icons.work : Icons.coffee,
                          color: const Color(0xFFD4AF37),
                          size: 24.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${timerState.sessionType.toUpperCase()} COMPLETE!',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(5.w),
                    child: Column(
                      children: [
                        // Celebration icon
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37)
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFD4AF37),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  isWorkSession
                                      ? Icons.celebration
                                      : Icons.self_improvement,
                                  color: const Color(0xFFD4AF37),
                                  size: 32.sp,
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 3.h),

                        // Message
                        Text(
                          isWorkSession
                              ? 'Excellent work, noble knight!\nYour focus has been unwavering.'
                              : 'Well deserved rest, brave warrior!\nTime to recharge your spirit.',
                          style: GoogleFonts.roboto(
                            fontSize: 14.sp,
                            color: Colors.white,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 4.h),

                        // Next session indicator
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D1B0F),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFFD4AF37)
                                  .withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                nextSessionType == 'Work'
                                    ? Icons.work
                                    : Icons.coffee,
                                color: const Color(0xFFD4AF37),
                                size: 20.sp,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Next: $nextSessionType',
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 10.sp,
                                  color: const Color(0xFFD4AF37),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Auto-start indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 16.sp,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Auto-starting in 3 seconds...',
                              style: GoogleFonts.roboto(
                                fontSize: 10.sp,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
