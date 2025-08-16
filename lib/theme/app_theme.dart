import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the medieval productivity application.
class AppTheme {
  AppTheme._();

  // Medieval Twilight Palette - Optimized for extended viewing sessions
  static const Color primaryLight = Color(0xFF4B2E20); // Rich medieval brown
  static const Color primaryVariantLight =
      Color(0xFF3A2318); // Darker brown variant
  static const Color secondaryLight = Color(0xFFD4A017); // Warm gold
  static const Color secondaryVariantLight =
      Color(0xFFB8860B); // Dark goldenrod
  static const Color backgroundLight = Color(0xFF2D1B12); // Deep brown base
  static const Color surfaceLight = Color(0xFF3A2318); // Darker brown variant
  static const Color errorLight = Color(0xFFA83232); // Deep red
  static const Color onPrimaryLight = Color(0xFFF5E6D3); // Warm off-white
  static const Color onSecondaryLight = Color(0xFF2D1B12); // Deep brown
  static const Color onBackgroundLight = Color(0xFFF5E6D3); // Warm off-white
  static const Color onSurfaceLight = Color(0xFFF5E6D3); // Warm off-white
  static const Color onErrorLight = Color(0xFFF5E6D3); // Warm off-white

  // Dark theme uses same medieval palette with adjusted contrasts
  static const Color primaryDark = Color(0xFF4B2E20); // Rich medieval brown
  static const Color primaryVariantDark =
      Color(0xFF3A2318); // Darker brown variant
  static const Color secondaryDark = Color(0xFFD4A017); // Warm gold
  static const Color secondaryVariantDark = Color(0xFFB8860B); // Dark goldenrod
  static const Color backgroundDark = Color(0xFF250D06); // Deep brown base
  static const Color surfaceDark = Color(0xFF3A2318); // Darker brown variant
  static const Color errorDark = Color(0xFFA83232); // Deep red
  static const Color onPrimaryDark = Color(0xFFF5E6D3); // Warm off-white
  static const Color onSecondaryDark = Color(0xFF2D1B12); // Deep brown
  static const Color onBackgroundDark = Color(0xFFF5E6D3); // Warm off-white
  static const Color onSurfaceDark = Color(0xFFF5E6D3); // Warm off-white
  static const Color onErrorDark = Color(0xFFF5E6D3); // Warm off-white

  // Additional medieval theme colors
  static const Color successColor = Color(0xFF5D7C47); // Forest green
  static const Color warningColor = Color(0xFFB8860B); // Dark goldenrod
  static const Color borderColor = Color(0xFF6B4423); // Medium brown
  static const Color textSecondary = Color(0xFFC4A373); // Muted gold

  // Card and dialog colors
  static const Color cardLight = Color(0xFF3A2318);
  static const Color cardDark = Color(0xFF3A2318);
  static const Color dialogLight = Color(0xFF4B2E20);
  static const Color dialogDark = Color(0xFF4B2E20);

  // Shadow colors with brown tints
  static const Color shadowLight = Color(0x334B2E20); // 20% opacity brown
  static const Color shadowDark = Color(0x334B2E20); // 20% opacity brown

  // Divider colors
  static const Color dividerLight = Color(0xFF6B4423);
  static const Color dividerDark = Color(0xFF6B4423);

  // Text colors with medieval palette
  static const Color textHighEmphasisLight =
      Color(0xFFF5E6D3); // Warm off-white
  static const Color textMediumEmphasisLight = Color(0xFFC4A373); // Muted gold
  static const Color textDisabledLight =
      Color(0x996B4423); // Medium brown with opacity

  static const Color textHighEmphasisDark = Color(0xFFF5E6D3); // Warm off-white
  static const Color textMediumEmphasisDark = Color(0xFFC4A373); // Muted gold
  static const Color textDisabledDark =
      Color(0x996B4423); // Medium brown with opacity

