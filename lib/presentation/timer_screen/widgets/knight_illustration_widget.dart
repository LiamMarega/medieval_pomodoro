import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medieval_pomodoro/core/widgets/inner_shadow.dart';
import 'package:gif/gif.dart';
import '../../../providers/animations_provider.dart';
import '../../../providers/timer_provider.dart';

class KnightIllustrationWidget extends ConsumerStatefulWidget {
  const KnightIllustrationWidget({super.key});

  @override
  ConsumerState<KnightIllustrationWidget> createState() =>
      _KnightIllustrationWidgetState();
}

class _KnightIllustrationWidgetState
    extends ConsumerState<KnightIllustrationWidget>
    with TickerProviderStateMixin {
  late final AnimationController _fade;
  GifController? _gifController;
  late final AnimationController _pingPongController;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..value = 1;

    // Controlador para el efecto ping-pong
    _pingPongController = AnimationController(
      vsync: this,
      duration: const Duration(
          seconds: 4), // Duración del ciclo completo (ida y vuelta)
    )..repeat(reverse: true);

    // Escuchar cambios en el ping-pong controller para controlar el GIF
    _pingPongController.addListener(_handlePingPongAnimation);

    // al insertar, elegir animación acorde a estado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerState = ref.read(timerControllerProvider);
      _lastIsBreak = !timerState.currentMode.isWork;
      ref
          .read(animationsControllerProvider.notifier)
          .pickForSession(isBreak: _lastIsBreak);
    });
  }

  void _handlePingPongAnimation() {
    if (_gifController == null) return;

    // Mapear el valor del ping-pong controller (0.0 a 1.0 y vuelta) al frame del GIF
    // Cuando va hacia adelante: 0.0 -> 1.0 (frames 0 a N)
    // Cuando va hacia atrás: 1.0 -> 0.0 (frames N a 0)
    // El GifController.value va de 0.0 (primer frame) a 1.0 (último frame)
    _gifController!.value = _pingPongController.value;
  }

  bool _lastIsBreak = false;

  @override
  void didUpdateWidget(covariant KnightIllustrationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final timerState = ref.watch(timerControllerProvider);
    final isBreak = !timerState.currentMode.isWork;

    if (_lastIsBreak != isBreak) {
      _lastIsBreak = isBreak;
      _boomerang(() {
        ref
            .read(animationsControllerProvider.notifier)
            .pickForSession(isBreak: isBreak);
      });
    }
  }

  Future<void> _boomerang(VoidCallback change) async {
    await _fade.reverse();
    change();
    await _fade.forward();
  }

  @override
  void dispose() {
    _fade.dispose();
    _pingPongController.dispose();
    _gifController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anim = ref.watch(animationsControllerProvider).current;

    if (anim == null) {
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
              child: const InnerShadow(
                child: ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

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
              child: ColoredBox(
                color: Colors.black,
                child: FadeTransition(
                  opacity: _fade,
                  child: Gif(
                    image: AssetImage(anim.path),
                    controller: _gifController ??= GifController(vsync: this),
                    autostart: Autostart.no,
                    fps: 8, // Reducido de 24 a 12 para que vaya más lento
                    fit: BoxFit.cover,
                    placeholder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
