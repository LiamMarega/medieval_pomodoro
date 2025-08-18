import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/pixel_frame.dart';
import '../../../providers/timer_provider.dart';

class MotivationalMessageWidget extends ConsumerWidget {
  const MotivationalMessageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerControllerProvider);

    return PixelFrame(
      cornerSize: 20,
      edgeThickness: 5,
      padding: 12,
      borderStyle: MedievalBorderStyle.stone,
      child: SizedBox(
        height: 15.h,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                    ),
                    child: Text(
                      timerState.currentMotivationalMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 8.sp,
                        color: const Color(0xFFB8860B),
                        letterSpacing: 1.0,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
