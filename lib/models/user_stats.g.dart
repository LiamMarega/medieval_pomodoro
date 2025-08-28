// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserStats _$UserStatsFromJson(Map<String, dynamic> json) => _UserStats(
      deviceId: json['deviceId'] as String,
      deviceType: json['deviceType'] as String,
      deviceModel: json['deviceModel'] as String,
      totalFocusMinutes: (json['totalFocusMinutes'] as num).toInt(),
      totalSessions: (json['totalSessions'] as num).toInt(),
      lastSessionDate: DateTime.parse(json['lastSessionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserStatsToJson(_UserStats instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'deviceType': instance.deviceType,
      'deviceModel': instance.deviceModel,
      'totalFocusMinutes': instance.totalFocusMinutes,
      'totalSessions': instance.totalSessions,
      'lastSessionDate': instance.lastSessionDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_FocusSession _$FocusSessionFromJson(Map<String, dynamic> json) =>
    _FocusSession(
      sessionId: json['sessionId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      completed: json['completed'] as bool,
    );

Map<String, dynamic> _$FocusSessionToJson(_FocusSession instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'completed': instance.completed,
    };
