# Sistema de Persistencia Local - Medieval Pomodoro

## Descripción General

El sistema de persistencia local permite que todas las configuraciones del usuario se guarden automáticamente en el dispositivo y se mantengan entre sesiones de la aplicación.

## Componentes Principales

### 1. LocalStorageService (`lib/services/local_storage_service.dart`)

Servicio singleton que maneja la persistencia usando SharedPreferences:

- **Métodos de guardado:**
  - `saveWorkDuration(int minutes)`
  - `saveShortBreakDuration(int minutes)`
  - `saveLongBreakDuration(int minutes)`
  - `saveMusicEnabled(bool enabled)`
  - `saveAllSettings()` - Guarda todas las configuraciones de una vez

- **Métodos de lectura:**
  - `getWorkDuration()` - Retorna el valor guardado o 25 por defecto
  - `getShortBreakDuration()` - Retorna el valor guardado o 5 por defecto
  - `getLongBreakDuration()` - Retorna el valor guardado o 30 por defecto
  - `getMusicEnabled()` - Retorna el valor guardado o true por defecto
  - `loadAllSettings()` - Retorna todas las configuraciones como Map

### 2. SettingsProvider (`lib/providers/settings_provider.dart`)

Provider con `keepAlive: true` que maneja el estado de las configuraciones:

- **Estado asíncrono:** Usa `Future<SettingsState>` para cargar configuraciones desde local storage
- **Persistencia automática:** Cada cambio se guarda automáticamente en local storage
- **Métodos de actualización:**
  - `updateSettings()` - Actualiza todas las configuraciones
  - `updateWorkDuration()` - Actualiza solo duración de trabajo
  - `updateShortBreakDuration()` - Actualiza solo duración de break corto
  - `updateLongBreakDuration()` - Actualiza solo duración de break largo
  - `updateMusicEnabled()` - Actualiza solo estado de música
  - `resetToDefaults()` - Restaura configuraciones por defecto

### 3. TimerProvider (`lib/providers/timer_provider.dart`)

Provider que observa el SettingsProvider y se actualiza automáticamente:

- **Observación reactiva:** Usa `ref.watch(settingsControllerProvider)` para reaccionar a cambios
- **Sincronización automática:** Los cambios en settings se reflejan inmediatamente en el timer
- **Configuración inicial:** Usa valores del settings provider al inicializar

## Flujo de Datos

```
Usuario cambia configuración
         ↓
SettingsScreen llama a updateSettings()
         ↓
SettingsProvider actualiza estado y guarda en LocalStorage
         ↓
TimerProvider observa cambios y se actualiza automáticamente
         ↓
UI se actualiza con nuevos valores
```

## Configuraciones Persistidas

1. **workDurationMinutes** - Duración de sesiones de trabajo (1-60 minutos)
2. **shortBreakMinutes** - Duración de breaks cortos (1-15 minutos)
3. **longBreakMinutes** - Duración de breaks largos (15-60 minutos)
4. **isMusicEnabled** - Estado de música (true/false)

## Uso en la UI

### En SettingsScreen:

```dart
// Observar estado asíncrono
final settingsAsync = ref.watch(settingsControllerProvider);

settingsAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
  data: (settings) => YourSettingsWidget(settings),
);

// Actualizar configuraciones
ref.read(settingsControllerProvider.notifier).updateSettings(
  workDurationMinutes: 30,
  shortBreakMinutes: 5,
  longBreakMinutes: 15,
  isMusicEnabled: true,
);
```

### En otros widgets:

```dart
// Obtener configuración actual
final settings = ref.watch(settingsControllerProvider);
final workDuration = settings.when(
  data: (data) => data.workDurationMinutes,
  loading: () => 25,
  error: (_, __) => 25,
);
```

## Ventajas del Sistema

1. **Persistencia automática:** No se pierden configuraciones al cerrar la app
2. **Reactividad:** Cambios inmediatos en toda la app
3. **keepAlive:** Los providers se mantienen vivos entre navegaciones
4. **Fallbacks:** Valores por defecto si no hay datos guardados
5. **Performance:** SharedPreferences es rápido y eficiente
6. **Manejo de errores:** Logs detallados para debugging

## Debugging

Los logs incluyen emojis para fácil identificación:
- 💾 - Guardado exitoso
- ❌ - Error en operación
- ⚠️ - Advertencia
- 🔄 - Reset a valores por defecto
- 📱 - Carga de configuraciones

## Mantenimiento

Para agregar nuevas configuraciones:

1. Agregar campo en `SettingsState`
2. Agregar métodos en `LocalStorageService`
3. Actualizar `SettingsProvider`
4. Regenerar archivos con `dart run build_runner build`
