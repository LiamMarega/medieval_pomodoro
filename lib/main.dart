import 'package:audio_service/audio_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medieval_pomodoro/presentation/timer_screen/timer_screen.dart';
import 'package:sizer/sizer.dart';

import 'core/app_export.dart';
import 'core/services/notification_service.dart';
import 'providers/audio_provider.dart';
import 'providers/app_blocker_provider.dart';
import 'services/audio/audio_service_handler.dart';
import 'widgets/custom_error_widget.dart';
import 'presentation/settings_screen/settings_screen.dart';
import 'presentation/stats_screen/stats_screen.dart';
import 'presentation/initial_loading_screen.dart';

late AudioHandler _audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  // Initialize Notification Service
  await NotificationService().initialize();

  // Initialize Audio Service
  _audioHandler = await AudioService.init(
    builder: () => UnifiedAudioHandler(),
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

class AppBlockerInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const AppBlockerInitializer({super.key, required this.child});

  @override
  ConsumerState<AppBlockerInitializer> createState() =>
      _AppBlockerInitializerState();
}

class _AppBlockerInitializerState extends ConsumerState<AppBlockerInitializer> {
  @override
  void initState() {
    super.initState();
    // Inicialización segura del bloqueador de apps
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAppBlocker();
    });
  }

  Future<void> _initAppBlocker() async {
    try {
      debugPrint('🛡️ Initializing App Blocker...');
      // 1. Desbloquear todo al inicio por seguridad (si la app crasheó antes)
      await ref.read(appBlockerProvider.notifier).unblockAll();

      // 2. Solicitar permisos si es necesario (opcional, mejor hacerlo en settings)
      // await ref.read(appBlockerProvider.notifier).requestPermissions();

      debugPrint('✅ App Blocker initialized');
    } catch (e) {
      debugPrint('❌ Error initializing App Blocker: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
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
          '/': (context) => const InitialLoadingScreen(),
          '/timer-screen': (context) => const TimerScreen(),
          '/settings-screen': (context) => const SettingsScreen(),
          '/stats-screen': (context) => const StatsScreen(),
        },
        initialRoute: '/',
      );
    });
  }
}
