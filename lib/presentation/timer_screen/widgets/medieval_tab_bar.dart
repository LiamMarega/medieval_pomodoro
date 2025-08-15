import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MedievalTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;

  const MedievalTabBar({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor,
            width: 2,
          ),
        ),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: AppTheme.secondaryLight,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.secondaryLight,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.pressStart2p(
          fontSize: 8.sp,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: GoogleFonts.pressStart2p(
          fontSize: 8.sp,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'timer',
                  color: tabController.index == 0
                      ? AppTheme.secondaryLight
                      : AppTheme.textSecondary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text('TIMER'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'settings',
                  color: tabController.index == 1
                      ? AppTheme.secondaryLight
                      : AppTheme.textSecondary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text('OPTIONS'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(8.h);
}
