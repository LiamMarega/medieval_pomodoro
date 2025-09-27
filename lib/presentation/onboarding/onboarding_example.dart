import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_integration.dart';

/// Ejemplo de cómo integrar el onboarding en la aplicación principal
class OnboardingExample extends StatelessWidget {
  const OnboardingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Medieval Pomodoro',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: OnboardingIntegration.buildInitialScreen(
          // Esta sería la pantalla principal de la aplicación
          const MainAppScreen(),
        ),
      ),
    );
  }
}

/// Pantalla principal de la aplicación (ejemplo)
class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medieval Pomodoro'),
        backgroundColor: const Color(0xFF2A1B0A),
      ),
      body: const Center(
        child: Text(
          'Pantalla Principal',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

/// Función para ejecutar el ejemplo
void runOnboardingExample() {
  runApp(const OnboardingExample());
}
