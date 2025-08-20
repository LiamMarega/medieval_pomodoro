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
  String _motivationalMessage = '';

  // Control de notificación
  bool _timerNotificationCreated = false;
  Timer? _notificationUpdateTimer;

  static const String _channelKey = 'pomodoro_timer_channel';
  static const String _groupKey = 'pomodoro_group';
  static const int _timerNotificationId = 1;
  static const int _completionNotificationId = 2;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    debugPrint('🔔 Initializing NotificationService...');

    try {
      // Inicializar awesome_notifications
      await _initializeAwesomeNotifications();

      // Configurar listener para estados de app
      _setupForegroundBackgroundListener();

      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  /// Configura awesome_notifications
  Future<void> _initializeAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      null, // No usar ícono por defecto para evitar el error
      [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: 'Pomodoro Timer',
          channelDescription: 'Notifications for pomodoro timer sessions',
          defaultColor: const Color(0xFF8B4513), // Color medieval (marrón)
          ledColor: Colors.amber,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          onlyAlertOnce: false,
          playSound: false, // Sin sonido para no interrumpir la música
          criticalAlerts: false,
          locked: false, // Permitir que se pueda deslizar para cerrar en iOS
          defaultRingtoneType: DefaultRingtoneType.Notification,
          enableVibration: false,
          enableLights: false,
        ),
      ],
    );

    // Solicitar permisos
    await _requestPermissions();
  }

  /// Solicita permisos para notificaciones
  Future<void> _requestPermissions() async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      debugPrint('🔔 Notification permission status: $isAllowed');

      if (!isAllowed) {
        final result =
            await AwesomeNotifications().requestPermissionToSendNotifications();
        debugPrint('🔔 Permission request result: $result');
      }
    } catch (e) {
      debugPrint('❌ Error requesting notification permissions: $e');
    }
  }

  /// Configura el listener para detectar foreground/background
  void _setupForegroundBackgroundListener() {
    _fgbgSubscription = FGBGEvents.instance.stream.listen((event) {
      debugPrint('🔄 App state changed: $event');

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

  /// Se ejecuta cuando la app va al background
  void _onAppWentToBackground() {
    debugPrint('📱 App went to background');

    if (_isTimerActive && _currentSeconds > 0) {
      debugPrint('⏰ Timer is active, showing background notification');
      if (!_timerNotificationCreated) {
        _showTimerNotification();
        _timerNotificationCreated = true;
      }
      // _startNotificationUpdates();
    }
  }

  /// Se ejecuta cuando la app vuelve al foreground
  void _onAppWentToForeground() {
    debugPrint('📱 App came to foreground');

    // Cancelar timer de actualización de notificaciones
    _stopNotificationUpdates();

    // Cancelar notificación de timer si existe
    _cancelTimerNotification();
    _timerNotificationCreated = false;
  }

  /// Actualiza el estado del timer desde el provider
  void updateTimerState({
    required bool isActive,
    required int currentSeconds,
    required String sessionType,
    required String motivationalMessage,
  }) {
    _isTimerActive = isActive;
    _currentSeconds = currentSeconds;
    _sessionType = sessionType;
    _motivationalMessage = motivationalMessage;

    // Si la app está en background y el timer está activo, actualizar notificación
    if (_isAppInBackground && _isTimerActive && _currentSeconds > 0) {
      if (_timerNotificationCreated) {
        // _updateTimerNotification();
      }
    }
  }

  /// Muestra la notificación del timer con contador (solo se llama una vez)
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
        body: timeString, // El tiempo como body para que aparezca grande
        bigPicture:
            'https://tecnoblog.net/wp-content/uploads/2019/09/emoji.jpg', // Imagen de fondo con efecto difuminado
        largeIcon:
            'asset://assets/images/knight_icon.png', // Ícono del caballero
        notificationLayout:
            NotificationLayout.BigPicture, // Layout con imagen grande
        category: NotificationCategory.Progress,
        wakeUpScreen: true,
        fullScreenIntent: true,
        autoDismissible: false,
        showWhen: true,
        chronometer: Duration(seconds: _currentSeconds),
        customSound: null,
        payload: {
          'type': 'timer',
          'session_type': _sessionType,
          'current_seconds': _currentSeconds.toString(),
        },
        backgroundColor: const Color(0xFF2D1810), // Marrón oscuro medieval
        color: const Color(0xFFD4AF37), // Dorado medieval
      ),
    );

    debugPrint('🔔 Timer notification created: $timeString remaining');
  }

  /// Actualiza la notificación del timer existente
  void _updateTimerNotification() {
    final minutes = _currentSeconds ~/ 60;
    final seconds = _currentSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final sessionEmoji = _getSessionEmoji(_sessionType);

    // Usar createNotification con el mismo ID para actualizar la notificación existente
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _timerNotificationId,
        channelKey: _channelKey,
        groupKey: _groupKey,
        title: '$sessionEmoji $_sessionType Session',
        body: timeString, // El tiempo como body para que aparezca grande
        bigPicture:
            'https://tecnoblog.net/wp-content/uploads/2019/09/emoji.jpg', // Imagen de fondo con efecto difuminado
        largeIcon:
            'asset://assets/images/knight_icon.png', // Ícono del caballero
        notificationLayout:
            NotificationLayout.BigPicture, // Layout con imagen grande
        category: NotificationCategory.StopWatch,
        wakeUpScreen: false,
        fullScreenIntent: false,
        autoDismissible: false,
        showWhen: true,
        customSound: null,
        payload: {
          'type': 'timer',
          'session_type': _sessionType,
          'current_seconds': _currentSeconds.toString(),
        },
        backgroundColor: const Color(0xFF2D1810), // Marrón oscuro medieval
        color: const Color(0xFFD4AF37), // Dorado medieval
      ),
    );

    debugPrint('🔄 Timer notification updated: $timeString remaining');
  }

  /// Muestra notificación cuando se completa una sesión
  void showSessionCompletedNotification({
    required String completedSessionType,
    required String nextSessionType,
  }) {
    // Solo mostrar si la app está en background
    if (!_isAppInBackground) return;

    final completedEmoji = _getSessionEmoji(completedSessionType);
    final nextEmoji = _getSessionEmoji(nextSessionType);

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _completionNotificationId,
        channelKey: _channelKey,
        groupKey: _groupKey,
        title: '🎉 $completedEmoji $completedSessionType Completed!',
        body: '$nextEmoji Next: $nextSessionType session is ready to start',
        notificationLayout: NotificationLayout.BigPicture,
        category: NotificationCategory.Progress,
        wakeUpScreen: true,
        fullScreenIntent: true,
        autoDismissible: true,
        largeIcon: 'asset://assets/images/knight_icon.png',
        bigPicture: 'asset://assets/images/notification_background.png',
        payload: {
          'type': 'completion',
          'completed_session': completedSessionType,
          'next_session': nextSessionType,
        },
        backgroundColor: const Color(0xFF2D1810),
        color: const Color(0xFFD4AF37),
      ),
    );

    debugPrint(
        '🏆 Session completion notification shown: $completedSessionType -> $nextSessionType');
  }

  /// Inicia las actualizaciones periódicas de la notificación
  void _startNotificationUpdates() {
    _stopNotificationUpdates(); // Cancelar cualquier timer existente

    _notificationUpdateTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_isAppInBackground && _isTimerActive && _currentSeconds > 0) {
          // La notificación se actualizará automáticamente cuando se llame updateTimerState
          // desde el TimerController
        } else {
          _stopNotificationUpdates();
        }
      },
    );

    debugPrint('🔄 Started notification updates timer');
  }

  /// Detiene las actualizaciones de notificación
  void _stopNotificationUpdates() {
    _notificationUpdateTimer?.cancel();
    _notificationUpdateTimer = null;
    debugPrint('⏹️ Stopped notification updates timer');
  }

  /// Cancela la notificación del timer
  void _cancelTimerNotification() {
    AwesomeNotifications().cancel(_timerNotificationId);
    _timerNotificationCreated = false;
    debugPrint('❌ Timer notification cancelled');
  }

  /// Cancela todas las notificaciones
  void cancelAllNotifications() {
    AwesomeNotifications().cancelAll();
    debugPrint('❌ All notifications cancelled');
  }

  /// Obtiene el emoji correspondiente al tipo de sesión
  String _getSessionEmoji(String sessionType) {
    switch (sessionType.toLowerCase()) {
      case 'work':
        return '⚔️'; // Espada para trabajo
      case 'short break':
        return '🍯'; // Miel para descanso corto
      case 'long break':
        return '🏰'; // Castillo para descanso largo
      default:
        return '⏰'; // Reloj por defecto
    }
  }

  /// Maneja las acciones de las notificaciones
  static Future<void> onNotificationActionReceived(
    ReceivedAction receivedAction,
  ) async {
    debugPrint('🔔 Notification action received: ${receivedAction.actionType}');

    switch (receivedAction.actionType) {
      case ActionType.Default:
        // Acción por defecto (tap en la notificación)
        debugPrint('👆 User tapped notification');
        break;

      case ActionType.SilentAction:
        // Acciones específicas de los botones
        switch (receivedAction.buttonKeyPressed) {
          case 'START_NEXT':
            debugPrint('▶️ User pressed Start Next Session');
            // Aquí puedes agregar lógica para iniciar la siguiente sesión
            break;
          case 'OPEN_APP':
            debugPrint('📱 User pressed Open App');
            // La app se abrirá automáticamente
            break;
        }
        break;

      case ActionType.SilentBackgroundAction:
        debugPrint('🔇 Silent background action');
        break;

      default:
        debugPrint('❓ Unknown action type: ${receivedAction.actionType}');
    }
  }

  /// Libera recursos
  void dispose() {
    debugPrint('🗑️ Disposing NotificationService...');

    _fgbgSubscription?.cancel();
    _stopNotificationUpdates();
    cancelAllNotifications();

    debugPrint('✅ NotificationService disposed');
  }

  // Getters para debugging
  bool get isAppInBackground => _isAppInBackground;
  bool get isTimerActive => _isTimerActive;
  int get currentSeconds => _currentSeconds;
}
