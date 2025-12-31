enum TimerMode {
  work('Work'),
  shortBreak('Short Break'),
  longBreak('Long Break'),
  gapTime('Gap Time');

  const TimerMode(this.displayName);

  final String displayName;

  bool get isWork => this == TimerMode.work;
  bool get isBreak =>
      this == TimerMode.shortBreak || this == TimerMode.longBreak;
  bool get isLongBreak => this == TimerMode.longBreak;
  bool get isShortBreak => this == TimerMode.shortBreak;
  bool get isGapTime => this == TimerMode.gapTime;
}

enum AnimationType {
  work1('assets/animations/knight_way_1.gif'),
  work2('assets/animations/knight_way_2.gif'),
  breakTime('assets/animations/break_time.gif'),
  gapTime('assets/animations/dragon_dark_room.gif');

  const AnimationType(this.assetPath);

  final String assetPath;
}

class TimerModeConfig {
  final TimerMode mode;
  final int durationMinutes;
  final AnimationType animationType;
  final String motivationalMessage;

  const TimerModeConfig({
    required this.mode,
    required this.durationMinutes,
    required this.animationType,
    required this.motivationalMessage,
  });

  static TimerModeConfig getWorkConfig({
    required int durationMinutes,
    String? motivationalMessage,
  }) {
    return TimerModeConfig(
      mode: TimerMode.work,
      durationMinutes: durationMinutes,
      animationType: _getRandomWorkAnimation(),
      motivationalMessage: motivationalMessage ?? _getRandomWorkMessage(),
    );
  }

  static TimerModeConfig getShortBreakConfig({
    required int durationMinutes,
    String? motivationalMessage,
  }) {
    return TimerModeConfig(
      mode: TimerMode.shortBreak,
      durationMinutes: durationMinutes,
      animationType: AnimationType.breakTime,
      motivationalMessage: motivationalMessage ?? _getRandomBreakMessage(),
    );
  }

  static TimerModeConfig getLongBreakConfig({
    required int durationMinutes,
    String? motivationalMessage,
  }) {
    return TimerModeConfig(
      mode: TimerMode.longBreak,
      durationMinutes: durationMinutes,
      animationType: AnimationType.breakTime,
      motivationalMessage: motivationalMessage ?? _getRandomBreakMessage(),
    );
  }

  static TimerModeConfig getGapTimeConfig() {
    return const TimerModeConfig(
      mode: TimerMode.gapTime,
      durationMinutes: 0, // Will be handled as 3 seconds in timer provider
      animationType: AnimationType.gapTime,
      motivationalMessage: "Preparing for next session...",
    );
  }

  static AnimationType _getRandomWorkAnimation() {
    final random = DateTime.now().millisecondsSinceEpoch % 2;
    return random == 0 ? AnimationType.work1 : AnimationType.work2;
  }

  static String _getRandomWorkMessage() {
    const int totalMessages = 99;
    final random = DateTime.now().millisecondsSinceEpoch % totalMessages;
    return "knight_quotes.$random";
  }

  static String _getRandomBreakMessage() {
    const int totalMessages = 8;
    final random = DateTime.now().millisecondsSinceEpoch % totalMessages;
    return "knight_break_quotes.$random";
  }
}
