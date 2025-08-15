import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item for CustomBottomBar
class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Custom Bottom Navigation Bar with medieval theme and pixel art aesthetics
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double elevation;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 2.0,
  });

  // Hardcoded navigation items for medieval productivity app
  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer,
      label: 'Timer',
      route: '/timer-screen',
    ),
    BottomNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
      route: '/settings-screen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        border: const Border(
          top: BorderSide(
            color: Color(0xFF6B4423), // Medieval brown border
            width: 1,
          ),
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color:
                      const Color(0x334B2E20), // Brown shadow with 20% opacity
                  offset: const Offset(0, -2),
                  blurRadius: elevation,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          onTap(index);
          // Navigate to the selected route
          Navigator.pushNamed(context, _navItems[index].route);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation:
            0, // Remove default elevation since we handle it with Container
        selectedItemColor: selectedItemColor ?? theme.colorScheme.secondary,
        unselectedItemColor:
            unselectedItemColor ?? const Color(0xFFC4A373), // Muted gold
        selectedLabelStyle: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
        unselectedLabelStyle: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
        ),
        items: _navItems.map((item) {
          final isSelected = _navItems[currentIndex] == item;
          return BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: isSelected
                  ? BoxDecoration(
                      color: (selectedItemColor ?? theme.colorScheme.secondary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF6B4423), // Medieval brown border
                        width: 1,
                      ),
                    )
                  : null,
              child: Icon(
                isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                size: 24,
              ),
            ),
            label: item.label,
            tooltip: item.label,
          );
        }).toList(),
      ),
    );
  }

  /// Factory constructor for main navigation
  factory CustomBottomBar.main({
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return CustomBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }

  /// Factory constructor for minimal bottom bar without labels
  factory CustomBottomBar.minimal({
    required int currentIndex,
    required Function(int) onTap,
    Color? backgroundColor,
  }) {
    return CustomBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: backgroundColor,
      elevation: 1.0,
    );
  }

  /// Get navigation item count
  static int get itemCount => _navItems.length;

  /// Get navigation item by index
  static BottomNavItem getItem(int index) {
    if (index >= 0 && index < _navItems.length) {
      return _navItems[index];
    }
    return _navItems[0]; // Default to first item
  }

  /// Get index by route
  static int getIndexByRoute(String route) {
    for (int i = 0; i < _navItems.length; i++) {
      if (_navItems[i].route == route) {
        return i;
      }
    }
    return 0; // Default to first item
  }
}
