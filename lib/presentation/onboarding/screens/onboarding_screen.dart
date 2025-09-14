import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/pixel_frame.dart';
import '../../../theme/app_theme.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/medieval_dialog_box.dart';

/// Pantalla principal de onboarding
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingControllerProvider);
    final onboardingController =
        ref.read(onboardingControllerProvider.notifier);
    final currentStep = onboardingController.getCurrentStep();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => onboardingController.nextStep(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Animación GIF en pantalla completa
            Image.asset(
              currentStep.animationPath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

            // Diálogo superpuesto
            Positioned(
              bottom: 0.h,
              width: 100.w,
              child: MedievalDialogBox(
                title: currentStep.dialogTitle ?? '',
                content: currentStep.dialogText,
              ),
            ),

            if (currentStep.hasForm && currentStep.formWidget != null)
              Positioned(
                bottom: 20.h,
                left: 10.w,
                right: 10.w,
                child: currentStep.formWidget!,
              ),
          ],
        ),
      ),
    );
  }
}

/// Botón para continuar al siguiente paso
class _ContinueButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLastStep;

  const _ContinueButton({
    required this.onTap,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PixelFrame(
        cornerSize: 16,
        edgeThickness: 4,
        padding: 15,
        borderStyle: MedievalBorderStyle.stone,
        child: Container(
          width: 100.w,
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: const Color(0xFF4A3728),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF5A4738),
                const Color(0xFF3A2718),
              ],
            ),
          ),
          child: Center(
            child: Text(
              isLastStep ? 'COMENZAR' : 'CONTINUAR',
              style: GoogleFonts.pressStart2p(
                fontSize: 12.sp,
                color: const Color(0xFFDAA520),
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
