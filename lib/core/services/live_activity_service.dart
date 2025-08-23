// lib/services/live_activity_service.dart
// Servicio para integrar Live Activities (iOS 16.1+) y RemoteViews (Android API 24+) usando:
// https://pub.dev/packages/live_activities
//
// NOTA IMPORTANTE:
// - No modifica tu @notifications_service existente.
// - Este servicio funciona de manera independiente. Podés llamarlo desde tu timer_provider.dart
//   cuando el pomodoro cambia de estado (start/pause/resume/stop/extend).
// - En iOS, necesitás el Widget Extension configurado (ver README del paquete).
// - Ajustá los valores de appGroupId y urlScheme a los de tu proyecto.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:live_activities/live_activities.dart';
import 'package:live_activities/models/activity_update.dart';
import 'package:live_activities/models/live_activity_file.dart';
import 'package:live_activities/models/url_scheme_data.dart';

/// Estados básicos del Pomodoro que este servicio entiende.
enum PomodoroPhase { focus, shortBreak, longBreak }

/// DTO con el estado mínimo para sincronizar la Live Activity.
class PomodoroSnapshot {
  PomodoroSnapshot({
    required this.taskName,
    required this.phase,
    required this.endAt, // Fecha/hora en la que termina el ciclo actual
    required this.isRunning,
  });

  final String taskName;
  final PomodoroPhase phase;
  final DateTime endAt;
  final bool isRunning;

  Map<String, dynamic> toLiveActivityPayload() {
    // Claves leídas desde el Widget Extension via UserDefaults (con prefijo)
    return <String, dynamic>{
      'taskName': taskName,
      'phase': describeEnum(phase),
      'endTimestamp': endAt.millisecondsSinceEpoch,
      'isRunning': isRunning,
      'logo':
          LiveActivityFileFromAsset.image('assets/images/focus_knight_logo.png')
    };
  }
}

/// Servicio principal. Maneja ciclo de vida de la Live Activity / RemoteViews.
class LiveActivityService {
  LiveActivityService({
    String appGroupId = 'group.com.example.pomodoro', // TODO: reemplazar
    String urlScheme = 'pomodoro', // TODO: reemplazar
    String customActivityId = 'pomodoro-activity',
  })  : _appGroupId = appGroupId,
        _urlScheme = urlScheme,
        _customId = customActivityId;

  final String _appGroupId;
  final String _urlScheme;
  final String _customId;
  final _plugin = LiveActivities();

  String? _activityId;
  StreamSubscription<ActivityUpdate>? _activityUpdatesSub;
  StreamSubscription<UrlSchemeData>? _urlSchemeSub;

  /// Inicializa el plugin y sus streams.
  Future<void> init({
    void Function(String action)? onActionFromIsland,
    void Function(String activityId, String? pushToken)? onActivityBecameActive,
    void Function(String activityId)? onActivityEnded,
  }) async {
    await _plugin.init(appGroupId: _appGroupId, urlScheme: _urlScheme);

    _activityUpdatesSub?.cancel();
    _activityUpdatesSub = _plugin.activityUpdateStream.listen((event) {
      event.map(
        active: (a) =>
            onActivityBecameActive?.call(a.activityId, a.activityToken),
        ended: (a) {
          if (_activityId == a.activityId) _activityId = null;
          onActivityEnded?.call(a.activityId);
        },
        unknown: (_) {},
        stale: (_) {},
      );
    });

    _urlSchemeSub?.cancel();
    _urlSchemeSub = _plugin.urlSchemeStream().listen((data) {
      // Espera algo como: pomodoro://action?type=pause|resume|stop
      final action = Uri.parse(data.url ?? '').queryParameters['type'];
      if (action != null) {
        onActionFromIsland?.call(action);
      }
    });
  }

  /// Crea o actualiza la Live Activity en función del snapshot del temporizador.
  Future<void> sync(PomodoroSnapshot snap) async {
    final supported = await _plugin.areActivitiesEnabled();
    if (supported != true) return; // iOS < 16.1, deshabilitado o permisos off

    final payload = snap.toLiveActivityPayload();

    // Crea una o actualiza la existente reusando un id predecible (_customId).
    _activityId = await _plugin.createOrUpdateActivity(
      'focus-knight',
      payload,
    );
  }

  /// Actualiza campos específicos de la actividad sin recrearla.
  Future<void> patch({
    bool? isRunning,
    DateTime? newEndAt,
    PomodoroPhase? phase,
    String? taskName,
  }) async {
    if (_activityId == null) return;
    final patch = <String, dynamic>{};
    if (isRunning != null) patch['isRunning'] = isRunning;
    if (newEndAt != null) {
      patch['endTimestamp'] = newEndAt.millisecondsSinceEpoch;
    }
    if (phase != null) patch['phase'] = describeEnum(phase);
    if (taskName != null) patch['taskName'] = taskName;
    if (patch.isEmpty) return;
    await _plugin.updateActivity(_activityId!, patch);
  }

  /// Finaliza la Live Activity (se oculta del Lock Screen / Dynamic Island).
  Future<void> end() async {
    if (_activityId == null) return;
    await _plugin.endActivity(_activityId!);
    _activityId = null;
  }

  /// Devuelve si el dispositivo soporta/permite Live Activities.
  Future<bool> isAvailable() async {
    return await _plugin.areActivitiesEnabled() ?? false;
  }

  /// Libera recursos.
  Future<void> dispose() async {
    await _activityUpdatesSub?.cancel();
    await _urlSchemeSub?.cancel();
  }
}
