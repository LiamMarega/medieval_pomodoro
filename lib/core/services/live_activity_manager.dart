import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:live_activities/live_activities.dart';

class LiveActivityManager {
  final LiveActivities _liveActivitiesPlugin = LiveActivities();
  String? _currentActivityId;

  // Stream controller for actions received from Live Activity
  final _actionController = StreamController<String>.broadcast();
  Stream<String> get actionStream => _actionController.stream;

  // Inicializar el plugin
  Future<void> init() async {
    await _liveActivitiesPlugin.init(
      appGroupId: 'group.com.focusknight.app',
      urlScheme: 'focusknight',
    );

    // Listen to URL schemes (actions from Live Activity)
    _liveActivitiesPlugin.urlSchemeStream().listen((schemeData) {
      debugPrint('🔗 URL Scheme received: ${schemeData.url}');
      if (schemeData.host != null) {
        _actionController.add(schemeData.host!);
      }
    });
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
      final activityId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentActivityId =
          await _liveActivitiesPlugin.createActivity(activityId, activityModel);

      // Inmediatamente actualizar con el estado del timer
      await updateActivity(
        timeRemaining: timeRemaining,
        sessionType: sessionType,
        currentSession: currentSession,
        paused: paused,
      );
    } catch (e) {
      debugPrint('Error creating live activity: $e');
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
      debugPrint('Error updating live activity: $e');
    }
  }

  // Finalizar la actividad
  Future<void> endActivity() async {
    if (_currentActivityId == null) return;

    try {
      await _liveActivitiesPlugin.endActivity(_currentActivityId!);
      _currentActivityId = null;
    } catch (e) {
      debugPrint('Error ending live activity: $e');
    }
  }

  void dispose() {
    _actionController.close();
  }
}
