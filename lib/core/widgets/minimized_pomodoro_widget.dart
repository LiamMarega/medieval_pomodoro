
// lib/widgets/minimized_pomodoro_widget.dart
// Widget "minimizado" moderno para mostrar al reducir/ocultar la app.
// Diseño: a la IZQUIERDA contador grande (mm:ss), a la DERECHA imagen cuadrada 1:1.
// Imagen: assets/images/knight_pomodoro_icon.png
//
// El widget es auto-contenido (no necesita Riverpod). Lo podés usar dentro
// de tus pantallas o como overlay. Incluye botones básicos (pausa/reanuda/detener).

import 'package:flutter/material.dart';

class MinimizedPomodoroWidget extends StatelessWidget {
  const MinimizedPomodoroWidget({
    super.key,
    required this.remaining,
    required this.isRunning,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    this.title = 'Pomodoro',
    this.compact = false,
  });

  /// Duración restante.
  final Duration remaining;

  /// ¿Está corriendo?
  final bool isRunning;

  /// Callbacks de control.
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  /// Título opcional.
  final String title;

  /// Si true, reduce paddings/tamaños (útil en pantallas muy pequeñas).
  final bool compact;

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    final timeStr = '${_two(minutes)}:${_two(seconds)}';

    final borderRadius = BorderRadius.circular(20);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final cardColor = theme.colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // ---- LADO IZQUIERDO: Contador + Título + Controles ----
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(compact ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título / estado
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            title,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusDot(isRunning: isRunning),
                      ],
                    ),
                    SizedBox(height: compact ? 8 : 12),
                    // Contador grande
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        timeStr,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 8 : 12),
                    // Controles
                    Row(
                      children: [
                        if (isRunning)
                          _ActionButton(
                            icon: Icons.pause_rounded,
                            label: 'Pausar',
                            onTap: onPause,
                          )
                        else
                          _ActionButton(
                            icon: Icons.play_arrow_rounded,
                            label: 'Reanudar',
                            onTap: onResume,
                          ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.stop_rounded,
                          label: 'Detener',
                          onTap: onStop,
                          tone: _ActionTone.danger,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // ---- LADO DERECHO: Imagen 1:1 ----
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 1, // fuerza cuadrado
                child: _HeroImage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.isRunning});
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final color = isRunning ? Colors.green : Colors.orange;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isRunning ? 'En curso' : 'Pausado',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}

enum _ActionTone { normal, danger }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tone = _ActionTone.normal,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final _ActionTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDanger = tone == _ActionTone.danger;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDanger
              ? theme.colorScheme.error.withOpacity(0.12)
              : theme.colorScheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDanger ? theme.colorScheme.error : theme.colorScheme.primary)
                .withOpacity(0.24),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDanger ? theme.colorScheme.error : theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDanger ? theme.colorScheme.error : theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replica un estilo de "imagen widget" moderno: bordes redondeados y leve sombra.
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/knight_pomodoro_icon.png',
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
