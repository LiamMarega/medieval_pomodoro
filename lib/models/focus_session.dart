class FocusSession {
  final String sessionId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final bool completed;

  const FocusSession({
    required this.sessionId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.completed,
  });

  FocusSession copyWith({
    String? sessionId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    bool? completed,
  }) {
    return FocusSession(
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      completed: completed ?? this.completed,
    );
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      sessionId: json['sessionId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      durationMinutes: json['durationMinutes'] as int,
      completed: json['completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'completed': completed,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FocusSession &&
        other.sessionId == sessionId &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.durationMinutes == durationMinutes &&
        other.completed == completed;
  }

  @override
  int get hashCode {
    return Object.hash(
      sessionId,
      startTime,
      endTime,
      durationMinutes,
      completed,
    );
  }

  @override
  String toString() {
    return 'FocusSession(sessionId: $sessionId, startTime: $startTime, endTime: $endTime, durationMinutes: $durationMinutes, completed: $completed)';
  }
}
