import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MedievalMusicToggle extends StatelessWidget {
  final bool isMusicEnabled;
  final VoidCallback onToggle;

  const MedievalMusicToggle({
    super.key,
    required this.isMusicEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle();
      },
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: isMusicEnabled
              ? AppTheme.successColor
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              offset: const Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: CustomIconWidget(
                iconName: isMusicEnabled ? 'music_note' : 'music_off',
                color: isMusicEnabled
                    ? AppTheme.lightTheme.colorScheme.onPrimary
                    : AppTheme.textSecondary,
                size: 20,
              ),
            ),
            // Pixel decoration
            if (isMusicEnabled)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 1.5.w,
                  height: 1.5.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.onPrimary
                        .withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
