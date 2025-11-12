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

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..value = 1;

    // al insertar, elegir animación acorde a estado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerState = ref.read(timerControllerProvider);
      _lastIsBreak = !timerState.currentMode.isWork;
      ref
          .read(animationsControllerProvider.notifier)
          .pickForSession(isBreak: _lastIsBreak);
    });
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
                    autostart: Autostart.loop,
                    fps: 24,
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
