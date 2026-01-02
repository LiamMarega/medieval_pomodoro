import 'timer_mode.dart';

class TimerState {
  final bool isActive;
  final int sessionNumber;
  final TimerMode currentMode;
  final TimerMode? lastMode;
  final bool isMusicEnabled;
  final bool isSoundEnabled;
  final bool isMusicPlaying;
  final String currentMotivationalMessage;
  final int workDurationMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final double currentVolume;
  final bool isLoading;
  final String? error;
  final AnimationType currentAnimation;
  
  // DateTime-based timer fields (principio clave: timer exacto basado en DateTime)
  final DateTime? endsAt; // null => detenido
  final Duration remaining; // recalculado en cada tick

  const TimerState({
    this.isActive = false,
    this.sessionNumber = 1,
    this.currentMode = TimerMode.work,
    this.lastMode,
    this.isMusicEnabled = true, // Music always ON by default
    this.isSoundEnabled = true,
    this.isMusicPlaying = false,
    this.currentMotivationalMessage = '',
    this.workDurationMinutes = 0, // 10 seconds for testing
    this.shortBreakMinutes = 0, // 10 seconds for testing
    this.longBreakMinutes = 0, // 20 seconds for testing
    this.currentVolume = 0.0,
    this.isLoading = false,
    this.error,
    this.currentAnimation = AnimationType.work1,
    this.endsAt,
    this.remaining = Duration.zero,
  });

  // Getters para mantener compatibilidad con código existente
  String get sessionType => currentMode.displayName;
  
  // Computed properties para backward compatibility
  int get currentSeconds => remaining.inSeconds;
  
  int get totalSeconds {
    switch (currentMode) {
      case TimerMode.work:
        return _minutesToSeconds(workDurationMinutes);
      case TimerMode.shortBreak:
        return _minutesToSeconds(shortBreakMinutes);
      case TimerMode.longBreak:
        return _minutesToSeconds(longBreakMinutes);
      case TimerMode.gapTime:
        return 3; // Always 3 seconds for gap time
    }
  }
  
  int _minutesToSeconds(int minutes) {
    if (minutes == 0) {
      // Test mode: 10 seconds for work/break, 20 seconds for long break
      if (currentMode == TimerMode.longBreak) {
        return 20;
      } else {
        return 10;
      }
    }
    return minutes * 60;
  }

  TimerState copyWith({
    bool? isActive,
    int? sessionNumber,
    TimerMode? currentMode,
    TimerMode? lastMode,
    bool? isMusicEnabled,
    bool? isSoundEnabled,
    bool? isMusicPlaying,
    String? currentMotivationalMessage,
    int? workDurationMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    double? currentVolume,
    bool? isLoading,
    String? error,
    AnimationType? currentAnimation,
    DateTime? endsAt,
    Duration? remaining,
  }) {
    return TimerState(
      isActive: isActive ?? this.isActive,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      currentMode: currentMode ?? this.currentMode,
      lastMode: lastMode ?? this.lastMode,
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isMusicPlaying: isMusicPlaying ?? this.isMusicPlaying,
      currentMotivationalMessage:
          currentMotivationalMessage ?? this.currentMotivationalMessage,
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      currentVolume: currentVolume ?? this.currentVolume,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentAnimation: currentAnimation ?? this.currentAnimation,
      endsAt: endsAt ?? this.endsAt,
      remaining: remaining ?? this.remaining,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimerState &&
        other.isActive == isActive &&
        other.remaining == remaining &&
        other.endsAt == endsAt &&
        other.sessionNumber == sessionNumber &&
        other.currentMode == currentMode &&
        other.lastMode == lastMode &&
        other.isMusicEnabled == isMusicEnabled &&
        other.isSoundEnabled == isSoundEnabled &&
        other.isMusicPlaying == isMusicPlaying &&
        other.currentMotivationalMessage == currentMotivationalMessage &&
        other.workDurationMinutes == workDurationMinutes &&
        other.shortBreakMinutes == shortBreakMinutes &&
        other.longBreakMinutes == longBreakMinutes &&
        other.currentVolume == currentVolume &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.currentAnimation == currentAnimation;
  }

  @override
  int get hashCode {
    return Object.hash(
      isActive,
      remaining,
      endsAt,
      sessionNumber,
      currentMode,
      lastMode,
      isMusicEnabled,
      isSoundEnabled,
      isMusicPlaying,
      currentMotivationalMessage,
      workDurationMinutes,
      shortBreakMinutes,
      longBreakMinutes,
      currentVolume,
      isLoading,
      error,
      currentAnimation,
    );
  }

  @override
  String toString() {
    return 'TimerState(isActive: $isActive, remaining: $remaining, endsAt: $endsAt, currentSeconds: $currentSeconds, totalSeconds: $totalSeconds, sessionNumber: $sessionNumber, currentMode: $currentMode, lastMode: $lastMode, isMusicEnabled: $isMusicEnabled, isSoundEnabled: $isSoundEnabled, isMusicPlaying: $isMusicPlaying, currentMotivationalMessage: $currentMotivationalMessage, workDurationMinutes: $workDurationMinutes, shortBreakMinutes: $shortBreakMinutes, longBreakMinutes: $longBreakMinutes, currentVolume: $currentVolume, isLoading: $isLoading, error: $error, currentAnimation: $currentAnimation)';
  }
}
