import 'package:audio_service/audio_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medieval_pomodoro/presentation/onboarding/onboarding_integration.dart';
import 'package:medieval_pomodoro/presentation/timer_screen/timer_screen.dart';
import 'package:sizer/sizer.dart';

import 'core/app_export.dart';
import 'core/services/notification_service.dart';
import 'providers/audio_provider.dart';
import 'services/audio/audio_service_handler.dart';
import 'widgets/custom_error_widget.dart';
import 'presentation/settings_screen/settings_screen.dart';
import 'presentation/stats_screen/stats_screen.dart';

late AudioHandler _audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  // Initialize Notification Service
  await NotificationService().initialize();

  // Initialize Audio Service
  _audioHandler = await AudioService.init(
    builder: () => AudioServiceHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.medieval_pomodoro.channel.audio',
      androidNotificationChannelName: 'Medieval Pomodoro Audio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      // Esto asegura la notificación estilo Spotify
    ),
  );

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(
      errorDetails: details,
    );
  };

  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: ProviderScope(
          overrides: [
            audioHandlerProvider.overrideWithValue(_audioHandler),
          ],
          child: const MyApp(),
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
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        // 🚨 END CRITICAL SECTION
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) =>
              OnboardingIntegration.buildInitialScreen(const TimerScreen()),
          '/timer-screen': (context) => const TimerScreen(),
          '/settings-screen': (context) => const SettingsScreen(),
          '/stats-screen': (context) => const StatsScreen(),
        },
        initialRoute: '/',
      );
    });
  }
}
