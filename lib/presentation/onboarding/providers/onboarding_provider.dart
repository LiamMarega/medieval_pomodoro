import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/local_storage_service.dart';
import '../models/onboarding_step.dart';

part 'onboarding_provider.g.dart';

/// Estado del onboarding
class OnboardingState {
  /// Índice del paso actual
  final int currentStepIndex;

  /// Indica si el onboarding ha sido completado
  final bool isCompleted;

  /// Indica si se está cargando algo
  final bool isLoading;

  /// Mensaje de error (si hay alguno)
  final String? error;

  /// Nombre del usuario ingresado en el formulario
  final String? userName;

  /// Indica si el formulario actual es válido
  final bool isFormValid;

  /// Constructor
  const OnboardingState({
    this.currentStepIndex = 0,
    this.isCompleted = false,
    this.isLoading = false,
    this.error,
    this.userName,
    this.isFormValid = false,
  });

  /// Método para crear una copia con algunos valores modificados
  OnboardingState copyWith({
    int? currentStepIndex,
    bool? isCompleted,
    bool? isLoading,
    String? error,
    String? userName,
    bool? isFormValid,
  }) {
    return OnboardingState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userName: userName ?? this.userName,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  /// Avanza al siguiente paso del onboarding
  Future<void> nextStep() async {
    final currentIndex = state.currentStepIndex;
    final totalSteps = OnboardingData.steps.length;
    final currentStep = OnboardingData.steps[currentIndex];

    // Si el paso actual tiene formulario, verificar que sea válido
    if (currentStep.hasForm && !state.isFormValid) {
      debugPrint('No se puede avanzar: formulario incompleto');
      return;
    }

    if (currentIndex < totalSteps - 1) {
      // Avanzar al siguiente paso
      state = state.copyWith(currentStepIndex: currentIndex + 1);
      debugPrint('Avanzando al paso ${currentIndex + 1} del onboarding');
    } else {
      // Completar el onboarding
      await completeOnboarding();
    }
  }

  /// Retrocede al paso anterior del onboarding
  void previousStep() {
    final currentIndex = state.currentStepIndex;

    if (currentIndex > 0) {
      state = state.copyWith(currentStepIndex: currentIndex - 1);
      debugPrint('Retrocediendo al paso ${currentIndex - 1} del onboarding');
    }
  }

  /// Marca el onboarding como completado
  Future<void> completeOnboarding() async {
    debugPrint('🎯 Iniciando completado del onboarding...');
    state = state.copyWith(isCompleted: true);
    debugPrint('✅ Onboarding completado - estado actualizado');

    // Guardar en almacenamiento local que el onboarding ha sido completado
    final storageService = await LocalStorageService.getInstance();
    final saved = await storageService.saveOnboardingCompleted(true);
    debugPrint('💾 Onboarding completed status saved: $saved');

    // Guardar el nombre del usuario si está disponible
    if (state.userName != null && state.userName!.isNotEmpty) {
      final userNameSaved = await storageService.saveUserName(state.userName!);
      debugPrint('👤 User name saved: $userNameSaved');
    }

    debugPrint(
        '🚀 Onboarding completamente finalizado - debería navegar al TimerScreen');
  }

  /// Reinicia el onboarding
  void resetOnboarding() {
    state = const OnboardingState();
    debugPrint('Onboarding reiniciado');
  }

  /// Obtiene el paso actual del onboarding
  OnboardingStep getCurrentStep() {
    return OnboardingData.steps[state.currentStepIndex];
  }

  /// Maneja la presentación del formulario
  Future<void> submitForm(String userName) async {
    if (userName.trim().length >= 3) {
      state = state.copyWith(
        userName: userName.trim(),
        isFormValid: true,
      );
      debugPrint('Formulario completado con nombre: $userName');

      // Avanzar al siguiente paso después de completar el formulario
      await nextStep();
    } else {
      debugPrint('Nombre inválido: debe tener al menos 3 caracteres');
    }
  }
}
