import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';

class MedievalSignboard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;

  const MedievalSignboard({
    super.key,
    required this.title,
    required this.message,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Image
              Image.asset(
                'assets/sprites/wall-signboard.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none, // Pixel perfect
              ),

              // Text Content
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      28, 48, 28, 28), // Tuned padding for visual alignment
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 14,
                          color: AppColors.primaryGold,
                          shadows: [
                            const Shadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Close functionality (tap anywhere on board to dismiss if needed, or external)
              // But usually this is an overlay.
            ],
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context,
      {required String title, required String message}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => MedievalSignboard(
        title: title,
        message: message,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: child,
        );
      },
    );
  }
}
