import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medieval_pomodoro/presentation/onboarding/screens/onboarding_screen.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import 'presentation/settings_screen/settings_screen.dart';
import 'core/services/live_activity_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(
      errorDetails: details,
    );
  };

  // Initialize Live Activity Manager
  final liveActivityManager = LiveActivityManager();
  await liveActivityManager.init();

  // Create initial live activity with user data
  await liveActivityManager.createFocusActivity(
    userName: "Liam", // O obtenerlo de SharedPreferences
    sessionType: "Focus",
    currentSession: 1,
    timeRemaining: 1500, // 25 minutes
    paused: false,
  );

  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const ProviderScope(
          child: MyApp(),
        ),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'medieval_pomodoro',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        // 🚨 END CRITICAL SECTION
        debugShowCheckedModeBanner: false,
        routes: {
          // '/': (context) => const TimerScreen(),
          // '/onboarding-screen': (context) => const OnboardingScreen(),
          '/settings-screen': (context) => const SettingsScreen(),
          '/': (context) => const OnboardingScreen(),
        },
        initialRoute: '/',
      );
    });
  }
}
