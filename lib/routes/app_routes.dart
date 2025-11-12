import 'package:flutter/material.dart';
import 'package:medieval_pomodoro/presentation/onboarding/onboarding_integration.dart';
import 'package:medieval_pomodoro/presentation/stats_screen/stats_screen.dart';
import 'package:medieval_pomodoro/presentation/timer_screen/timer_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String timer = '/timer-screen';
  static const String stats = '/stats-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) =>
        OnboardingIntegration.buildInitialScreen(const TimerScreen()),
    timer: (context) => const TimerScreen(),
    stats: (context) => const StatsScreen(),
    // TODO: Add your other routes here
  };
}
