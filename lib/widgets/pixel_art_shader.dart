import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Widget que aplica un fragment shader de pixel art 16 bits sobre su contenido
///
/// Este widget carga un shader GLSL que:
/// - Reduce la resolución aparente (píxeles grandes estilo retro)
/// - Limita la paleta de colores a 16-32 colores
/// - Mantiene bordes definidos tipo videojuego de los 90s
class PixelArtShaderFilter extends StatefulWidget {
  /// El widget hijo sobre el que se aplicará el efecto
  final Widget child;

  /// Tamaño de los bloques de píxel (mayor = píxeles más grandes)
  /// Valores típicos: 32-128 para pantallas modernas
  final double pixelSize;

  /// Número de colores en la paleta (16 para efecto más auténtico, hasta 32)
  final int colorCount;

  /// Si es true, usa BackdropFilter (más eficiente, aplica sobre contenido existente)
  /// Si es false, captura el widget como imagen primero (más costoso pero más control)
  final bool useBackdropFilter;

  const PixelArtShaderFilter({
    super.key,
    required this.child,
    this.pixelSize = 64.0,
    this.colorCount = 16,
    this.useBackdropFilter = true,
  });

  @override
  State<PixelArtShaderFilter> createState() => _PixelArtShaderFilterState();
}

class _PixelArtShaderFilterState extends State<PixelArtShaderFilter> {
  ui.FragmentProgram? _program;
  bool _isLoading = true;
  String? _error;
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      _program = await ui.FragmentProgram.fromAsset('shaders/pixel_art.frag');
      debugPrint('✅ Pixel art shader cargado correctamente');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando pixel art shader: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      debugPrint('⏳ Cargando shader...');
      return widget.child; // Muestra el contenido original mientras carga
    }

    if (_error != null || _program == null) {
      // Si hay error, muestra el contenido sin efecto
      debugPrint('❌ Error: $_error');
      return widget.child;
    }

    debugPrint(
        '✅ Aplicando shader con pixelSize: ${widget.pixelSize}, colorCount: ${widget.colorCount}');

    if (widget.useBackdropFilter) {
      return _buildWithBackdropFilter();
    } else {
      return _buildWithImageCapture();
    }
  }

  /// Implementación usando BackdropFilter (más eficiente)
  /// BackdropFilter aplica el shader sobre el contenido que ya está renderizado
  Widget _buildWithBackdropFilter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (size.width <= 0 || size.height <= 0) {
          return widget.child;
        }

        final shader = _program!.fragmentShader();

        // IMPORTANTE: Con ImageFilter.shader(), el orden de uniforms es:
        // - El primer uniforme DEBE ser vec2 con el tamaño (índices 0, 1)
        // - El sampler2D se configura automáticamente por Flutter (no lo configuramos)
        // - Los demás uniforms siguen en orden después del sampler

        // u_size (vec2) - índices 0, 1
        shader.setFloat(0, size.width);
        shader.setFloat(1, size.height);

        // u_texture (sampler2D) - se configura automáticamente, NO lo configuramos

        // u_pixelSize (float) - índice después del sampler
        try {
          shader.setFloat(2, widget.pixelSize);
          shader.setFloat(3, widget.colorCount.toDouble());
        } catch (e) {
          debugPrint('⚠️ Error configurando uniforms en índices 2-3: $e');
          try {
            shader.setFloat(3, widget.pixelSize);
            shader.setFloat(4, widget.colorCount.toDouble());
          } catch (e2) {
            debugPrint('❌ Error configurando uniforms: $e2');
          }
        }

        debugPrint(
            '🔧 Uniforms: size=${size.width}x${size.height}, pixelSize=${widget.pixelSize}, colorCount=${widget.colorCount}');

        // Intentar usar ImageFiltered primero (más compatible)
        try {
          return RepaintBoundary(
            key: _repaintKey,
            child: ClipRect(
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.shader(shader),
                child: widget.child,
              ),
            ),
          );
        } catch (e) {
          debugPrint('⚠️ ImageFiltered falló, usando BackdropFilter: $e');
          return RepaintBoundary(
            key: _repaintKey,
            child: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.shader(shader),
                child: widget.child,
              ),
            ),
          );
        }
      },
    );
  }

  /// Implementación capturando el widget como imagen primero
  /// Nota: Esta implementación requiere usar un GlobalKey y RenderRepaintBoundary
  /// Por ahora, usamos BackdropFilter que es más eficiente
  Widget _buildWithImageCapture() {
    // Por simplicidad y rendimiento, redirigimos a BackdropFilter
    // Para una implementación completa con captura de imagen, se necesitaría:
    // 1. Un GlobalKey<State<StatefulWidget>> con RepaintBoundary
    // 2. RenderRepaintBoundary.toImage() para capturar
    // 3. Configurar el sampler del shader con la imagen capturada
    return _buildWithBackdropFilter();
  }
}

