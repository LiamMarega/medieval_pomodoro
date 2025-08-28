import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medieval_pomodoro/core/widgets/inner_shadow.dart';
import 'package:gif/gif.dart';

class KnightIllustrationWidget extends ConsumerStatefulWidget {
  const KnightIllustrationWidget({super.key});

  @override
  ConsumerState<KnightIllustrationWidget> createState() =>
      _KnightIllustrationWidgetState();
}

class _KnightIllustrationWidgetState
    extends ConsumerState<KnightIllustrationWidget>
    with TickerProviderStateMixin {
  late final GifController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GifController(vsync: this);

    // Inicializar el controlador de GIF con un solo GIF
    _controller.repeat(
      min: 0,
      max: 1,
      period: const Duration(seconds: 7),
      reverse: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
              child: ColoredBox(
                color: Colors.black,
                child: Gif(
                  image: const AssetImage('assets/animations/knight_way_1.gif'),
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
            ),
          ),
        ),
      ),
    );
  }
}
