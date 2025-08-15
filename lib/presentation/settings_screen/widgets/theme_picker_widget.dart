import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ThemePickerWidget extends StatefulWidget {
  final String selectedTheme;
  final Function(String) onThemeChanged;

  const ThemePickerWidget({
    super.key,
    required this.selectedTheme,
    required this.onThemeChanged,
  });

  @override
  State<ThemePickerWidget> createState() => _ThemePickerWidgetState();
}

class _ThemePickerWidgetState extends State<ThemePickerWidget> {
  late String _selectedTheme;

  final List<Map<String, dynamic>> _themes = [
    {
      'id': 'medieval_brown',
      'name': 'Medieval Brown',
      'primaryColor': Color(0xFF4B2E20),
      'secondaryColor': Color(0xFFD4A017),
      'description': 'Classic medieval castle theme',
    },
    {
      'id': 'forest_green',
      'name': 'Forest Green',
      'primaryColor': Color(0xFF2D4A2B),
      'secondaryColor': Color(0xFF8FBC8F),
      'description': 'Enchanted forest theme',
    },
    {
      'id': 'royal_purple',
      'name': 'Royal Purple',
      'primaryColor': Color(0xFF4A2C5A),
      'secondaryColor': Color(0xFFDDA0DD),
      'description': 'Noble kingdom theme',
    },
    {
      'id': 'dragon_red',
      'name': 'Dragon Red',
      'primaryColor': Color(0xFF5A2D2D),
      'secondaryColor': Color(0xFFFF6B6B),
      'description': 'Fierce dragon lair theme',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.selectedTheme;
  }

  void _selectTheme(String themeId) {
    setState(() {
      _selectedTheme = themeId;
    });
    widget.onThemeChanged(themeId);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Text(
              'Castle Themes',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              itemCount: _themes.length,
              itemBuilder: (context, index) {
                final theme = _themes[index];
                final isSelected = _selectedTheme == theme['id'];

                return GestureDetector(
                  onTap: () => _selectTheme(theme['id']),
                  child: Container(
                    width: 35.w,
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: theme['primaryColor'],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.secondary
                            : AppTheme.borderColor,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowLight,
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: theme['secondaryColor'],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppTheme.borderColor,
                              width: 1,
                            ),
                          ),
                          child: CustomIconWidget(
                            iconName: 'castle',
                            color: theme['primaryColor'],
                            size: 24,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          theme['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          theme['description'],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8.sp,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        if (isSelected) ...[
                          SizedBox(height: 1.h),
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}