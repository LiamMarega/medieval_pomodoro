import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif/gif.dart';
import 'package:sizer/sizer.dart';

import '../providers/onboarding_provider.dart';
import '../widgets/medieval_dialog_box.dart';
import '../widgets/onboarding_form_widget.dart';

/// Pantalla principal de onboarding
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  GifController? _gifController;
  late final AnimationController _pingPongController;

  @override
  void initState() {
    super.initState();

    // Controlador para el efecto ping-pong
    _pingPongController = AnimationController(
      vsync: this,
      duration: const Duration(
          seconds: 4), // Duración del ciclo completo (ida y vuelta)
    )..repeat(reverse: true);

    // Escuchar cambios en el ping-pong controller para controlar el GIF
    _pingPongController.addListener(_handlePingPongAnimation);
  }

  void _handlePingPongAnimation() {
    if (_gifController == null) return;

    // Mapear el valor del ping-pong controller (0.0 a 1.0 y vuelta) al frame del GIF
    // Cuando va hacia adelante: 0.0 -> 1.0 (frames 0 a N)
    // Cuando va hacia atrás: 1.0 -> 0.0 (frames N a 0)
    // El GifController.value va de 0.0 (primer frame) a 1.0 (último frame)
    _gifController!.value = _pingPongController.value;
  }

  @override
  void dispose() {
    _pingPongController.dispose();
    _gifController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            // Image.asset(
            //   currentStep.animationPath,
            //   fit: BoxFit.cover,
            //   width: double.infinity,
            //   height: double.infinity,
            //   filterQuality: FilterQuality.high,
            // ),

            Gif(
              image: AssetImage(currentStep.animationPath),
              controller: _gifController ??= GifController(vsync: this),
              autostart: Autostart.no,
              fps: 8, // Reducido de 24 a 12 para que vaya más lento
              repeat: ImageRepeat.noRepeat,
              fit: BoxFit.cover,
              placeholder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
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
