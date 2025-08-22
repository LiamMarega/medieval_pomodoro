import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medieval_pomodoro/models/timer_mode.dart';
import 'package:medieval_pomodoro/core/widgets/inner_shadow.dart';
import 'package:medieval_pomodoro/providers/timer_provider.dart';
import 'package:gif/gif.dart';

class KnightIllustrationWidget extends ConsumerStatefulWidget {
  final TimerMode currentMode;
  final AnimationType currentAnimation;
  final VoidCallback? onTransitionComplete;

  const KnightIllustrationWidget({
    super.key,
    required this.currentMode,
    required this.currentAnimation,
    this.onTransitionComplete,
  });

  @override
  ConsumerState<KnightIllustrationWidget> createState() =>
      _KnightIllustrationWidgetState();
}

class _KnightIllustrationWidgetState
    extends ConsumerState<KnightIllustrationWidget>
    with TickerProviderStateMixin {
  late final GifController _controller;
  late final AnimationController _transitionController;

  String _currentGifPath = '';
  TimerMode? _lastMode;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _controller = GifController(vsync: this);

    // Inicializar controlador de transición
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 1000), // 500ms + 500ms
      vsync: this,
    );

    _updateGifPath();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Verificar que el widget aún está montado antes de procesar cambios
    if (!mounted) return;

    // Escuchar cambios en el TimerProvider
    final timerState = ref.watch(timerControllerProvider);
    _handleModeChange(timerState.currentMode);
  }

  void _handleModeChange(TimerMode newMode) {
    // Solo ejecutar transición si el modo realmente cambió y no estamos ya en transición
    if (_lastMode != null && _lastMode != newMode && !_isTransitioning) {
      _startTransition();
    }
    _lastMode = newMode;
  }

  void _startTransition() {
    if (_isTransitioning || !mounted) return;

    setState(() {
      _isTransitioning = true;
    });

    // Ejecutar animación boomerang
    _transitionController.forward().then((_) {
      // Verificar que el widget aún está montado
      if (!mounted) return;

      // Cambiar el GIF en el punto medio de la transición (opacidad = 0)
      _updateGifPath();

      // Continuar con la segunda mitad de la animación (0 → 1)
      _transitionController.reverse().then((_) {
        // Verificar que el widget aún está montado
        if (mounted) {
          setState(() {
            _isTransitioning = false;
          });

          // Notificar que la transición completó
          widget.onTransitionComplete?.call();
        }
      });
    });
  }

  @override
  void didUpdateWidget(KnightIllustrationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Verificar si el modo o la animación han cambiado
    if (oldWidget.currentMode != widget.currentMode ||
        oldWidget.currentAnimation != widget.currentAnimation) {
      // La actualización del GIF se maneja en _handleModeChange para evitar duplicados
    }
  }

  void _updateGifPath() {
    String newGifPath;

    if (widget.currentMode.isBreak) {
      // Si está en break, mostrar breck_time.gif
      newGifPath = 'assets/animations/breck_time.gif';
    } else {
      // Si está en work, mostrar aleatoriamente knight_way_1.gif o knight_way_2.gif
      final random = DateTime.now().millisecondsSinceEpoch % 2;
      newGifPath = random == 0
          ? 'assets/animations/knight_way_1.gif'
          : 'assets/animations/knight_way_2.gif';
    }

    if (_currentGifPath != newGifPath) {
      setState(() {
        _currentGifPath = newGifPath;
      });

      // Verificar que el widget aún está montado antes de continuar
      if (mounted) {
        // Reiniciar el controlador para la nueva animación
        _controller.reset();
        Future.delayed(const Duration(milliseconds: 100), () {
          // Verificar nuevamente que el widget aún está montado
          if (mounted) {
            _controller.repeat(
              min: 0,
              max: 1,
              period: const Duration(seconds: 7),
              reverse: true, // Efecto ping-pong para animación suave
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.5),
              width: 5,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 5,
              ),
            ),
            child: InnerShadow(
              child: AnimatedBuilder(
                animation: _transitionController,
                builder: (context, child) {
                  // Calcular opacidad para efecto boomerang
                  double opacity;
                  if (_transitionController.value <= 0.5) {
                    // Primera mitad: 1 → 0
                    opacity = 1.0 - (_transitionController.value * 2);
                  } else {
                    // Segunda mitad: 0 → 1
                    opacity = (_transitionController.value - 0.5) * 2;
                  }

                  return Opacity(
                    opacity: opacity,
                    child: Gif(
                      image: AssetImage(_currentGifPath),
                      controller: _controller,
                      fit: BoxFit.cover,
                      duration: const Duration(seconds: 7),
                      placeholder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      onFetchCompleted: () {
                        // Verificar que el widget aún está montado antes de continuar
                        if (mounted) {
                          // Cuando termina de cargar, arrancamos en bucle ida-vuelta
                          _controller.repeat(
                            min: 0,
                            max: 1,
                            period: const Duration(seconds: 7),
                            reverse: true, // Esto hace el efecto ping-pong
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
