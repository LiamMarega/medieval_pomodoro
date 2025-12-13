import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medieval_pomodoro/widgets/pixel_frame.dart';

import '../../generated/locale_keys.g.dart';
import '../../providers/timer_provider.dart';
import '../../providers/rewards_provider.dart';
import '../../core/services/live_activity_manager.dart';
import '../../constants/colors.dart';
import 'widgets/timer_header_widget.dart';
import 'widgets/timer_display_widget.dart';
import 'widgets/timer_controls_widget.dart';
import 'widgets/knight_illustration_widget.dart';
import 'widgets/motivational_message_widget.dart';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../core/services/notification_service.dart';
import '../../services/app_blocker_service.dart';
import 'widgets/music_notification_widget.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenRefactoredState();
}

class _TimerScreenRefactoredState extends ConsumerState<TimerScreen> {
  String? _lastSessionType;
  int _lastSessionNumber = 0;
  bool _showNotification = false;
  LiveActivityManager? _liveActivityManager;

  @override
  void initState() {
    super.initState();
    _initializeLiveActivity();
  }

  Future<void> _initializeLiveActivity() async {
    try {
      _liveActivityManager = LiveActivityManager();
      await _liveActivityManager!.init();

      // Create initial live activity
      await _liveActivityManager!.createFocusActivity(
        userName: "Liam", // O obtenerlo de SharedPreferences
        sessionType: "Focus",
        currentSession: 1,
        timeRemaining: 1500, // 25 minutes
        paused: false,
      );
    } catch (e) {
      debugPrint('❌ Error initializing Live Activity: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerControllerProvider);

    // Listen for reward events and show modals
    ref.listen<RewardsState>(rewardsControllerProvider, (previous, next) {
      final ev = next.lastEvent;
      if (ev != null && mounted) {
        // Show reward modal
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.primaryBackground,
            title: Text(
              ev.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              ev.description,
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref
                      .read(rewardsControllerProvider.notifier)
                      .consumeLastEvent();
                  Navigator.pop(context);
                },
                child: Text(
                  LocaleKeys.timer_screen_ok_button.tr(),
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });

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

        // Hide notification after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showNotification = false;
            });
          }
        });
      }

      _lastSessionType = timerState.currentMode.displayName;
      _lastSessionNumber = timerState.sessionNumber;

      // Check permissions
      _checkPermissions();
    });
    return PixelFrame(
      cornerSize: 32,
      edgeThickness: 8,
      showBorder: false,
      showBottomBorder: false,
      padding: 16,
      borderStyle: MedievalBorderStyle.stone,
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: Stack(
          children: [
            Column(
              children: [
                const TimerHeaderWidget(),
                TimerDisplayWidget(),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: const AssetImage(
                                  'assets/sprites/dirt_sprite_2.png'),
                              fit: BoxFit.none,
                              repeat: ImageRepeat.repeat,
                              scale: 2,
                              filterQuality: FilterQuality.low,
                              colorFilter: const ColorFilter.mode(
                                AppColors.filterBrownRed,
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
                                    child: KnightIllustrationWidget(),
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
          ],
        ),
      ),
    );
  }

  Future<void> _checkPermissions() async {
    // Don't check if we already showed it this session or if timer is active
    if (ref.read(timerControllerProvider).isActive) return;

    try {
      final notificationService = NotificationService();
      final appBlockerService = AppBlockerService();

      // Check permissions with timeout to prevent hanging
      bool notificationsAllowed = false;
      try {
        notificationsAllowed = await AwesomeNotifications()
            .isNotificationAllowed()
            .timeout(const Duration(seconds: 2), onTimeout: () => true);
      } catch (e) {
        debugPrint('⚠️ Error checking notification permission: $e');
        notificationsAllowed = true; // Assume granted to avoid blocking user
      }

      // If any permission is missing, show dialog
      if (!notificationsAllowed) {
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: PixelFrame(
              cornerSize: 16,
              edgeThickness: 4,
              padding: 20,
              borderStyle: MedievalBorderStyle.stone,
              child: Container(
                padding: EdgeInsets.all(2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1B0A).withValues(alpha: 0.95),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      LocaleKeys.onboarding_permissions_title.tr(),
                      style: GoogleFonts.pressStart2p(
                        fontSize: 12.sp,
                        color: const Color(0xFFDAA520),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      LocaleKeys.onboarding_permissions_message.tr(),
                      style: GoogleFonts.vt323(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 3.h),
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        // Request permissions with robust error handling
                        try {
                          await notificationService.requestPermissions();
                        } catch (e) {
                          debugPrint('⚠️ Notification permission failed: $e');
                        }

                        // Request iOS Screen Time permissions if on iOS
                        if (Platform.isIOS) {
                          try {
                            await appBlockerService.requestPermission();
                          } catch (e) {
                            debugPrint('⚠️ App blocker permission failed: $e');
                            // Don't show error to user, just log it
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.5.h, horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A3728),
                          border: Border.all(
                              color: const Color(0xFFDAA520), width: 2),
                        ),
                        child: Text(
                          LocaleKeys.onboarding_grant_permissions.tr(),
                          style: GoogleFonts.pressStart2p(
                            fontSize: 10.sp,
                            color: const Color(0xFFDAA520),
                          ),
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
    } catch (e) {
      debugPrint('❌ Error in _checkPermissions: $e');
      // Silent failure - don't block the user from using the app
    }
  }

  @override
  void dispose() {
    _liveActivityManager?.endActivity();
    super.dispose();
  }
}
