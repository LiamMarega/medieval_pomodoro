import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medieval_pomodoro/models/timer_mode.dart';
import 'package:sizer/sizer.dart';

import '../../../providers/timer_provider.dart';

class TimerDisplayWidget extends ConsumerStatefulWidget {
  const TimerDisplayWidget({
    super.key,
  });

  @override
  ConsumerState<TimerDisplayWidget> createState() => _TimerDisplayWidgetState();
}

class _TimerDisplayWidgetState extends ConsumerState<TimerDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    // Create a stepped animation for retro game effect (10 FPS)
    const int framesPerSecond = 30;
    const int totalFrames =
        5 * framesPerSecond; // 5 seconds * 10 FPS = 50 frames

    _slideAnimation = Tween<double>(
      begin: -2.0, // Start completely off-screen to the left
      end: 2.0, // End 200% off-screen to the right
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: _SteppedCurve(totalFrames),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerControllerProvider);

    // Start animation when in gap time mode
    if (timerState.currentMode == TimerMode.gapTime) {
      _animationController.repeat();
    } else {
      _animationController.stop();
      _animationController.reset();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 5,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(2.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.5),
            width: 5,
          ),
        ),
        child: timerState.currentMode == TimerMode.gapTime
            ? ClipRect(
                child: SizedBox(
                  width: double.infinity,
                  // height: 40.sp, // Fixed height to prevent layout shifts
                  child: AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          _slideAnimation.value *
                              MediaQuery.of(context).size.width,
                          0,
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width *
                              3, // Allow text to extend beyond screen
                          child: Text(
                            "BREAK TIME",
                            style: GoogleFonts.pressStart2p(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.normal,
                              color: const Color(0xFFDAA520),
                              letterSpacing: 4.0,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  offset: const Offset(4, 4),
                                  blurRadius: 8,
                                ),
                                Shadow(
                                  color: const Color(0xFFDAA520)
                                      .withValues(alpha: 0.5),
                                  offset: const Offset(-2, -2),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            overflow: TextOverflow.visible,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            : Text(
                _formatTime(timerState.currentSeconds),
                style: GoogleFonts.pressStart2p(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFFDAA520),
                  letterSpacing: 4.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      offset: const Offset(4, 4),
                      blurRadius: 8,
                    ),
                    Shadow(
                      color: const Color(0xFFDAA520).withValues(alpha: 0.5),
                      offset: const Offset(-2, -2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

// Custom curve that creates stepped animation for retro game effect
class _SteppedCurve extends Curve {
  final int steps;

  const _SteppedCurve(this.steps);

  @override
  double transform(double t) {
    // Create discrete steps
    final step = (t * steps).floor();
    return step / steps;
  }
}
