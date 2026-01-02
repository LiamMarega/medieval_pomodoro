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
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Evita que el tap en el signboard cierre el dialog
            child: SizedBox(
              width: screenWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Image - Full width
                    Image.asset(
                      'assets/sprites/wall-signboard.png',
                      width: screenWidth - 32,
                      fit: BoxFit.fitWidth,
                      filterQuality: FilterQuality.none,
                    ),

                    // Text Content - Centered within the signboard
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 32,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title
                          Text(
                            title,
                            style: GoogleFonts.pressStart2p(
                              fontSize: 16,
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
                          const SizedBox(height: 24),
                          // Message
                          Text(
                            message,
                            style: GoogleFonts.pressStart2p(
                              fontSize: 11,
                              color: Colors.white,
                              height: 1.8,
                              shadows: [
                                const Shadow(
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
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
      ),
    );
  }

  static void show(BuildContext context,
      {required String title, required String message}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.7),
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
