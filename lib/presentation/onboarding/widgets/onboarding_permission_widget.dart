import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../generated/locale_keys.g.dart';
import '../../../widgets/pixel_frame.dart';

/// Widget para solicitar permisos en el onboarding
class OnboardingPermissionWidget extends StatelessWidget {
  final VoidCallback? onPermissionsRequested;
  final bool arePermissionsGranted;

  const OnboardingPermissionWidget({
    super.key,
    this.onPermissionsRequested,
    this.arePermissionsGranted = false,
  });

  @override
  Widget build(BuildContext context) {
    return PixelFrame(
      cornerSize: 16,
      edgeThickness: 4,
      padding: 20,
      borderStyle: MedievalBorderStyle.stone,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(2.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1B0A).withValues(alpha: 0.9),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3A2B1A).withValues(alpha: 0.9),
              const Color(0xFF1A0B0A).withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          spacing: 10,
          children: [
            Text(
              LocaleKeys.onboarding_permissions_title.tr(),
              style: GoogleFonts.pressStart2p(
                fontSize: 15.sp,
                color: const Color(0xFFDAA520),
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                LocaleKeys.onboarding_permissions_message.tr(),
                style: GoogleFonts.vt323(
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: arePermissionsGranted ? null : onPermissionsRequested,
      child: Container(
        width: 60.w,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: arePermissionsGranted
              ? const Color(0xFF2E7D32) // Green for granted
              : const Color(0xFF4A3728), // Brown for action
          gradient: arePermissionsGranted
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF388E3C),
                    const Color(0xFF1B5E20),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF5A4738),
                    const Color(0xFF3A2718),
                  ],
                ),
        ),
        child: Center(
          child: Text(
            arePermissionsGranted
                ? LocaleKeys.onboarding_permissions_granted.tr()
                : LocaleKeys.onboarding_grant_permissions.tr(),
            style: GoogleFonts.pressStart2p(
              fontSize: 10.sp,
              color: arePermissionsGranted
                  ? Colors.white
                  : const Color(0xFFDAA520),
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
