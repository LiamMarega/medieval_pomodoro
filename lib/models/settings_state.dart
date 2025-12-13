class SettingsState {
  final int workDurationMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final bool isMusicEnabled;
  final bool strictMode;
  final bool isLoading;
  final String? error;

  const SettingsState({
    this.workDurationMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 30,
    this.isMusicEnabled = true,
    this.strictMode = false,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    int? workDurationMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    bool? isMusicEnabled,
    bool? strictMode,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      strictMode: strictMode ?? this.strictMode,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsState &&
        other.workDurationMinutes == workDurationMinutes &&
        other.shortBreakMinutes == shortBreakMinutes &&
        other.longBreakMinutes == longBreakMinutes &&
        other.isMusicEnabled == isMusicEnabled &&
        other.strictMode == strictMode &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      workDurationMinutes,
      shortBreakMinutes,
      longBreakMinutes,
      isMusicEnabled,
      strictMode,
      isLoading,
      error,
    );
  }

  @override
  String toString() {
    return 'SettingsState(workDurationMinutes: $workDurationMinutes, shortBreakMinutes: $shortBreakMinutes, longBreakMinutes: $longBreakMinutes, isMusicEnabled: $isMusicEnabled, strictMode: $strictMode, isLoading: $isLoading, error: $error)';
  }
}
