import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/notification_service.dart';
import '../../../services/app_blocker_service.dart';
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

  /// Indica si los permisos han sido concedidos
  final bool arePermissionsGranted;

  /// Constructor
  const OnboardingState({
    this.currentStepIndex = 0,
    this.isCompleted = false,
    this.isLoading = false,
    this.error,
    this.userName,
    this.isFormValid = false,
    this.arePermissionsGranted = false,
  });

  /// Método para crear una copia con algunos valores modificados
  OnboardingState copyWith({
    int? currentStepIndex,
    bool? isCompleted,
    bool? isLoading,
    String? error,
    String? userName,
    bool? isFormValid,
    bool? arePermissionsGranted,
  }) {
    return OnboardingState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userName: userName ?? this.userName,
      isFormValid: isFormValid ?? this.isFormValid,
      arePermissionsGranted:
          arePermissionsGranted ?? this.arePermissionsGranted,
    );
  }
}

@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  OnboardingState build() {
    // Cargar el nombre del usuario desde el almacenamiento local si existe
    // Se hace de forma asíncrona sin bloquear la inicialización
    Future.microtask(() => _loadUserNameFromStorage());
    return const OnboardingState();
  }

  /// Carga el nombre del usuario desde el almacenamiento local
  Future<void> _loadUserNameFromStorage() async {
    try {
      final storageService = await LocalStorageService.getInstance();
      final savedUserName = storageService.getUserName();
      if (savedUserName != null && savedUserName.isNotEmpty) {
        state = state.copyWith(
          userName: savedUserName,
          isFormValid: true,
        );
        debugPrint('👤 User name loaded from storage: $savedUserName');
      }
    } catch (e) {
      debugPrint('❌ Error loading user name from storage: $e');
    }
  }

  /// Avanza al siguiente paso del onboarding
  Future<void> nextStep() async {
    final currentIndex = state.currentStepIndex;
    final totalSteps = OnboardingData.steps.length;
    final currentStep = OnboardingData.steps[currentIndex];

    // Si el paso actual tiene formulario, verificar que sea válido
    if (currentStep.type == OnboardingStepType.nameInput &&
        !state.isFormValid) {
      debugPrint('No se puede avanzar: formulario incompleto');
      return;
    }

    // Si el paso actual es de permisos, verificar que estén concedidos
    if (currentStep.type == OnboardingStepType.permissions &&
        !state.arePermissionsGranted) {
      debugPrint('No se puede avanzar: permisos no concedidos');
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

  /// Solicita los permisos necesarios
  Future<void> requestPermissions() async {
    state = state.copyWith(isLoading: true);

    try {
      debugPrint('🛡️ Requesting permissions...');
      final appBlocker = AppBlockerService();

      // Request app blocker permissions (iOS Screen Time)
      // AppBlockerService handles platform checks internally
      try {
        await appBlocker.requestPermission();
      } catch (e) {
        debugPrint(
            '⚠️ App blocker permission request failed (non-critical): $e');
        // Don't rethrow - Permission requests can fail if denied or called incorrectly
        // We just log and continue, user can retry later if needed
      }

      // Request notification permissions
      try {
        debugPrint('🔔 Requesting notification permissions...');
        await NotificationService().requestPermissions();
      } catch (e) {
        debugPrint(
            '⚠️ Notification permission request failed (non-critical): $e');
      }

      // Always mark as granted (user can retry later in TimerScreen if needed)
      state = state.copyWith(
        isLoading: false,
        arePermissionsGranted: true,
      );
      debugPrint('✅ Permissions granted state updated');
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      // Even if there's an error, mark as "granted" to allow user to proceed
      // They can be prompted again in TimerScreen if truly needed
      state = state.copyWith(
        isLoading: false,
        arePermissionsGranted: true,
      );
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
      final trimmedName = userName.trim();
      state = state.copyWith(
        userName: trimmedName,
        isFormValid: true,
      );
      debugPrint('Formulario completado con nombre: $trimmedName');

      // Guardar el nombre inmediatamente en almacenamiento local para persistencia
      final storageService = await LocalStorageService.getInstance();
      final userNameSaved = await storageService.saveUserName(trimmedName);
      debugPrint('👤 User name saved immediately: $userNameSaved');

      // Avanzar al siguiente paso después de completar el formulario
      await nextStep();
    } else {
      debugPrint('Nombre inválido: debe tener al menos 3 caracteres');
    }
  }
}
