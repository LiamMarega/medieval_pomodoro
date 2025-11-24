import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../generated/locale_keys.g.dart';
import '../../providers/stats_provider.dart';
import '../../widgets/pixel_frame.dart';
import '../../constants/colors.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsControllerProvider);

    return PixelFrame(
      cornerSize: 32,
      edgeThickness: 8,
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage(
                  'assets/sprites/backgrounds/pixel-art-bg-2.png'),
              fit: BoxFit.none,
              repeat: ImageRepeat.noRepeat,
              scale: 1.5,
              filterQuality: FilterQuality.low,
              colorFilter: ColorFilter.mode(
                AppColors.primaryBackground,
                BlendMode.dstOver,
              ),
              opacity: 0.2,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 6.h),
              _buildHeader(stats),
              SizedBox(height: 4.h),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.black.withValues(alpha: 0.5),
                        width: 5,
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/sprites/bricks_background_mobile.png'),
                        fit: BoxFit.none,
                        repeat: ImageRepeat.repeat,
                        scale: 2,
                        filterQuality: FilterQuality.low,
                        colorFilter: ColorFilter.mode(
                          AppColors.filterBrownRed,
                          BlendMode.color,
                        ),
                        opacity: 0.5,
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PixelFrame(
                            cornerSize: 0,
                            edgeThickness: 100,
                            showBorder: false,
                            showLeftBorder: false,
                            showRightBorder: false,
                            padding: 10,
                            showLeftShadow: false,
                            showRightShadow: false,
                            child: Container(
                              color: AppColors.containerBackground,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 2.h),
                                  Center(
                                    child: Text(
                                      LocaleKeys.stats_screen_weekly_performance
                                          .tr(),
                                      style: GoogleFonts.pressStart2p(
                                        fontSize: 14.sp,
                                        color: AppColors.primaryGold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  _buildWeeklyPerformanceSection(stats),
                                  SizedBox(height: 2.h),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          _buildWeeklyChart(stats),
                          SizedBox(height: 3.h),
                          _buildTimeMetrics(stats),
                          SizedBox(height: 3.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(StatsState stats) {
    final totalHours = stats.totalFocusSeconds ~/ 3600;
    final totalMinutes = (stats.totalFocusSeconds % 3600) ~/ 60;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.containerBackground.withValues(alpha: 0.9),
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Tiempo total enfocado
          _buildHeaderStat(
            '💰',
            '${totalHours}h ${totalMinutes}m',
            LocaleKeys.stats_screen_total_focused_time.tr(),
          ),
          // Espadas cruzadas (sesiones totales)
          _buildHeaderStat(
            '⚔️',
            '${stats.totalPomodoros}',
            LocaleKeys.stats_screen_total_sessions_header.tr(),
          ),
          // Días de streak
          _buildHeaderStat(
            '🛡️',
            '${stats.currentStreakDays}',
            LocaleKeys.stats_screen_streak_days.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 2.w),
            Text(
              value,
              style: GoogleFonts.pressStart2p(
                fontSize: 18.sp,
                color: AppColors.primaryGold,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    offset: const Offset(2, 2),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: GoogleFonts.pressStart2p(
            fontSize: 7.sp,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWeeklyPerformanceSection(StatsState stats) {
    // Mock data para achievements - puedes personalizarlo después
    final achievements = [
      {
        'icon': '🏅',
        'title': LocaleKeys.stats_screen_iron_initiate.tr(),
        'subtitle': LocaleKeys.stats_screen_complete_5_sessions.tr(),
        'progress': stats.totalPomodoros >= 5 ? 1.0 : stats.totalPomodoros / 5,
        'current': stats.totalPomodoros >= 5 ? 5 : stats.totalPomodoros,
        'total': 5,
      },
      {
        'icon': '🔥',
        'title': LocaleKeys.stats_screen_infernal_flame_guardian.tr(),
        'subtitle': LocaleKeys.stats_screen_10_hours_total_focus.tr(),
        'progress': (stats.totalFocusSeconds / 36000).clamp(0.0, 1.0),
        'current': ((stats.totalFocusSeconds / 3600) >= 10
                ? 10
                : (stats.totalFocusSeconds / 3600))
            .toInt(),
        'total': 10,
      },
      {
        'icon': '🗡️',
        'title': LocaleKeys.stats_screen_dragon_hunter.tr(),
        'subtitle': LocaleKeys.stats_screen_7_consecutive_days.tr(),
        'progress':
            stats.currentStreakDays >= 7 ? 1.0 : stats.currentStreakDays / 7,
        'current': stats.currentStreakDays >= 7 ? 7 : stats.currentStreakDays,
        'total': 7,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Background image - centered and sized to fit width while maintaining aspect ratio
            Center(
              child: Transform.scale(
                scaleX: 1.15,
                child: Transform.scale(
                  scale: 1.05,
                  child: Image.asset(
                    'assets/sprites/paper-sprite-2.png',
                    fit: BoxFit.fitWidth,
                    width: 100.w,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ),
            ),
            // Content on top of the image
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...achievements.map((achievement) => _buildAchievementRow(
                        achievement['icon'] as String,
                        achievement['title'] as String,
                        achievement['subtitle'] as String,
                        achievement['progress'] as double,
                        achievement['current'] as int,
                        achievement['total'] as int,
                      )),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAchievementRow(
    String icon,
    String title,
    String subtitle,
    double progress,
    int current,
    int total,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerBackgroundAlt.withValues(alpha: 0.8),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 24.sp)),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$current/$total',
            style: GoogleFonts.pressStart2p(
              fontSize: 10.sp,
              color: AppColors.primaryGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(StatsState stats) {
    // Obtener los últimos 7 días
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return date;
    });

    // Obtener los datos para cada día
    final weekData = weekDays.map((date) {
      final dateStr = date.toIso8601String().substring(0, 10);
      final count = stats.dailyPomodoros[dateStr] ?? 0;
      return count;
    }).toList();

    final maxValue = weekData.reduce((a, b) => a > b ? a : b);
    final normalizedData = weekData.map((count) {
      if (maxValue == 0) return 0.0;
      return count / maxValue;
    }).toList();

    final dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.containerBackgroundAlt.withValues(alpha: 0.8),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gráfica de barras
          SizedBox(
            height: 20.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final isToday = index == 6;
                return _buildBar(
                  normalizedData[index],
                  weekData[index],
                  isToday,
                );
              }),
            ),
          ),
          SizedBox(height: 1.h),
          // Etiquetas de días
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: dayLabels
                .map((day) => Text(
                      day,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double normalizedValue, int actualValue, bool isToday) {
    final barColor = isToday ? AppColors.primaryGold : const Color(0xFFD4A017);
    final minHeight = 2.h;
    final maxHeight = 18.h;
    final barHeight = minHeight + (normalizedValue * (maxHeight - minHeight));

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (actualValue > 0)
          Text(
            '$actualValue',
            style: GoogleFonts.pressStart2p(
              fontSize: 8.sp,
              color: barColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        SizedBox(height: 0.5.h),
        Container(
          width: 8.w,
          height: barHeight,
          decoration: BoxDecoration(
            color: barColor,
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeMetrics(StatsState stats) {
    final totalHours = stats.totalFocusSeconds ~/ 3600;
    final totalMinutes = (stats.totalFocusSeconds % 3600) ~/ 60;

    // Mock data para descansos (puedes ajustarlo si tienes estos datos)
    final shortBreakMinutes =
        (stats.totalPomodoros * 5); // Asumiendo 5 min por descanso corto
    final longBreakMinutes =
        ((stats.totalPomodoros / 4).floor() * 30); // 30 min cada 4 pomodoros

    return Column(
      children: [
        _buildTimeMetricRow(
          '⏳',
          LocaleKeys.stats_screen_total_work.tr(),
          '${totalHours}h ${totalMinutes}m',
        ),
        SizedBox(height: 1.5.h),
        _buildTimeMetricRow(
          '🌿',
          LocaleKeys.stats_screen_short_breaks.tr(),
          '${shortBreakMinutes ~/ 60}h ${shortBreakMinutes % 60}m',
        ),
        SizedBox(height: 1.5.h),
        _buildTimeMetricRow(
          '🏰',
          LocaleKeys.stats_screen_long_breaks.tr(),
          '${longBreakMinutes ~/ 60}h ${longBreakMinutes % 60}m',
        ),
      ],
    );
  }

  Widget _buildTimeMetricRow(String icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.containerBackgroundAlt.withValues(alpha: 0.8),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 10.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppColors.containerBackground,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Text(
              value,
              style: GoogleFonts.pressStart2p(
                fontSize: 10.sp,
                color: AppColors.primaryGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
