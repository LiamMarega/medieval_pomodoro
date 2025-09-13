import 'package:flutter/material.dart';

import '../widgets/onboarding_form_widget.dart';

/// Modelo que representa un paso del onboarding
class OnboardingStep {
  /// Ruta de la animación GIF a mostrar
  final String animationPath;
  
  /// Texto del diálogo a mostrar
  final String dialogText;
  
  /// Título del diálogo (opcional)
  final String? dialogTitle;
  
  /// Indica si este paso tiene un formulario
  final bool hasForm;
  
  /// Widget del formulario (opcional)
  final Widget? formWidget;
  
  /// Constructor
  const OnboardingStep({
    required this.animationPath,
    required this.dialogText,
    this.dialogTitle,
    this.hasForm = false,
    this.formWidget,
  });
}

/// Clase que contiene los datos predefinidos para el onboarding
class OnboardingData {
  /// Lista de pasos del onboarding
  static final List<OnboardingStep> steps = [
    const OnboardingStep(
      animationPath: 'assets/animations/onboarding/knight_onboarding_1.gif',
      dialogTitle: 'Bienvenido, Caballero',
      dialogText: 'En un reino donde el tiempo es oro, un caballero debe aprender a administrarlo sabiamente...',
    ),
    const OnboardingStep(
      animationPath: 'assets/animations/onboarding/knight_onboarding_oldman_2.gif',
      dialogTitle: 'El Sabio Consejo',
      dialogText: 'El viejo sabio te enseñará la técnica ancestral del Pomodoro para maximizar tu concentración y productividad...',
    ),
    OnboardingStep(
      animationPath: 'assets/animations/onboarding/knight_onboarding_sword_3.gif',
      dialogTitle: 'Tu Misión Comienza',
      dialogText: 'Con tu nueva espada del tiempo, estás listo para conquistar tus tareas y vencer la procrastinación...',
      hasForm: true,
      formWidget: const OnboardingFormWidget(),
    ),
  ];
}