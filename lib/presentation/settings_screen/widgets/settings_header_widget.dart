import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../generated/locale_keys.g.dart';
import '../../../constants/colors.dart';

class SettingsHeaderWidget extends StatelessWidget {
  const SettingsHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 10.h,
      child: Stack(
        children: [
          Positioned.fill(
            child: Transform.scale(
              scaleY: 1.2,
              child: Image.asset(
                'assets/sprites/sign-sprite.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(1.5.w),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryGold,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  // Spacer
                  SizedBox(width: 2.w),
                  // Options text
                  Expanded(
                    child: Center(
                      child: Text(
                        LocaleKeys.settings_screen_options.tr(),
                        style: GoogleFonts.pressStart2p(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.9),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Spacer to balance the back button
                  SizedBox(width: 20.sp + 3.w),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
