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

  TimerMode? _lastMode;
  bool _isTransitioning = false;
  bool _showNextImage = false;

  @override
  void initState() {
    super.initState();
    _controller = GifController(vsync: this);

    // Inicializar controlador de transición
    _transitionController = AnimationController(
      duration: const Duration(
          milliseconds: 500), // 500ms para cada fase (desvanecer/aparecer)
      vsync: this,
    );

    // Inicializar el controlador de GIF
    _controller.repeat(
      min: 0,
      max: 1,
      period: const Duration(seconds: 7),
      reverse: true,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Verificar que el widget aún está montado antes de procesar cambios
    if (!mounted) return;

    // Escuchar cambios en el TimerProvider
    final timerState = ref.watch(timerControllerProvider);

    debugPrint(
        '🎭 KnightIllustration: didChangeDependencies called - Mode: ${timerState.currentMode.displayName}, Animation: ${timerState.currentAnimation.assetPath}');

    // Solo inicializar el modo la primera vez
    if (_lastMode == null) {
      _lastMode = timerState.currentMode;
      debugPrint(
          '🎭 KnightIllustration: Initial mode set to ${timerState.currentMode.displayName}');
    }
  }

  @override
  void didUpdateWidget(KnightIllustrationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    debugPrint('🎭 KnightIllustration: didUpdateWidget called');

    // Verificar si el modo o la animación han cambiado
    if (oldWidget.currentMode != widget.currentMode ||
        oldWidget.currentAnimation != widget.currentAnimation) {
      _handleModeChange(widget.currentMode);
    }
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

    debugPrint('🎭 KnightIllustration: Transition started');

    // Preparar el siguiente GIF antes de la transición
    _prepareNextGif();

    setState(() {
      _isTransitioning = true;
      _showNextImage = false;
    });

    // Primera fase: desvanecer imagen actual (1 → 0)
    _transitionController.forward().then((_) {
      // Verificar que el widget aún está montado
      if (!mounted) return;

      debugPrint(
          '🎭 KnightIllustration: First phase completed - showing next image');

      // Segunda fase: mostrar la nueva imagen
      setState(() {
        _showNextImage = true;
      });

      // Tercera fase: hacer aparecer la nueva imagen (0 → 1)
      _transitionController.reverse().then((_) {
        // Verificar que el widget aún está montado
        if (mounted) {
          debugPrint('🎭 KnightIllustration: Transition completed');
          setState(() {
            _isTransitioning = false;
          });

          // Notificar que la transición completó
          widget.onTransitionComplete?.call();
        }
      });
    });
  }

  void _prepareNextGif() {
    debugPrint(
        '🎭 KnightIllustration: Preparing next GIF for mode: ${widget.currentMode.displayName}');
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
                  double opacity;

                  if (!_showNextImage) {
                    // Primera fase: desvanecer imagen actual (1 → 0)
                    opacity = 1.0 - _transitionController.value;
                  } else {
                    // Segunda fase: hacer aparecer nueva imagen (0 → 1)
                    opacity = _transitionController.value;
                  }

                  return ColoredBox(
                    color: Colors.black,
                    child: Opacity(
                      opacity: opacity,
                      child: Gif(
                        image: AssetImage(widget.currentAnimation.assetPath),
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
