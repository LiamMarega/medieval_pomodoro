import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medieval_pomodoro/generated/locale_keys.g.dart';

import '../widgets/onboarding_form_widget.dart';

enum OnboardingStepType { dialog, nameInput, permissions }

/// Modelo que representa un paso del onboarding
class OnboardingStep {
  /// Ruta de la animación GIF a mostrar
  final String animationPath;

  /// Texto del diálogo a mostrar
  final String dialogText;

  /// Título del diálogo (opcional)
  final String? dialogTitle;

  /// Tipo de paso
  final OnboardingStepType type;

  /// Widget del formulario (opcional)
  final Widget? formWidget;

  /// Constructor
  OnboardingStep({
    required this.animationPath,
    required this.dialogText,
    this.dialogTitle,
    this.type = OnboardingStepType.dialog,
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
          type: OnboardingStepType.nameInput,
          formWidget: const OnboardingFormWidget(),
        ),
        OnboardingStep(
          animationPath: 'assets/animations/onboarding/knight_onboarding_1.gif',
          dialogTitle: LocaleKeys.onboarding_permissions_title.tr(),
          dialogText: LocaleKeys.onboarding_permissions_message.tr(),
          type: OnboardingStepType.permissions,
        ),
      ];
}
