import 'package:flutter/material.dart';
import 'package:medieval_pomodoro/core/widgets/inner_shadow.dart';
import 'package:gif/gif.dart';

class KnightIllustrationWidget extends StatefulWidget {
  const KnightIllustrationWidget({super.key});

  @override
  State<KnightIllustrationWidget> createState() =>
      _KnightIllustrationWidgetState();
}

class _KnightIllustrationWidgetState extends State<KnightIllustrationWidget>
    with TickerProviderStateMixin {
  late final GifController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GifController(vsync: this);
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
              key: Key('shadow'),
              child: Gif(
                image:
                    const AssetImage('assets/animations/dragon_dark_room.gif'),
                controller: _controller,
                fit: BoxFit.cover,
                duration: const Duration(
                  seconds: 7,
                ), // Controla la velocidad de reproducción
                autostart: Autostart.no, // No arranca automáticamente

                placeholder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
                onFetchCompleted: () {
                  // Cuando termina de cargar, arrancamos en bucle ida-vuelta
                  _controller.repeat(
                    min: 0,
                    max: 1,
                    reverse: true, // Esto hace el efecto ping-pong
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
