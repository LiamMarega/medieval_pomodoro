import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget with medieval theme and pixel art aesthetics
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 2.0,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primary,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFF6B4423), // Medieval brown border
            width: 1,
          ),
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color:
                      const Color(0x334B2E20), // Brown shadow with 20% opacity
                  offset: const Offset(0, 2),
                  blurRadius: elevation,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: AppBar(
        title: Text(
          title,
          style: GoogleFonts.pressStart2p(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: foregroundColor ?? theme.colorScheme.onPrimary,
            letterSpacing: 0.5,
          ),
        ),
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: Colors.transparent,
        foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
        elevation:
            0, // Remove default elevation since we handle it with Container
        centerTitle: centerTitle,
        bottom: bottom,
        iconTheme: IconThemeData(
          color: foregroundColor ?? theme.colorScheme.onPrimary,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: foregroundColor ?? theme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  /// Factory constructor for timer screen app bar
  factory CustomAppBar.timer(BuildContext context) {
    return CustomAppBar(
      title: 'Medieval Timer',
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/settings-screen'),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  /// Factory constructor for settings screen app bar
  factory CustomAppBar.settings(BuildContext context) {
    return CustomAppBar(
      title: 'Settings',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Back',
      ),
    );
  }

  /// Factory constructor for minimal app bar without title
  factory CustomAppBar.minimal({
    List<Widget>? actions,
    Widget? leading,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return CustomAppBar(
      title: '',
      actions: actions,
      leading: leading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: false,
    );
  }
}
