import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_stats.freezed.dart';
part 'user_stats.g.dart';

@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    required String deviceId,
    required String deviceType,
    required String deviceModel,
    required int totalFocusMinutes,
    required int totalSessions,
    required DateTime lastSessionDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserStats;

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
}

@freezed
class FocusSession with _$FocusSession {
  const factory FocusSession({
    required String sessionId,
    required DateTime startTime,
    required DateTime? endTime,
    required int durationMinutes,
    required bool completed,
  }) = _FocusSession;

  factory FocusSession.fromJson(Map<String, dynamic> json) =>
      _$FocusSessionFromJson(json);
}
