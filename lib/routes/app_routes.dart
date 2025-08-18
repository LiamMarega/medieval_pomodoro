import 'package:flutter/material.dart';
import 'package:medieval_pomodoro/presentation/timer_screen/timer_screen_refactored.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String timer = '/timer-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const TimerScreenRefactored(),
    timer: (context) => const TimerScreenRefactored(),
    // TODO: Add your other routes here
  };
}
