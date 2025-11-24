import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Subscription para detectar estados de foreground/background
  StreamSubscription<FGBGType>? _fgbgSubscription;

  // Control de estado de la app
  bool _isAppInBackground = false;
  bool _isTimerActive = false;
  int _currentSeconds = 0;
  String _sessionType = 'Work';

  // Control de notificación
  bool _timerNotificationCreated = false;
  Timer? _notificationUpdateTimer;

  static const String _channelKey = 'pomodoro_timer_channel';
  static const String _mediaChannelKey = 'media_player_channel';
  static const String _groupKey = 'pomodoro_group';
  static const int _timerNotificationId = 1;
  static const int _completionNotificationId = 2;
  static const int _mediaNotificationId = 3;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    debugPrint('🔔 Initializing NotificationService...');

    try {
      // Inicializar awesome_notifications
      await _initializeAwesomeNotifications();

      // Configurar listener para estados de app
      _setupForegroundBackgroundListener();

      // Configurar listeners de acciones
      await AwesomeNotifications().setListeners(
        onActionReceivedMethod: onNotificationActionReceived,
      );

      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  /// Configura awesome_notifications
  Future<void> _initializeAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      null, // Icono por defecto (null usa el de la app)
      [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: 'Focus Knight Timer',
          channelDescription: 'Notifications for Pomodoro Timer',
          defaultColor: const Color(0xFF8B4513),
          ledColor: Colors.amber,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: false,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: _mediaChannelKey,
          channelName: 'Media Controls',
          channelDescription: 'Media playback controls',
          defaultColor: const Color(0xFF8B4513),
          ledColor: Colors.amber,
          importance: NotificationImportance
              .Low, // Low para evitar sonido/pop-up constante
          channelShowBadge: false,
          playSound: false,
          enableVibration: false,
          locked: true, // Persistente
        ),
      ],
    );

    await _requestPermissions();
  }

  /// Solicita permisos para notificaciones
  Future<void> _requestPermissions() async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    } catch (e) {
      debugPrint('❌ Error requesting notification permissions: $e');
    }
  }

  void _setupForegroundBackgroundListener() {
    _fgbgSubscription = FGBGEvents.instance.stream.listen((event) {
      switch (event) {
        case FGBGType.background:
          _isAppInBackground = true;
          _onAppWentToBackground();
          break;
        case FGBGType.foreground:
          _isAppInBackground = false;
          _onAppWentToForeground();
          break;
      }
    });
  }

  void _onAppWentToBackground() {
    if (_isTimerActive && _currentSeconds > 0) {
      if (!_timerNotificationCreated) {
        _showTimerNotification();
        _timerNotificationCreated = true;
      }
    }
  }

  void _onAppWentToForeground() {
    _stopNotificationUpdates();
    _cancelTimerNotification();
    _timerNotificationCreated = false;
  }

  void updateTimerState({
    required bool isActive,
    required int currentSeconds,
    required String sessionType,
    required String motivationalMessage,
  }) {
    _isTimerActive = isActive;
    _currentSeconds = currentSeconds;
    _sessionType = sessionType;

    if (_isAppInBackground && _isTimerActive && _currentSeconds > 0) {
      if (_timerNotificationCreated) {
        // Actualizar notificación existente si es necesario
        // _showTimerNotification(); // Llamar con debounce si se actualiza cada segundo
      }
    }
  }

  void _showTimerNotification() {
    final minutes = _currentSeconds ~/ 60;
    final seconds = _currentSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final sessionEmoji = _getSessionEmoji(_sessionType);

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _timerNotificationId,
        channelKey: _channelKey,
        groupKey: _groupKey,
        title: '$sessionEmoji $_sessionType Session',
        body: timeString,
        notificationLayout:
            NotificationLayout.Default, // Usar Default o BigText
        category: NotificationCategory.Progress,
        wakeUpScreen: true,
        fullScreenIntent: true,
        autoDismissible: false,
        locked: true,
        payload: {
          'type': 'timer',
          'session_type': _sessionType,
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'STOP_TIMER',
          label: 'Stop',
          actionType: ActionType.SilentAction,
        ),
      ],
    );
  }

  void showSessionCompletedNotification({
    required String completedSessionType,
    required String nextSessionType,
  }) {
    if (!_isAppInBackground) return;

    final completedEmoji = _getSessionEmoji(completedSessionType);
    final nextEmoji = _getSessionEmoji(nextSessionType);

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _completionNotificationId,
        channelKey: _channelKey,
        groupKey: _groupKey,
        title: '🎉 $completedEmoji $completedSessionType Completed!',
        body: '$nextEmoji Next: $nextSessionType session is ready',
        notificationLayout: NotificationLayout.BigPicture,
        bigPicture:
            'asset://assets/images/notification_background.png', // Asegurar que exista
        wakeUpScreen: true,
        category: NotificationCategory.Alarm,
        fullScreenIntent: true,
        payload: {
          'type': 'completion',
          'next_session': nextSessionType,
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'START_NEXT',
          label: 'Start Next',
          actionType: ActionType.SilentAction,
        ),
      ],
    );
  }

  /// Método opcional para mostrar controles de media con AwesomeNotifications
  /// (Si se prefiere sobre la nativa de audio_service)
  Future<void> showMediaNotification({
    required String title,
    required String artist,
    required bool isPlaying,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _mediaNotificationId,
        channelKey: _mediaChannelKey,
        title: title,
        body: artist,
        notificationLayout: NotificationLayout.MediaPlayer,
        locked: true,
        autoDismissible: false,
        category: NotificationCategory.Transport,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'AUDIO_PREV',
          icon:
              'resource://drawable/res_ic_prev', // Necesitas iconos en res/drawable
          label: 'Previous',
          autoDismissible: false,
          showInCompactView: true,
          actionType: ActionType.KeepOnTop,
        ),
        NotificationActionButton(
          key: isPlaying ? 'AUDIO_PAUSE' : 'AUDIO_PLAY',
          icon: isPlaying
              ? 'resource://drawable/res_ic_pause'
              : 'resource://drawable/res_ic_play',
          label: isPlaying ? 'Pause' : 'Play',
          autoDismissible: false,
          showInCompactView: true,
          actionType: ActionType.KeepOnTop,
        ),
        NotificationActionButton(
          key: 'AUDIO_NEXT',
          icon: 'resource://drawable/res_ic_next',
          label: 'Next',
          autoDismissible: false,
          showInCompactView: true,
          actionType: ActionType.KeepOnTop,
        ),
      ],
    );
  }

  void _stopNotificationUpdates() {
    _notificationUpdateTimer?.cancel();
    _notificationUpdateTimer = null;
  }

  void _cancelTimerNotification() {
    AwesomeNotifications().cancel(_timerNotificationId);
    _timerNotificationCreated = false;
  }

  void cancelAllNotifications() {
    AwesomeNotifications().cancelAll();
  }

  String _getSessionEmoji(String sessionType) {
    switch (sessionType.toLowerCase()) {
      case 'work':
        return '⚔️';
      case 'short break':
        return '🍯';
      case 'long break':
        return '🏰';
      default:
        return '⏰';
    }
  }

  /// Callback estático para acciones
  @pragma("vm:entry-point")
  static Future<void> onNotificationActionReceived(
      ReceivedAction receivedAction) async {
    debugPrint('🔔 Action Received: ${receivedAction.buttonKeyPressed}');

    // Para interactuar con audio_service desde aquí, necesitamos acceso al handler.
    // Como es estático, dependemos de que el servicio esté corriendo o sea accesible.
    // En una app Flutter normal, el isolate principal sigue vivo.

    // NOTA: Esto asume que tienes acceso a _audioHandler global o via GetIt.
    // Si no, deberías usar ports o audio_service custom actions.

    // Aquí un ejemplo de cómo mapear las acciones:
    /*
    final audioHandler = GetIt.I<AudioHandler>(); // Si usas GetIt
    switch (receivedAction.buttonKeyPressed) {
      case 'AUDIO_PLAY':
        audioHandler.play();
        break;
      case 'AUDIO_PAUSE':
        audioHandler.pause();
        break;
      case 'AUDIO_NEXT':
        audioHandler.skipToNext();
        break;
      case 'AUDIO_PREV':
        audioHandler.skipToPrevious();
        break;
    }
    */

    // Si el usuario pulsa START_NEXT en la notificación de Pomodoro
    if (receivedAction.buttonKeyPressed == 'START_NEXT') {
      // Lógica para iniciar siguiente sesión
      // Esto requeriría comunicar con el TimerProvider
    }
  }

  void dispose() {
    _fgbgSubscription?.cancel();
    _stopNotificationUpdates();
    cancelAllNotifications();
  }
}
