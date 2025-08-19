import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../providers/timer_provider.dart';

class MusicNotificationWidget extends ConsumerStatefulWidget {
  const MusicNotificationWidget({super.key});

  @override
  ConsumerState<MusicNotificationWidget> createState() =>
      _MusicNotificationWidgetState();
}

class _MusicNotificationWidgetState
    extends ConsumerState<MusicNotificationWidget> {
  bool _lastMusicEnabled =
      true; // Default to true since music is enabled by default
  bool _hasShownNotification = false;

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerControllerProvider);

    // Show notification when music state changes, but only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentMusicEnabled = timerState.isMusicEnabled;

      // Only show notification if music enabled state changed and we haven't shown it yet
      if (currentMusicEnabled != _lastMusicEnabled && !_hasShownNotification) {
        debugPrint(
            'Music state changed: $_lastMusicEnabled -> $currentMusicEnabled');
        _showMusicNotification(context, currentMusicEnabled);
        _lastMusicEnabled = currentMusicEnabled;
        _hasShownNotification = true;

        // Reset the flag after a delay to allow future notifications
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _hasShownNotification = false;
            });
          }
        });
      }
    });

    return const SizedBox
        .shrink(); // This widget doesn't render anything visible
  }

  void _showMusicNotification(BuildContext context, bool isMusicEnabled) {
    debugPrint('Music notification: $isMusicEnabled');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isMusicEnabled ? 'Medieval Music: ON' : 'Medieval Music: OFF',
          style: GoogleFonts.pressStart2p(fontSize: 8.sp),
        ),
        backgroundColor:
            isMusicEnabled ? AppTheme.successColor : AppTheme.textSecondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
