import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/local_storage_service.dart';
import 'onboarding.dart';
import 'providers/onboarding_provider.dart';

/// Clase para integrar el onboarding en la aplicación principal
class OnboardingIntegration {
  /// Verifica si se debe mostrar el onboarding
  /// Verifica en el almacenamiento local si el onboarding ya ha sido completado
  static Future<bool> shouldShowOnboarding() async {
    final storageService = await LocalStorageService.getInstance();
    return !storageService.isOnboardingCompleted();
  }
  
  /// Muestra el onboarding o la pantalla principal según corresponda
  static Widget buildInitialScreen(Widget mainApp) {
    return FutureBuilder<bool>(
      future: shouldShowOnboarding(),
      builder: (context, snapshot) {
        // Mientras se carga, muestra una pantalla de carga o la app principal
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final shouldShow = snapshot.data!;
        
        if (!shouldShow) {
          // Si no se debe mostrar el onboarding, muestra la app principal
          return mainApp;
        }
        
        // Si se debe mostrar el onboarding, usa el Consumer para manejar su estado
        return Consumer(
          builder: (context, ref, _) {
            final onboardingState = ref.watch(onboardingControllerProvider);
            
            // Si el onboarding está completado durante la sesión, muestra la app principal
            if (onboardingState.isCompleted) {
              return mainApp;
            }
            
            // De lo contrario, muestra la pantalla de onboarding
            return const OnboardingScreen();
          },
        );
      },
    );
  }
}