import 'package:flutter/material.dart';
import 'package:medieval_pomodoro/presentation/timer_screen/timer_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String timer = '/timer-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const TimerScreen(),
    timer: (context) => const TimerScreen(),
    // TODO: Add your other routes here
  };
}
