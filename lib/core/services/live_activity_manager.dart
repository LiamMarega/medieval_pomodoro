import 'package:live_activities/live_activities.dart';

class LiveActivityManager {
  final LiveActivities _liveActivitiesPlugin = LiveActivities();
  String? _currentActivityId;

  // Inicializar el plugin
  Future<void> init() async {
    await _liveActivitiesPlugin.init(
      appGroupId: 'group.com.focusknight.app',
      urlScheme: 'focusknight',
    );
  }

  // Crear la actividad con los datos iniciales
  Future<void> createFocusActivity({
    required String userName,
    required String sessionType,
    required int currentSession,
    required int timeRemaining,
    bool paused = false,
  }) async {
    final Map<String, dynamic> activityModel = {
      'name': userName, // Este será leído desde Swift
      'ingredient': sessionType, // Puedes usar esto para información adicional
      'quantity': currentSession, // Número de sesión actual
      // Los datos del timer van en el ContentState, no aquí
    };

    try {
      _currentActivityId = await _liveActivitiesPlugin.createActivity(
          "focusknight", activityModel);

      // Inmediatamente actualizar con el estado del timer
      await updateActivity(
        timeRemaining: timeRemaining,
        sessionType: sessionType,
        currentSession: currentSession,
        paused: paused,
      );
    } catch (e) {
      print('Error creating live activity: $e');
    }
  }

  // Actualizar la actividad (llamar cada segundo cuando el timer corre)
  Future<void> updateActivity({
    required int timeRemaining,
    required String sessionType,
    required int currentSession,
    required bool paused,
  }) async {
    if (_currentActivityId == null) return;

    try {
      await _liveActivitiesPlugin.updateActivity(
        _currentActivityId!,
        {
          'timeRemaining': timeRemaining,
          'sessionType': sessionType,
          'currentSession': currentSession,
          'paused': paused,
        },
      );
    } catch (e) {
      print('Error updating live activity: $e');
    }
  }

  // Finalizar la actividad
  Future<void> endActivity() async {
    if (_currentActivityId == null) return;

    try {
      await _liveActivitiesPlugin.endActivity(_currentActivityId!);
      _currentActivityId = null;
    } catch (e) {
      print('Error ending live activity: $e');
    }
  }
}




