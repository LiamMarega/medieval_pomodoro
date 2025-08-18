import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../providers/timer_provider.dart';

class MusicNotificationWidget extends ConsumerWidget {
  const MusicNotificationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerControllerProvider);

    // Show notification when music state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (timerState.isMusicEnabled != timerState.isMusicPlaying) {
        _showMusicNotification(context, timerState.isMusicEnabled);
      }
    });

    return const SizedBox.shrink(); // This widget doesn't render anything visible
  }

  void _showMusicNotification(BuildContext context, bool isMusicEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isMusicEnabled ? 'Medieval Music: ON' : 'Medieval Music: OFF',
          style: GoogleFonts.pressStart2p(fontSize: 8.sp),
        ),
        backgroundColor: isMusicEnabled ? AppTheme.successColor : AppTheme.textSecondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
