import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../generated/locale_keys.g.dart';

class SettingsHeaderWidget extends StatelessWidget {
  const SettingsHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3728).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(0),
          border: Border.all(
            color: Colors.black,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1B0A),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: const Color(0xFFDAA520),
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🛡️',
                    style: TextStyle(fontSize: 20.sp),
                  ),
                  SizedBox(width: 2.w),
                  Flexible(
                    child: Text(
                      LocaleKeys.settings_screen_options.tr(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFDAA520),
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.9),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '⏳',
                    style: TextStyle(fontSize: 20.sp),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
          ],
        ),
      ),
    );
  }
}
