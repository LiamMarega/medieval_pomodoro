class UserStats {
  final String deviceId;
  final String deviceType;
  final String deviceModel;
  final int totalFocusMinutes;
  final int totalSessions;
  final DateTime lastSessionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserStats({
    required this.deviceId,
    required this.deviceType,
    required this.deviceModel,
    required this.totalFocusMinutes,
    required this.totalSessions,
    required this.lastSessionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  UserStats copyWith({
    String? deviceId,
    String? deviceType,
    String? deviceModel,
    int? totalFocusMinutes,
    int? totalSessions,
    DateTime? lastSessionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserStats(
      deviceId: deviceId ?? this.deviceId,
      deviceType: deviceType ?? this.deviceType,
      deviceModel: deviceModel ?? this.deviceModel,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      totalSessions: totalSessions ?? this.totalSessions,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      deviceId: json['deviceId'] as String,
      deviceType: json['deviceType'] as String,
      deviceModel: json['deviceModel'] as String,
      totalFocusMinutes: json['totalFocusMinutes'] as int,
      totalSessions: json['totalSessions'] as int,
      lastSessionDate: DateTime.parse(json['lastSessionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceType': deviceType,
      'deviceModel': deviceModel,
      'totalFocusMinutes': totalFocusMinutes,
      'totalSessions': totalSessions,
      'lastSessionDate': lastSessionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStats &&
        other.deviceId == deviceId &&
        other.deviceType == deviceType &&
        other.deviceModel == deviceModel &&
        other.totalFocusMinutes == totalFocusMinutes &&
        other.totalSessions == totalSessions &&
        other.lastSessionDate == lastSessionDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      deviceId,
      deviceType,
      deviceModel,
      totalFocusMinutes,
      totalSessions,
      lastSessionDate,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserStats(deviceId: $deviceId, deviceType: $deviceType, deviceModel: $deviceModel, totalFocusMinutes: $totalFocusMinutes, totalSessions: $totalSessions, lastSessionDate: $lastSessionDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