/// Versión optimizada que reutiliza el FragmentProgram
/// Úsala cuando necesites aplicar el mismo shader a múltiples widgets
class PixelArtShaderFilterOptimized extends StatefulWidget {
  final Widget child;
  final double pixelSize;
  final int colorCount;
  final bool useBackdropFilter;

  const PixelArtShaderFilterOptimized({
    super.key,
    required this.child,
    this.pixelSize = 64.0,
    this.colorCount = 16,
    this.useBackdropFilter = true,
  });

  @override
  State<PixelArtShaderFilterOptimized> createState() =>
      _PixelArtShaderFilterOptimizedState();
}

class _PixelArtShaderFilterOptimizedState
    extends State<PixelArtShaderFilterOptimized> {
  static ui.FragmentProgram? _cachedProgram;
  static bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (_cachedProgram == null && !_isLoading) {
      _loadShader();
    }
  }

  Future<void> _loadShader() async {
    _isLoading = true;
    try {
      _cachedProgram =
          await ui.FragmentProgram.fromAsset('shaders/pixel_art.frag');
      debugPrint('✅ Pixel art shader optimizado cargado correctamente');
    } catch (e) {
      debugPrint('❌ Error cargando pixel art shader optimizado: $e');
      debugPrint(
          '   Verifica que el archivo shaders/pixel_art.frag existe y está en pubspec.yaml');
    } finally {
      _isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _cachedProgram == null) {
      if (_isLoading) {
        debugPrint('⏳ Shader optimizado cargando...');
      }
      return widget.child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (size.width <= 0 || size.height <= 0) {
          return widget.child;
        }

        final shader = _cachedProgram!.fragmentShader();

        // IMPORTANTE: Con ImageFilter.shader(), el orden de uniforms es:
        // - El primer uniforme DEBE ser vec2 con el tamaño (índices 0, 1)
        // - El sampler2D se configura automáticamente por Flutter (no lo configuramos)
        // - Los demás uniforms siguen en orden después del sampler

        // u_size (vec2) - índices 0, 1
        shader.setFloat(0, size.width);
        shader.setFloat(1, size.height);

        // u_texture (sampler2D) - se configura automáticamente, NO lo configuramos

        // u_pixelSize (float) - índice después del sampler
        try {
          shader.setFloat(2, widget.pixelSize);
          shader.setFloat(3, widget.colorCount.toDouble());
        } catch (e) {
          debugPrint('⚠️ Error configurando uniforms en índices 2-3: $e');
          try {
            shader.setFloat(3, widget.pixelSize);
            shader.setFloat(4, widget.colorCount.toDouble());
          } catch (e2) {
            debugPrint('❌ Error configurando uniforms: $e2');
          }
        }

        debugPrint(
            '🔧 Uniforms: size=${size.width}x${size.height}, pixelSize=${widget.pixelSize}, colorCount=${widget.colorCount}');

        // Intentar usar ImageFiltered primero (más compatible)
        // Si no funciona, BackdropFilter es la alternativa
        try {
          return RepaintBoundary(
            child: ClipRect(
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.shader(shader),
                child: widget.child,
              ),
            ),
          );
        } catch (e) {
          debugPrint('⚠️ ImageFiltered falló, usando BackdropFilter: $e');
          return RepaintBoundary(
            child: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.shader(shader),
                child: widget.child,
              ),
            ),
          );
        }
      },
    );
  }
}
