import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medieval_pomodoro/widgets/pixel_frame.dart';
import 'package:sizer/sizer.dart';

import '../../providers/timer_provider.dart';
import 'widgets/timer_header_widget.dart';
import 'widgets/timer_display_widget.dart';
import 'widgets/timer_controls_widget.dart';
import 'widgets/knight_illustration_widget.dart';
import 'widgets/motivational_message_widget.dart';
import 'widgets/music_notification_widget.dart';
import 'widgets/session_complete_dialog.dart';

class TimerScreenRefactored extends ConsumerWidget {
  const TimerScreenRefactored({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerControllerProvider);

    // Show session complete dialog when session changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (timerState.sessionNumber > 1 && !timerState.isActive) {
        _showSessionCompleteDialog(context, ref);
      }
    });

    return PixelFrame(
      cornerSize: 32,
      edgeThickness: 8,
      showBorder: false,
      showBottomBorder: false,
      padding: 16,
      borderStyle: MedievalBorderStyle.stone,
      child: Scaffold(
        backgroundColor: const Color(0xFF2D1B0F),
        body: Column(
          children: [
            const TimerHeaderWidget(),
            const TimerDisplayWidget(),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/sprites/dirt_sprite_2.png'),
                          fit: BoxFit.none,
                          repeat: ImageRepeat.repeat,
                          scale: 2,
                          filterQuality: FilterQuality.low,
                          colorFilter: ColorFilter.mode(
                            Color(0x6b2f01),
                            BlendMode.color,
                          ),
                          opacity: 0.5,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Colors.black,
                              width: 10,
                            ),
                            right: BorderSide(
                              color: Colors.black,
                              width: 10,
                            ),
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 5,
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.black.withValues(alpha: 0.5),
                                width: 5,
                              ),
                              right: BorderSide(
                                color: Colors.black.withValues(alpha: 0.5),
                                width: 5,
                              ),
                              bottom: BorderSide(
                                color: Colors.black.withValues(alpha: 0.5),
                                width: 5,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 10),
                              const TimerControlsWidget(),
                              const KnightIllustrationWidget(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const MotivationalMessageWidget(),
                ],
              ),
            ),
            const MusicNotificationWidget(),
          ],
        ),
      ),
    );
  }

  void _showSessionCompleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const SessionCompleteDialog();
      },
    );
  }
}
