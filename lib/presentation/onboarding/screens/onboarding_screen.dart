import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../providers/onboarding_provider.dart';
import '../widgets/medieval_dialog_box.dart';
import '../widgets/onboarding_form_widget.dart';

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
        onTap: () {
          // Solo permitir navegación si no hay formulario o si el formulario es válido
          if (!currentStep.hasForm || onboardingState.isFormValid) {
            onboardingController.nextStep();
          }
        },
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
              top: 0.h,
              width: 100.w,
              child: MedievalDialogBox(
                title: currentStep.dialogTitle ?? '',
                content: currentStep.dialogText,
              ),
            ),

            if (currentStep.hasForm && currentStep.formWidget != null)
              Positioned(
                bottom: 0.h,
                left: 0.w,
                right: 0.w,
                child: OnboardingFormWidget(
                  onNameSubmitted: (name) {
                    onboardingController.submitForm(name);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
