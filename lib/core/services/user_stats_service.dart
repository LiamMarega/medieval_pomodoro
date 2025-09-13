import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:medieval_pomodoro/models/focus_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../models/user_stats.dart';

class UserStatsService {
  static const String _userStatsKey = 'user_stats';
  static const String _deviceIdKey = 'device_id';
  static const String _sessionsKey = 'focus_sessions';

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Uuid _uuid = const Uuid();

  /// Obtiene o crea un ID único para el dispositivo
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      deviceId = _uuid.v4();
      await prefs.setString(_deviceIdKey, deviceId);
    }

    return deviceId;
  }

  /// Obtiene información del dispositivo
  Future<Map<String, String>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'type': 'Android',
          'model': '${androidInfo.brand} ${androidInfo.model}',
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'type': 'iOS',
          'model': '${iosInfo.name} ${iosInfo.model}',
        };
      } else if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        return {
          'type': 'macOS',
          'model': '${macOsInfo.computerName}',
        };
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return {
          'type': 'Windows',
          'model': '${windowsInfo.computerName}',
        };
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return {
          'type': 'Linux',
          'model': '${linuxInfo.name}',
        };
      } else {
        return {
          'type': 'Web',
          'model': 'Web Browser',
        };
      }
    } catch (e) {
      return {
        'type': 'Unknown',
        'model': 'Unknown Device',
      };
    }
  }

  /// Carga las estadísticas del usuario desde localStorage
  Future<UserStats?> loadUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_userStatsKey);

      if (statsJson != null) {
        final statsMap = json.decode(statsJson) as Map<String, dynamic>;
        return UserStats.fromJson(statsMap);
      }

      return null;
    } catch (e) {
      print('Error loading user stats: $e');
      return null;
    }
  }

  /// Guarda las estadísticas del usuario en localStorage
  Future<void> saveUserStats(UserStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = json.encode(stats.toJson());
      await prefs.setString(_userStatsKey, statsJson);
    } catch (e) {
      print('Error saving user stats: $e');
    }
  }

  /// Crea o actualiza las estadísticas del usuario
  Future<UserStats> createOrUpdateUserStats() async {
    final deviceId = await getDeviceId();
    final deviceInfo = await getDeviceInfo();
    final now = DateTime.now();

    UserStats? existingStats = await loadUserStats();

    if (existingStats != null) {
      // Actualizar estadísticas existentes
      return existingStats.copyWith(
        updatedAt: now,
      );
    } else {
      // Crear nuevas estadísticas
      final newStats = UserStats(
        deviceId: deviceId,
        deviceType: deviceInfo['type'] ?? 'Unknown',
        deviceModel: deviceInfo['model'] ?? 'Unknown',
        totalFocusMinutes: 0,
        totalSessions: 0,
        lastSessionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await saveUserStats(newStats);
      return newStats;
    }
  }

  /// Registra una sesión de enfoque completada
  Future<void> recordFocusSession(int durationMinutes) async {
    try {
      final stats = await loadUserStats();
      if (stats == null) {
        await createOrUpdateUserStats();
        return;
      }

      final updatedStats = stats.copyWith(
        totalFocusMinutes: stats.totalFocusMinutes + durationMinutes,
        totalSessions: stats.totalSessions + 1,
        lastSessionDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await saveUserStats(updatedStats);

      // También guardar la sesión individual
      await _saveFocusSession(durationMinutes);
    } catch (e) {
      print('Error recording focus session: $e');
    }
  }

  /// Guarda una sesión individual de enfoque
  Future<void> _saveFocusSession(int durationMinutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = _uuid.v4();
      final now = DateTime.now();

      final session = FocusSession(
        sessionId: sessionId,
        startTime: now.subtract(Duration(minutes: durationMinutes)),
        endTime: now,
        durationMinutes: durationMinutes,
        completed: true,
      );

      // Obtener sesiones existentes
      final sessionsJson = prefs.getString(_sessionsKey);
      List<Map<String, dynamic>> sessions = [];

      if (sessionsJson != null) {
        final sessionsList = json.decode(sessionsJson) as List;
        sessions = sessionsList.cast<Map<String, dynamic>>();
      }

      // Agregar nueva sesión
      sessions.add(session.toJson());

      // Mantener solo las últimas 100 sesiones para no llenar el storage
      if (sessions.length > 100) {
        sessions = sessions.sublist(sessions.length - 100);
      }

      await prefs.setString(_sessionsKey, json.encode(sessions));
    } catch (e) {
      print('Error saving focus session: $e');
    }
  }

  /// Obtiene las sesiones de enfoque
  Future<List<FocusSession>> getFocusSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sessionsKey);

      if (sessionsJson != null) {
        final sessionsList = json.decode(sessionsJson) as List;
        return sessionsList
            .map((session) =>
                FocusSession.fromJson(session as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error loading focus sessions: $e');
      return [];
    }
  }

  /// Obtiene estadísticas resumidas
  Future<Map<String, dynamic>> getStatsSummary() async {
    final stats = await loadUserStats();
    final sessions = await getFocusSessions();

    if (stats == null) {
      return {
        'totalFocusMinutes': 0,
        'totalSessions': 0,
        'averageSessionLength': 0,
        'todayMinutes': 0,
        'thisWeekMinutes': 0,
        'thisMonthMinutes': 0,
      };
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    int todayMinutes = 0;
    int thisWeekMinutes = 0;
    int thisMonthMinutes = 0;

    for (final session in sessions) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (sessionDate.isAtSameMomentAs(today)) {
        todayMinutes += session.durationMinutes;
      }

      if (sessionDate.isAfter(weekStart.subtract(const Duration(days: 1)))) {
        thisWeekMinutes += session.durationMinutes;
      }

      if (sessionDate.isAfter(monthStart.subtract(const Duration(days: 1)))) {
        thisMonthMinutes += session.durationMinutes;
      }
    }

    final averageSessionLength = sessions.isNotEmpty
        ? sessions.map((s) => s.durationMinutes).reduce((a, b) => a + b) /
            sessions.length
        : 0;

    return {
      'totalFocusMinutes': stats.totalFocusMinutes,
      'totalSessions': stats.totalSessions,
      'averageSessionLength': averageSessionLength.round(),
      'todayMinutes': todayMinutes,
      'thisWeekMinutes': thisWeekMinutes,
      'thisMonthMinutes': thisMonthMinutes,
    };
  }
}
