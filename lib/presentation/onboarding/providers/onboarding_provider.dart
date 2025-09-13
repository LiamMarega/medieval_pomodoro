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

  /// Constructor
  const OnboardingState({
    this.currentStepIndex = 0,
    this.isCompleted = false,
    this.isLoading = false,
    this.error,
  });

  /// Método para crear una copia con algunos valores modificados
  OnboardingState copyWith({
    int? currentStepIndex,
    bool? isCompleted,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error,
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
    state = state.copyWith(isCompleted: true);
    debugPrint('Onboarding completado');
    
    // Guardar en almacenamiento local que el onboarding ha sido completado
    final storageService = await LocalStorageService.getInstance();
    await storageService.saveOnboardingCompleted(true);
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
}