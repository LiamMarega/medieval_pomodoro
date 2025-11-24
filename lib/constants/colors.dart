/// Colores principales de la aplicación Medieval Pomodoro
/// 
/// Este archivo centraliza todos los colores utilizados en la aplicación
/// para mantener consistencia visual y facilitar el mantenimiento.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Constructor privado para evitar instanciación

  // ============================================
  // COLORES PRINCIPALES
  // ============================================

  /// Color dorado principal usado en textos y elementos destacados
  /// Hex: #DAA520
  static const Color primaryGold = Color(0xFFDAA520);

  /// Color de fondo principal (marrón oscuro)
  /// Hex: #2D1B0F
  static const Color primaryBackground = Color(0xFF2D1B0F);

  // ============================================
  // COLORES DE FONDO
  // ============================================

  /// Fondo secundario (marrón muy oscuro)
  /// Hex: #2A1B0A
  static const Color secondaryBackground = Color(0xFF2A1B0A);

  /// Fondo de contenedores (marrón medio oscuro)
  /// Hex: #4A3728
  static const Color containerBackground = Color(0xFF4A3728);

  /// Fondo de contenedores alternativo (marrón medio claro)
  /// Hex: #3A2A1A
  static const Color containerBackgroundAlt = Color(0xFF3A2A1A);

  /// Fondo de cards y paneles (marrón oscuro)
  /// Hex: #3A2318
  static const Color cardBackground = Color(0xFF3A2318);

  /// Fondo de audio controls
  /// Hex: #2D1B0E
  static const Color audioBackground = Color(0xFF2D1B0E);

  // ============================================
  // COLORES DORADOS (VARIACIONES)
  // ============================================

  /// Dorado oscuro
  /// Hex: #B8860B
  static const Color darkGold = Color(0xFFB8860B);

  /// Dorado claro
  /// Hex: #D4AF37
  static const Color lightGold = Color(0xFFD4AF37);

  /// Dorado medio
  /// Hex: #D4A017
  static const Color mediumGold = Color(0xFFD4A017);

  // ============================================
  // COLORES DE ESTADO
  // ============================================

  /// Verde para éxito/confirmación
  /// Hex: #4CAF50
  static const Color success = Color(0xFF4CAF50);

  /// Rojo para errores/reset
  /// Hex: #FF4444
  static const Color error = Color(0xFFFF4444);

  /// Azul para información
  /// Hex: #6B9BD1
  static const Color info = Color(0xFF6B9BD1);

  /// Naranja para advertencias
  /// Hex: #FFA500
  static const Color warning = Color(0xFFFFA500);

  // ============================================
  // COLORES DE TEXTO
  // ============================================

  /// Texto principal (blanco)
  static const Color textPrimary = Colors.white;

  /// Texto secundario (gris claro)
  /// Hex: #888888
  static const Color textSecondary = Color(0xFF888888);

  /// Texto deshabilitado (gris medio)
  /// Hex: #666666
  static const Color textDisabled = Color(0xFF666666);

  /// Texto en contenedores oscuros (gris)
  /// Hex: #757575
  static const Color textOnDark = Color(0xFF757575);

  // ============================================
  // COLORES DE BORDES Y SOMBRAS
  // ============================================

  /// Borde negro estándar
  static const Color borderBlack = Colors.black;

  /// Borde negro con transparencia
  static const Color borderBlackTransparent = Color(0x80000000);

  /// Color de filtro marrón rojizo (usado en imágenes)
  /// Hex: #6b2f01 (con alpha)
  static const Color filterBrownRed = Color(0x006b2f01);

  // ============================================
  // COLORES DE TEMAS (Theme Picker)
  // ============================================

  /// Tema Medieval Brown - Color primario
  /// Hex: #4B2E20
  static const Color themeMedievalBrownPrimary = Color(0xFF4B2E20);

  /// Tema Medieval Brown - Color secundario
  /// Hex: #D4A017
  static const Color themeMedievalBrownSecondary = Color(0xFFD4A017);

  /// Tema Forest Green - Color primario
  /// Hex: #2D4A2B
  static const Color themeForestGreenPrimary = Color(0xFF2D4A2B);

  /// Tema Forest Green - Color secundario
  /// Hex: #8FBC8F
  static const Color themeForestGreenSecondary = Color(0xFF8FBC8F);

  /// Tema Royal Purple - Color primario
  /// Hex: #4A2C5A
  static const Color themeRoyalPurplePrimary = Color(0xFF4A2C5A);

  /// Tema Royal Purple - Color secundario
  /// Hex: #DDA0DD
  static const Color themeRoyalPurpleSecondary = Color(0xFFDDA0DD);

  /// Tema Dragon Red - Color primario
  /// Hex: #5A2D2D
  static const Color themeDragonRedPrimary = Color(0xFF5A2D2D);

  /// Tema Dragon Red - Color secundario
  /// Hex: #FF6B6B
  static const Color themeDragonRedSecondary = Color(0xFFFF6B6B);

  // ============================================
  // COLORES ADICIONALES (Session Complete)
  // ============================================

  /// Marrón silla de montar
  /// Hex: #8B4513
  static const Color saddleBrown = Color(0xFF8B4513);

  /// Marrón oscuro
  /// Hex: #654321
  static const Color darkBrown = Color(0xFF654321);

  /// Marrón muy oscuro
  /// Hex: #3E2723
  static const Color veryDarkBrown = Color(0xFF3E2723);

  // ============================================
  // MÉTODOS DE UTILIDAD
  // ============================================

  /// Obtiene el color dorado con transparencia
  static Color goldWithOpacity(double opacity) {
    return primaryGold.withValues(alpha: opacity);
  }

  /// Obtiene el color de fondo con transparencia
  static Color backgroundWithOpacity(double opacity) {
    return primaryBackground.withValues(alpha: opacity);
  }

  /// Obtiene el color de contenedor con transparencia
  static Color containerWithOpacity(double opacity) {
    return containerBackground.withValues(alpha: opacity);
  }
}

