import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medieval_pomodoro/widgets/pixel_frame.dart';

import '../../providers/timer_provider.dart';
import 'widgets/timer_header_widget.dart';
import 'widgets/timer_display_widget.dart';
import 'widgets/timer_controls_widget.dart';
import 'widgets/knight_illustration_widget.dart';
import 'widgets/motivational_message_widget.dart';
import 'widgets/music_notification_widget.dart';
import 'widgets/session_complete_notification.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenRefactoredState();
}

class _TimerScreenRefactoredState extends ConsumerState<TimerScreen> {
  String? _lastSessionType;
  int _lastSessionNumber = 0;
  bool _showNotification = false;

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerControllerProvider);

    // Check if session just completed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show notification when session number increases and timer is not active
      if (timerState.sessionNumber > _lastSessionNumber &&
          !timerState.isActive &&
          !_showNotification) {
        setState(() {
          _showNotification = true;
          _lastSessionType =
              _lastSessionType ?? 'Work'; // Use previous session type
        });
      }

      _lastSessionType = timerState.currentMode.displayName;
      _lastSessionNumber = timerState.sessionNumber;
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
        body: Stack(
          children: [
            Column(
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
                              image: AssetImage(
                                  'assets/sprites/dirt_sprite_2.png'),
                              fit: BoxFit.none,
                              repeat: ImageRepeat.repeat,
                              scale: 2,
                              filterQuality: FilterQuality.low,
                              colorFilter: ColorFilter.mode(
                                Color(0x006b2f01),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 16),
                                  const TimerControlsWidget(),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: KnightIllustrationWidget(
                                      currentMode: timerState.currentMode,
                                      currentAnimation:
                                          timerState.currentAnimation,
                                      onTransitionComplete: () {
                                        // Callback opcional cuando termina la transición
                                        debugPrint(
                                            '🎭 Knight animation transition completed');
                                      },
                                    ),
                                  ),
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
            // Session complete notification overlay
            if (_showNotification && _lastSessionType != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SessionCompleteNotification(
                  sessionType: _lastSessionType!,
                  nextSessionType: timerState.currentMode.displayName,
                  onDismiss: () {
                    setState(() {
                      _showNotification = false;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
