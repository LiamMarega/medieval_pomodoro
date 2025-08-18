import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class MusicSettingWidget extends ConsumerWidget {
  final bool isMusicEnabled;
  final Function(bool) onChanged;

  const MusicSettingWidget({
    super.key,
    required this.isMusicEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Background Music',
            style: GoogleFonts.pressStart2p(
              fontSize: 12.sp,
              color: const Color(0xFFDAA520),
            ),
          ),
          Switch(
            value: true,
            onChanged: onChanged,
            activeColor: const Color(0xFFDAA520),
            activeTrackColor: const Color(0xFFDAA520).withValues(alpha: 0.3),
            inactiveThumbColor: const Color(0xFF757575),
            inactiveTrackColor: const Color(0xFF757575).withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
