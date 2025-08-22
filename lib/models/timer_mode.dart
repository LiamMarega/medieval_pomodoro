enum TimerMode {
  work('Work'),
  shortBreak('Short Break'),
  longBreak('Long Break');

  const TimerMode(this.displayName);

  final String displayName;

  bool get isWork => this == TimerMode.work;
  bool get isBreak =>
      this == TimerMode.shortBreak || this == TimerMode.longBreak;
  bool get isLongBreak => this == TimerMode.longBreak;
  bool get isShortBreak => this == TimerMode.shortBreak;
}

enum AnimationType {
  work1('assets/animations/knight_way_1.gif'),
  work2('assets/animations/knight_way_2.gif'),
  breakTime('assets/animations/breck_time.gif');

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

  static AnimationType _getRandomWorkAnimation() {
    final random = DateTime.now().millisecondsSinceEpoch % 2;
    return random == 0 ? AnimationType.work1 : AnimationType.work2;
  }

  static String _getRandomWorkMessage() {
    final messages = [
      "A knight's focus is their greatest weapon!",
      "Every quest begins with a single step forward.",
      "The castle of success is built one stone at a time.",
      "Honor your commitment to excellence, brave warrior!",
      "In the realm of productivity, consistency reigns supreme.",
      "Your dedication today forges tomorrow's victories.",
      "Like a steadfast knight, persist through challenges.",
      "The path to mastery requires unwavering discipline.",
    ];
    final random = DateTime.now().millisecondsSinceEpoch % messages.length;
    return messages[random];
  }

  static String _getRandomBreakMessage() {
    final messages = [
      "Even the mightiest warriors need rest.",
      "Take this moment to recharge your spirit.",
      "A well-rested knight is a victorious knight.",
      "Pause and reflect on your achievements.",
      "This break is your well-deserved reward.",
      "Rest now, conquer later.",
      "Your mind and body deserve this respite.",
      "Prepare for the next battle ahead.",
    ];
    final random = DateTime.now().millisecondsSinceEpoch % messages.length;
    return messages[random];
  }
}