  /// Light theme with medieval aesthetics
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: onPrimaryLight,
      primaryContainer: primaryVariantLight,
      onPrimaryContainer: onPrimaryLight,
      secondary: secondaryLight,
      onSecondary: onSecondaryLight,
      secondaryContainer: secondaryVariantLight,
      onSecondaryContainer: onSecondaryLight,
      tertiary: successColor,
      onTertiary: onPrimaryLight,
      tertiaryContainer: successColor,
      onTertiaryContainer: onPrimaryLight,
      error: errorLight,
      onError: onErrorLight,
      surface: surfaceLight,
      onSurface: onSurfaceLight,
      onSurfaceVariant: textSecondary,
      outline: borderColor,
      outlineVariant: dividerLight,
      shadow: shadowLight,
      scrim: shadowLight,
      inverseSurface: surfaceDark,
      onInverseSurface: onSurfaceDark,
      inversePrimary: secondaryLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    dividerColor: dividerLight,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryLight,
      foregroundColor: onPrimaryLight,
      elevation: 2.0,
      shadowColor: shadowLight,
      titleTextStyle: GoogleFonts.pressStart2p(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: onPrimaryLight,
      ),
      iconTheme: const IconThemeData(
        color: onPrimaryLight,
        size: 24,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 2.0,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: borderColor, width: 1),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: secondaryLight,
      unselectedItemColor: textMediumEmphasisLight,
      elevation: 2.0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryLight,
      foregroundColor: onSecondaryLight,
      elevation: 2.0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryLight,
        backgroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 2.0,
        shadowColor: shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: secondaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: const BorderSide(color: secondaryLight, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: true),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceLight,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: secondaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorLight, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorLight, width: 2),
      ),
      labelStyle: GoogleFonts.roboto(
        color: textMediumEmphasisLight,
        fontSize: 16,
      ),
      hintStyle: GoogleFonts.roboto(
        color: textDisabledLight,
        fontSize: 16,
      ),
      prefixIconColor: textMediumEmphasisLight,
      suffixIconColor: textMediumEmphasisLight,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryLight;
        }
        return textMediumEmphasisLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryLight.withValues(alpha: 0.5);
        }
        return borderColor;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onSecondaryLight),
      side: const BorderSide(color: borderColor, width: 1),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryLight;
        }
        return borderColor;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: secondaryLight,
      linearTrackColor: borderColor,
      circularTrackColor: borderColor,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: secondaryLight,
      thumbColor: secondaryLight,
      overlayColor: secondaryLight.withValues(alpha: 0.2),
      inactiveTrackColor: borderColor,
      valueIndicatorColor: primaryLight,
      valueIndicatorTextStyle: GoogleFonts.robotoMono(
        color: onPrimaryLight,
        fontSize: 12,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: secondaryLight,
      unselectedLabelColor: textMediumEmphasisLight,
      indicatorColor: secondaryLight,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: primaryLight,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
      ),
      textStyle: GoogleFonts.roboto(
        color: onPrimaryLight,
        fontSize: 12,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryLight,
      contentTextStyle: GoogleFonts.roboto(
        color: onPrimaryLight,
        fontSize: 14,
      ),
      actionTextColor: secondaryLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: borderColor, width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(backgroundColor: dialogLight),
  );

  /// Dark theme with medieval aesthetics (same as light for this medieval theme)
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: onPrimaryDark,
      primaryContainer: primaryVariantDark,
      onPrimaryContainer: onPrimaryDark,
      secondary: secondaryDark,
      onSecondary: onSecondaryDark,
      secondaryContainer: secondaryVariantDark,
      onSecondaryContainer: onSecondaryDark,
      tertiary: successColor,
      onTertiary: onPrimaryDark,
      tertiaryContainer: successColor,
      onTertiaryContainer: onPrimaryDark,
      error: errorDark,
      onError: onErrorDark,
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      onSurfaceVariant: textSecondary,
      outline: borderColor,
      outlineVariant: dividerDark,
      shadow: shadowDark,
      scrim: shadowDark,
      inverseSurface: surfaceLight,
      onInverseSurface: onSurfaceLight,
      inversePrimary: secondaryDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardDark,
    dividerColor: dividerDark,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryDark,
      foregroundColor: onPrimaryDark,
      elevation: 2.0,
      shadowColor: shadowDark,
      titleTextStyle: GoogleFonts.pressStart2p(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: onPrimaryDark,
      ),
      iconTheme: const IconThemeData(
        color: onPrimaryDark,
        size: 24,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 2.0,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: borderColor, width: 1),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: secondaryDark,
      unselectedItemColor: textMediumEmphasisDark,
      elevation: 2.0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryDark,
      foregroundColor: onSecondaryDark,
      elevation: 2.0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryDark,
        backgroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 2.0,
        shadowColor: shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: secondaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: const BorderSide(color: secondaryDark, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: false),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceDark,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: secondaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorDark, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorDark, width: 2),
      ),
      labelStyle: GoogleFonts.roboto(
        color: textMediumEmphasisDark,
        fontSize: 16,
      ),
      hintStyle: GoogleFonts.roboto(
        color: textDisabledDark,
        fontSize: 16,
      ),
      prefixIconColor: textMediumEmphasisDark,
      suffixIconColor: textMediumEmphasisDark,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryDark;
        }
        return textMediumEmphasisDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryDark.withValues(alpha: 0.5);
        }
        return borderColor;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryDark;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onSecondaryDark),
      side: const BorderSide(color: borderColor, width: 1),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return secondaryDark;
        }
        return borderColor;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: secondaryDark,
      linearTrackColor: borderColor,
      circularTrackColor: borderColor,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: secondaryDark,
      thumbColor: secondaryDark,
      overlayColor: secondaryDark.withValues(alpha: 0.2),
      inactiveTrackColor: borderColor,
      valueIndicatorColor: primaryDark,
      valueIndicatorTextStyle: GoogleFonts.robotoMono(
        color: onPrimaryDark,
        fontSize: 12,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: secondaryDark,
      unselectedLabelColor: textMediumEmphasisDark,
      indicatorColor: secondaryDark,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
      ),
      textStyle: GoogleFonts.roboto(
        color: onPrimaryDark,
        fontSize: 12,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryDark,
      contentTextStyle: GoogleFonts.roboto(
        color: onPrimaryDark,
        fontSize: 14,
      ),
      actionTextColor: secondaryDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: borderColor, width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(backgroundColor: dialogDark),
  );

  /// Helper method to build medieval-themed text theme
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textHighEmphasis =
        isLight ? textHighEmphasisLight : textHighEmphasisDark;
    final Color textMediumEmphasis =
        isLight ? textMediumEmphasisLight : textMediumEmphasisDark;
    final Color textDisabled = isLight ? textDisabledLight : textDisabledDark;

    return TextTheme(
      // Headings use Press Start 2P for authentic 8-bit feel
      displayLarge: GoogleFonts.pressStart2p(
        fontSize: 32,
        fontWeight: FontWeight.normal,
        color: textHighEmphasis,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.pressStart2p(
        fontSize: 28,
        fontWeight: FontWeight.normal,
        color: textHighEmphasis,
        letterSpacing: -0.25,
      ),
      displaySmall: GoogleFonts.pressStart2p(
        fontSize: 24,
        fontWeight: FontWeight.normal,
        color: textHighEmphasis,
      ),
      headlineLarge: GoogleFonts.pressStart2p(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        color: textHighEmphasis,
        letterSpacing: 0.15,
      ),
      headlineMedium: GoogleFonts.pressStart2p(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: textHighEmphasis,
      ),
      headlineSmall: GoogleFonts.pressStart2p(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textHighEmphasis,
      ),

      // Body text uses Roboto for readability
      titleLarge: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
        letterSpacing: 0.15,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMediumEmphasis,
        letterSpacing: 0.4,
      ),

      // Captions use Roboto Light
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
        letterSpacing: 1.25,
      ),
      labelMedium: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: textMediumEmphasis,
        letterSpacing: 0.4,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 10,
        fontWeight: FontWeight.w300,
        color: textDisabled,
        letterSpacing: 1.5,
      ),
    );
  }

  /// Get timer display text style using Roboto Mono
  static TextStyle getTimerTextStyle({
    required bool isLight,
    double fontSize = 48,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: isLight ? textHighEmphasisLight : textHighEmphasisDark,
      letterSpacing: 2.0,
    );
  }

  /// Get data display text style using Roboto Mono
  static TextStyle getDataTextStyle({
    required bool isLight,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: isLight ? textHighEmphasisLight : textHighEmphasisDark,
      letterSpacing: 1.0,
    );
  }
}
