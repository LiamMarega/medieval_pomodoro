// Ejemplo de uso del sistema de persistencia local
// Este archivo muestra cómo usar el LocalStorageService y SettingsProvider

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_storage_service.dart';
import '../providers/settings_provider.dart';
import '../providers/timer_provider.dart';
import '../models/settings_state.dart';

class PersistenceExample {
  // Ejemplo 1: Uso directo del LocalStorageService
  static Future<void> directStorageExample() async {
    final storage = await LocalStorageService.getInstance();

    // Guardar configuraciones individuales
    await storage.saveWorkDuration(30);
    await storage.saveShortBreakDuration(5);
    await storage.saveLongBreakDuration(15);
    await storage.saveMusicEnabled(true);

    // O guardar todas las configuraciones de una vez
    await storage.saveAllSettings(
      workDurationMinutes: 30,
      shortBreakMinutes: 5,
      longBreakMinutes: 15,
      isMusicEnabled: true,
    );

    // Leer configuraciones
    final workDuration = storage.getWorkDuration(); // 30
    final shortBreak = storage.getShortBreakDuration(); // 5
    final longBreak = storage.getLongBreakDuration(); // 15
    final musicEnabled = storage.getMusicEnabled(); // true

    // O leer todas las configuraciones
    final allSettings = storage.loadAllSettings();
    print('All settings: $allSettings');
  }

  // Ejemplo 2: Uso con Riverpod en un widget
  static Widget settingsWidgetExample(WidgetRef ref) {
    // Observar el estado asíncrono del settings provider
    final settingsAsync = ref.watch(settingsControllerProvider);

    return settingsAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (settings) => Column(
        children: [
          Text('Work Duration: ${settings.workDurationMinutes} minutes'),
          Text('Short Break: ${settings.shortBreakMinutes} minutes'),
          Text('Long Break: ${settings.longBreakMinutes} minutes'),
          Text('Music Enabled: ${settings.isMusicEnabled}'),

          // Botones para actualizar configuraciones
          ElevatedButton(
            onPressed: () {
              ref
                  .read(settingsControllerProvider.notifier)
                  .updateWorkDuration(45);
            },
            child: Text('Set Work to 45 minutes'),
          ),

          ElevatedButton(
            onPressed: () {
              ref.read(settingsControllerProvider.notifier).updateSettings(
                    workDurationMinutes: 25,
                    shortBreakMinutes: 3,
                    longBreakMinutes: 20,
                    isMusicEnabled: false,
                  );
            },
            child: Text('Reset to Defaults'),
          ),
        ],
      ),
    );
  }

  // Ejemplo 3: Uso en un provider que necesita configuraciones
  static Widget timerWidgetExample(WidgetRef ref) {
    // El timer provider observa automáticamente los cambios en settings
    final timerState = ref.watch(timerControllerProvider);

    return Column(
      children: [
        Text('Current Timer: ${timerState.currentSeconds} seconds'),
        Text('Total Time: ${timerState.totalSeconds} seconds'),
        Text('Music Enabled: ${timerState.isMusicEnabled}'),

        // Los cambios en settings se reflejan automáticamente en el timer
        ElevatedButton(
          onPressed: () {
            // Este cambio se guardará automáticamente y el timer se actualizará
            ref
                .read(settingsControllerProvider.notifier)
                .updateWorkDuration(60);
          },
          child: Text('Set Work to 1 hour'),
        ),
      ],
    );
  }

  // Ejemplo 4: Manejo de errores y estados de carga
  static Widget robustSettingsWidget(WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return settingsAsync.when(
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading settings...'),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text('Error loading settings: $error'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Refrescar el provider
                ref.invalidate(settingsControllerProvider);
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
      data: (settings) => SettingsContent(settings: settings),
    );
  }
}

// Widget auxiliar para mostrar el contenido de settings
class SettingsContent extends ConsumerWidget {
  final SettingsState settings;

  const SettingsContent({super.key, required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          title: Text('Work Duration'),
          subtitle: Text('${settings.workDurationMinutes} minutes'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  final newValue =
                      (settings.workDurationMinutes - 5).clamp(1, 60);
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateWorkDuration(newValue);
                },
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  final newValue =
                      (settings.workDurationMinutes + 5).clamp(1, 60);
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateWorkDuration(newValue);
                },
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: Text('Music'),
          subtitle: Text('Enable background music'),
          value: settings.isMusicEnabled,
          onChanged: (value) {
            ref
                .read(settingsControllerProvider.notifier)
                .updateMusicEnabled(value);
          },
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(settingsControllerProvider.notifier).resetToDefaults();
          },
          child: Text('Reset to Defaults'),
        ),
      ],
    );
  }
}
