/// Coordenadas de sprites del medieval.png
///
/// Para encontrar coordenadas:
/// 1. Abre medieval.png en un editor de imágenes
/// 2. Usa la herramienta de selección rectangular
/// 3. Anota las coordenadas (x, y) y tamaño (width, height)

class MedievalSprite {
  final double x;
  final double y;
  final double width;
  final double height;

  const MedievalSprite({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

/// Sprites del sheet medieval.png
class MedievalSprites {
  static const String imagePath = 'assets/sprites/medieval.png';

  // === CARTELES Y PANELES ===

  /// Cartel pequeño con marco decorativo (esquina superior izquierda)
  static const MedievalSprite smallSignWithFrame = MedievalSprite(
    x: 10,
    y: 153,
    width: 54,
    height: 73,
  );

  /// Panel de madera mediano con marco
  static const MedievalSprite mediumWoodenPanel = MedievalSprite(
    x: 88,
    y: 153,
    width: 64,
    height: 73,
  );

  /// Panel de madera grande con marco oscuro
  static const MedievalSprite largeWoodenPanel = MedievalSprite(
    x: 162,
    y: 153,
    width: 64,
    height: 73,
  );

  /// Cartel con texto "PLAY"
  static const MedievalSprite playButton = MedievalSprite(
    x: 10,
    y: 233,
    width: 54,
    height: 73,
  );

  /// Panel rectangular horizontal pequeño
  static const MedievalSprite smallHorizontalPanel = MedievalSprite(
    x: 10,
    y: 393,
    width: 64,
    height: 48,
  );

  /// Panel cuadrado mediano
  static const MedievalSprite mediumSquarePanel = MedievalSprite(
    x: 88,
    y: 393,
    width: 64,
    height: 48,
  );

  /// Panel rectangular horizontal (más oscuro)
  static const MedievalSprite darkHorizontalPanel = MedievalSprite(
    x: 10,
    y: 553,
    width: 64,
    height: 48,
  );

  /// Panel redondo mediano
  static const MedievalSprite roundPanel = MedievalSprite(
    x: 210,
    y: 393,
    width: 48,
    height: 48,
  );

  // === PERGAMINOS ===

  /// Pergamino enrollado (cerrado)
  static const MedievalSprite scrollClosed = MedievalSprite(
    x: 335,
    y: 116,
    width: 64,
    height: 96,
  );

  /// Pergamino desplegado grande
  static const MedievalSprite scrollLarge = MedievalSprite(
    x: 459,
    y: 802,
    width: 144,
    height: 96,
  );

  // === BOTONES ===

  /// Botón "PLAY" rectangular con texto
  static const MedievalSprite buttonPlay = MedievalSprite(
    x: 322,
    y: 5,
    width: 80,
    height: 32,
  );

  // === ELEMENTOS DECORATIVOS ===

  /// Tabla de madera rectangular grande (para mostrar información)
  static const MedievalSprite largeBoardTop = MedievalSprite(
    x: 517,
    y: 207,
    width: 112,
    height: 48,
  );

  /// Tabla de madera rectangular mediana
  static const MedievalSprite mediumBoard = MedievalSprite(
    x: 517,
    y: 271,
    width: 112,
    height: 64,
  );

  /// Panel con borde claro (perfecto para timer)
  static const MedievalSprite timerPanel = MedievalSprite(
    x: 657,
    y: 207,
    width: 112,
    height: 48,
  );

  /// Panel inventario grande
  static const MedievalSprite inventoryPanelLarge = MedievalSprite(
    x: 533,
    y: 631,
    width: 96,
    height: 96,
  );

  /// Panel inventario mediano
  static const MedievalSprite inventoryPanelMedium = MedievalSprite(
    x: 645,
    y: 631,
    width: 96,
    height: 96,
  );

  // === BARRAS DE PROGRESO ===

  /// Barra de progreso vacía (oscura)
  static const MedievalSprite progressBarEmpty = MedievalSprite(
    x: 186,
    y: 95,
    width: 96,
    height: 16,
  );

  /// Barra de progreso - segmento rojo
  static const MedievalSprite progressBarRed = MedievalSprite(
    x: 186,
    y: 118,
    width: 96,
    height: 16,
  );

  /// Barra de progreso - segmento azul
  static const MedievalSprite progressBarBlue = MedievalSprite(
    x: 186,
    y: 151,
    width: 96,
    height: 16,
  );

  // === SHIELDS/ESCUDOS (pueden servir como badges) ===

  /// Escudo marrón
  static const MedievalSprite shieldBrown = MedievalSprite(
    x: 818,
    y: 327,
    width: 48,
    height: 64,
  );

  /// Escudo oscuro
  static const MedievalSprite shieldDark = MedievalSprite(
    x: 866,
    y: 327,
    width: 48,
    height: 64,
  );

  /// Escudo blanco/claro
  static const MedievalSprite shieldLight = MedievalSprite(
    x: 914,
    y: 327,
    width: 48,
    height: 64,
  );
}
