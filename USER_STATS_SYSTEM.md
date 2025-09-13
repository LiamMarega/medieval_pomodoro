# Sistema de Estadísticas del Usuario - Medieval Pomodoro

## Descripción General

El sistema de estadísticas del usuario permite trackear y almacenar información sobre las sesiones de enfoque completadas por el usuario. Cada "usuario" está vinculado a un dispositivo específico con un ID único.

## Características Principales

### 🔍 Identificación del Dispositivo
- **ID Único**: Cada dispositivo obtiene un UUID único que se almacena localmente
- **Información del Dispositivo**: Se detecta automáticamente el tipo y modelo del dispositivo
- **Plataformas Soportadas**: Android, iOS, macOS, Windows, Linux, Web

### 📊 Estadísticas Trackeadas
- **Tiempo Total de Enfoque**: Minutos acumulados en sesiones de trabajo
- **Número Total de Sesiones**: Cantidad de sesiones completadas
- **Duración Promedio**: Tiempo promedio por sesión
- **Estadísticas Temporales**: Hoy, esta semana, este mes
- **Historial de Sesiones**: Últimas 100 sesiones con timestamps

### 💾 Almacenamiento Local
- **SharedPreferences**: Para datos persistentes del usuario
- **Serialización JSON**: Para estructuras de datos complejas
- **Gestión de Memoria**: Limitación a 100 sesiones para evitar sobrecarga

## Arquitectura del Sistema

### Modelos de Datos

#### UserStats
```dart
class UserStats {
  String deviceId;           // ID único del dispositivo
  String deviceType;         // Tipo de dispositivo (Android, iOS, etc.)
  String deviceModel;        // Modelo específico del dispositivo
  int totalFocusMinutes;     // Minutos totales de enfoque
  int totalSessions;         // Número total de sesiones
  DateTime lastSessionDate;  // Fecha de la última sesión
  DateTime createdAt;        // Fecha de creación del perfil
  DateTime updatedAt;        // Fecha de última actualización
}
```

#### FocusSession
```dart
class FocusSession {
  String sessionId;          // ID único de la sesión
  DateTime startTime;        // Hora de inicio
  DateTime? endTime;         // Hora de finalización
  int durationMinutes;       // Duración en minutos
  bool completed;            // Si la sesión se completó
}
```

### Servicios

#### UserStatsService
- **getDeviceId()**: Obtiene o crea ID único del dispositivo
- **getDeviceInfo()**: Detecta información del dispositivo
- **loadUserStats()**: Carga estadísticas desde localStorage
- **saveUserStats()**: Guarda estadísticas en localStorage
- **recordFocusSession()**: Registra una sesión completada
- **getStatsSummary()**: Obtiene estadísticas resumidas

### Providers (Riverpod)

#### UserStatsController
- **build()**: Inicializa y mantiene el estado del usuario
- **recordFocusSession()**: Registra sesiones de forma reactiva
- **getStatsSummary()**: Obtiene estadísticas actualizadas
- **refreshStats()**: Refresca los datos

#### Providers Adicionales
- **statsSummaryProvider**: Estadísticas resumidas
- **focusSessionsProvider**: Lista de sesiones

## Integración con el Timer

### Registro Automático
El sistema se integra automáticamente con el `TimerController`:

```dart
void _completeSession() {
  // ... lógica existente ...
  
  // Registrar estadísticas si es una sesión de trabajo completada
  if (completedSessionType.isWork) {
    _recordWorkSessionStats();
  }
  
  // ... resto de la lógica ...
}
```

### Método de Registro
```dart
void _recordWorkSessionStats() {
  try {
    final durationMinutes = state.workDurationMinutes;
    
    Future.microtask(() async {
      await _userStatsService.recordFocusSession(durationMinutes);
      debugPrint('📊 Work session recorded: $durationMinutes minutes');
    });
  } catch (e) {
    debugPrint('❌ Error recording work session stats: $e');
  }
}
```

## Componentes de UI

### UserStatsWidget
Widget reutilizable que muestra estadísticas en tiempo real:
- Tiempo total de enfoque
- Número de sesiones
- Duración promedio
- Estadísticas temporales (hoy, semana, mes)

### StatsScreen
Pantalla completa con:
- Información del dispositivo
- Estadísticas detalladas
- Historial de sesiones recientes
- Botón de refresh

## Uso del Sistema

### 1. Inicialización Automática
El sistema se inicializa automáticamente cuando se accede por primera vez:

```dart
// En cualquier widget que use estadísticas
final userStats = ref.watch(userStatsControllerProvider);
```

### 2. Registro de Sesiones
Las sesiones se registran automáticamente al completar una sesión de trabajo.

### 3. Visualización de Estadísticas
```dart
// Widget simple
const UserStatsWidget()

// Pantalla completa
const StatsScreen()
```

### 4. Actualización Manual
```dart
// Refrescar estadísticas
ref.refresh(userStatsControllerProvider);
ref.refresh(statsSummaryProvider);
```

## Dependencias

### Nuevas Dependencias Agregadas
```yaml
device_info_plus: ^10.1.0  # Detección de información del dispositivo
uuid: ^4.3.3               # Generación de IDs únicos
```

### Dependencias Existentes Utilizadas
```yaml
shared_preferences: ^2.2.2  # Almacenamiento local
flutter_riverpod: ^3.0.0-dev.17  # Gestión de estado
freezed_annotation: ^3.1.0  # Modelos inmutables
json_annotation: ^4.9.0     # Serialización JSON
```

## Estructura de Archivos

```
lib/
├── models/
│   └── user_stats.dart              # Modelos de datos
├── core/services/
│   └── user_stats_service.dart      # Servicio principal
├── providers/
│   └── user_stats_provider.dart     # Providers de Riverpod
├── widgets/
│   └── user_stats_widget.dart       # Widget de estadísticas
└── presentation/stats_screen/
    └── stats_screen.dart            # Pantalla de estadísticas
```

## Consideraciones de Privacidad

- **Datos Locales**: Toda la información se almacena localmente en el dispositivo
- **Sin Tracking**: No se envían datos a servidores externos
- **Control del Usuario**: Los datos pertenecen completamente al usuario
- **Transparencia**: El código es abierto y auditable

## Futuras Mejoras

1. **Exportación de Datos**: Permitir exportar estadísticas en CSV/JSON
2. **Gráficos**: Visualizaciones más avanzadas con fl_chart
3. **Metas**: Sistema de objetivos y logros
4. **Sincronización**: Opcional con servicios en la nube
5. **Notificaciones**: Recordatorios basados en patrones de uso
