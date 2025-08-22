import 'timer_mode.dart';

class TimerState {
  final bool isActive;
  final int currentSeconds;
  final int totalSeconds;
  final int sessionNumber;
  final TimerMode currentMode;
  final bool isMusicEnabled;
  final bool isMusicPlaying;
  final String currentMotivationalMessage;
  final int workDurationMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final double currentVolume;
  final bool isLoading;
  final String? error;
  final AnimationType currentAnimation;

  const TimerState({
    this.isActive = false,
    this.currentSeconds = 1500,
    this.totalSeconds = 1500,
    this.sessionNumber = 1,
    this.currentMode = TimerMode.work,
    this.isMusicEnabled = true, // Music always ON by default
    this.isMusicPlaying = false,
    this.currentMotivationalMessage = '',
    this.workDurationMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 30,
    this.currentVolume = 0.0,
    this.isLoading = false,
    this.error,
    this.currentAnimation = AnimationType.work1,
  });

  // Getter para mantener compatibilidad con código existente
  String get sessionType => currentMode.displayName;

  TimerState copyWith({
    bool? isActive,
    int? currentSeconds,
    int? totalSeconds,
    int? sessionNumber,
    TimerMode? currentMode,
    bool? isMusicEnabled,
    bool? isMusicPlaying,
    String? currentMotivationalMessage,
    int? workDurationMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    double? currentVolume,
    bool? isLoading,
    String? error,
    AnimationType? currentAnimation,
  }) {
    return TimerState(
      isActive: isActive ?? this.isActive,
      currentSeconds: currentSeconds ?? this.currentSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      currentMode: currentMode ?? this.currentMode,
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
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
        other.currentMode == currentMode &&
        other.isMusicEnabled == isMusicEnabled &&
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
      currentSeconds,
      totalSeconds,
      sessionNumber,
      currentMode,
      isMusicEnabled,
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
    return 'TimerState(isActive: $isActive, currentSeconds: $currentSeconds, totalSeconds: $totalSeconds, sessionNumber: $sessionNumber, currentMode: $currentMode, isMusicEnabled: $isMusicEnabled, isMusicPlaying: $isMusicPlaying, currentMotivationalMessage: $currentMotivationalMessage, workDurationMinutes: $workDurationMinutes, shortBreakMinutes: $shortBreakMinutes, longBreakMinutes: $longBreakMinutes, currentVolume: $currentVolume, isLoading: $isLoading, error: $error, currentAnimation: $currentAnimation)';
  }
}
