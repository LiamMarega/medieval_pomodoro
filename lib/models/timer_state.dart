class TimerState {
  final bool isActive;
  final int currentSeconds;
  final int totalSeconds;
  final int sessionNumber;
  final String sessionType;
  final bool isMusicEnabled;
  final bool isMusicPlaying;
  final String currentMotivationalMessage;
  final int workDurationMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final double currentVolume;
  final bool isLoading;
  final String? error;

  const TimerState({
    this.isActive = false,
    this.currentSeconds = 1500,
    this.totalSeconds = 1500,
    this.sessionNumber = 1,
    this.sessionType = 'Work',
    this.isMusicEnabled = false,
    this.isMusicPlaying = false,
    this.currentMotivationalMessage = '',
    this.workDurationMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 30,
    this.currentVolume = 0.0,
    this.isLoading = false,
    this.error,
  });

  TimerState copyWith({
    bool? isActive,
    int? currentSeconds,
    int? totalSeconds,
    int? sessionNumber,
    String? sessionType,
    bool? isMusicEnabled,
    bool? isMusicPlaying,
    String? currentMotivationalMessage,
    int? workDurationMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    double? currentVolume,
    bool? isLoading,
    String? error,
  }) {
    return TimerState(
      isActive: isActive ?? this.isActive,
      currentSeconds: currentSeconds ?? this.currentSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      sessionType: sessionType ?? this.sessionType,
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      isMusicPlaying: isMusicPlaying ?? this.isMusicPlaying,
      currentMotivationalMessage: currentMotivationalMessage ?? this.currentMotivationalMessage,
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      currentVolume: currentVolume ?? this.currentVolume,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimerState &&
        other.isActive == isActive &&
        other.currentSeconds == currentSeconds &&
        other.totalSeconds == totalSeconds &&
        other.sessionNumber == sessionNumber &&
        other.sessionType == sessionType &&
        other.isMusicEnabled == isMusicEnabled &&
        other.isMusicPlaying == isMusicPlaying &&
        other.currentMotivationalMessage == currentMotivationalMessage &&
        other.workDurationMinutes == workDurationMinutes &&
        other.shortBreakMinutes == shortBreakMinutes &&
        other.longBreakMinutes == longBreakMinutes &&
        other.currentVolume == currentVolume &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      isActive,
      currentSeconds,
      totalSeconds,
      sessionNumber,
      sessionType,
      isMusicEnabled,
      isMusicPlaying,
      currentMotivationalMessage,
      workDurationMinutes,
      shortBreakMinutes,
      longBreakMinutes,
      currentVolume,
      isLoading,
      error,
    );
  }

  @override
  String toString() {
    return 'TimerState(isActive: $isActive, currentSeconds: $currentSeconds, totalSeconds: $totalSeconds, sessionNumber: $sessionNumber, sessionType: $sessionType, isMusicEnabled: $isMusicEnabled, isMusicPlaying: $isMusicPlaying, currentMotivationalMessage: $currentMotivationalMessage, workDurationMinutes: $workDurationMinutes, shortBreakMinutes: $shortBreakMinutes, longBreakMinutes: $longBreakMinutes, currentVolume: $currentVolume, isLoading: $isLoading, error: $error)';
  }
}
