import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medieval_pomodoro/generated/locale_keys.g.dart';

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
  OnboardingStep({
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
  static List<OnboardingStep> get steps => [
        OnboardingStep(
          animationPath: 'assets/animations/onboarding/knight_onboarding_1.gif',
          dialogTitle: LocaleKeys.onboarding_welcome_knight.tr(),
          dialogText: LocaleKeys.onboarding_welcome_knight_message.tr(),
        ),
        OnboardingStep(
          animationPath:
              'assets/animations/onboarding/knight_onboarding_oldman_2.gif',
          dialogTitle: LocaleKeys.onboarding_wise_counsel.tr(),
          dialogText: LocaleKeys.onboarding_wise_counsel_message.tr(),
        ),
        OnboardingStep(
          animationPath:
              'assets/animations/onboarding/knight_onboarding_sword_3.gif',
          dialogTitle: LocaleKeys.onboarding_your_mission_begins.tr(),
          dialogText: LocaleKeys.onboarding_your_mission_begins_message.tr(),
          hasForm: true,
          formWidget: const OnboardingFormWidget(),
        ),
      ];
}
