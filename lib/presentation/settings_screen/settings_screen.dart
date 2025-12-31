import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'dart:io';
import '../../generated/locale_keys.g.dart';
import '../../providers/settings_provider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/app_blocker_provider.dart';
import '../../widgets/pixel_frame.dart';
import '../../core/widgets/small_wood_button.dart';
import '../../core/widgets/large_wood_button.dart';
import '../../constants/colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late int _workDurationMinutes = 25;
  late int _shortBreakMinutes = 5;
  late int _longBreakMinutes = 30;
  late bool _isMusicEnabled = true;
  late bool _strictMode = false;

  @override
  void initState() {
    super.initState();

    // Initialize audio provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioControllerProvider.notifier).initialize();
    });
  }

  // Cached TextStyle to avoid repeated font loading calls
  TextStyle? _cachedDurationTextStyle;

  /// Helper method to safely create pressStart2p TextStyle with fallback
  /// This prevents callstack freezing when the font is not loaded
  TextStyle _safePressStart2p({
    required double fontSize,
    Color? color,
    FontWeight? fontWeight,
    List<Shadow>? shadows,
  }) {
    // Use cached style if available and parameters match
    if (_cachedDurationTextStyle != null &&
        _cachedDurationTextStyle!.fontSize == fontSize) {
      return _cachedDurationTextStyle!.copyWith(
        color: color,
        fontWeight: fontWeight,
        shadows: shadows,
      );
    }

    try {
      final style = GoogleFonts.pressStart2p(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        shadows: shadows,
      );
      // Cache the style for reuse
      _cachedDurationTextStyle = style;
      return style;
    } catch (e) {
      // Fallback to default TextStyle if font loading fails
      return TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        shadows: shadows,
        fontFamily: 'monospace',
      );
    }
  }

  void _autoSaveSettings() {
    final settingsController = ref.read(settingsControllerProvider.notifier);

    // Update settings in the settings provider (this will persist to local storage)
    settingsController.updateSettings(
      workDurationMinutes: _workDurationMinutes,
      shortBreakMinutes: _shortBreakMinutes,
      longBreakMinutes: _longBreakMinutes,
      isMusicEnabled: _isMusicEnabled,
      strictMode: _strictMode,
    );

    // The timer provider will automatically pick up the new settings
    // since it watches the settings provider
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return PixelFrame(
      cornerSize: 32,
      edgeThickness: 8,
      padding: 10,
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
              Expanded(
                child: settingsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Text(LocaleKeys
                        .settings_screen_error_loading_settings
                        .tr(namedArgs: {'error': error.toString()})),
                  ),
                  data: (settings) {
                    // Update local state when settings are loaded
                    if (_workDurationMinutes != settings.workDurationMinutes ||
                        _shortBreakMinutes != settings.shortBreakMinutes ||
                        _longBreakMinutes != settings.longBreakMinutes ||
                        _strictMode != settings.strictMode) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _workDurationMinutes = settings.workDurationMinutes;
                          _shortBreakMinutes = settings.shortBreakMinutes;
                          _longBreakMinutes = settings.longBreakMinutes;
                          _isMusicEnabled = settings.isMusicEnabled;
                          _strictMode = settings.strictMode;
                        });
                      });
                    }

                    return Column(
                      children: [
                        SizedBox(height: 6.h),
                        PaperWidget(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            spacing: 1.h,
                            children: [
                              // Battle Rhythm Section
                              _buildSectionTitle(LocaleKeys
                                  .settings_screen_battle_rhythm
                                  .tr()),
                              SizedBox(height: 1.h),

                              _buildDurationSetting(
                                title: LocaleKeys.settings_screen_work_duration
                                    .tr(),
                                currentValue: _workDurationMinutes,
                                minValue:
                                    0, // Allow 0 minutes (10 seconds for testing)
                                maxValue: 60,
                                increment: 5,
                                onChanged: (value) {
                                  setState(() => _workDurationMinutes = value);
                                  _autoSaveSettings();
                                },
                                customIncrementLogic:
                                    (currentValue, isIncrement) {
                                  if (isIncrement) {
                                    // When incrementing, use smart logic
                                    if (currentValue < 5) {
                                      // If below 5, add 1
                                      return currentValue + 1;
                                    } else {
                                      // If 5 or above, add 5
                                      return currentValue + 5;
                                    }
                                  } else {
                                    // When decrementing, use smart logic
                                    if (currentValue > 5) {
                                      // If above 5, subtract 5
                                      return currentValue - 5;
                                    } else if (currentValue > 0) {
                                      // If between 0 and 5, subtract 1
                                      return currentValue - 1;
                                    } else {
                                      // If at 0, can't go lower
                                      return currentValue;
                                    }
                                  }
                                },
                              ),
                              SizedBox(height: 1.5.h),
                              _buildDurationSetting(
                                title: LocaleKeys
                                    .settings_screen_short_break_time
                                    .tr(),
                                currentValue: _shortBreakMinutes,
                                minValue:
                                    0, // Allow 0 minutes (10 seconds for testing)
                                maxValue: 15,
                                increment: 1,
                                onChanged: (value) {
                                  setState(() => _shortBreakMinutes = value);
                                  _autoSaveSettings();
                                },
                              ),
                              SizedBox(height: 1.5.h),
                              _buildDurationSetting(
                                title: LocaleKeys
                                    .settings_screen_long_break_time
                                    .tr(),
                                currentValue: _longBreakMinutes,
                                minValue:
                                    0, // Allow 0 minutes (20 seconds for testing)
                                maxValue: 60,
                                increment: 5,
                                onChanged: (value) {
                                  setState(() => _longBreakMinutes = value);
                                  _autoSaveSettings();
                                },
                              ),
                              SizedBox(height: 1.5.h),
                            ],
                          ),
                        ),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Language selector
                                    _buildLanguageSelector(context),

                                    // View Stats button
                                    _buildActionButton(
                                      label: LocaleKeys
                                          .settings_screen_view_statistics
                                          .tr(),
                                      color: AppColors.info,
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/stats-screen');
                                      },
                                    ),
                                    SizedBox(height: 1.h),

                                    // Manage Blocked Apps button (iOS only)
                                    if (Platform.isIOS)
                                      _buildActionButton(
                                        label: LocaleKeys
                                            .settings_screen_manage_blocked_apps
                                            .tr(),
                                        color: AppColors.primaryGold,
                                        onTap: () async {
                                          HapticFeedback.mediumImpact();

                                          // Check permission first
                                          final hasPermission = await ref
                                              .read(appBlockerProvider.notifier)
                                              .hasPermission();

                                          if (!hasPermission) {
                                            // Request permission first
                                            final authResult = await ref
                                                .read(
                                                    appBlockerProvider.notifier)
                                                .requestPermission();

                                            if (!authResult) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      '⚠️ Permission denied. Please grant Screen Time permission in Settings.',
                                                      style: GoogleFonts
                                                          .pressStart2p(
                                                              fontSize: 10.sp),
                                                    ),
                                                    backgroundColor:
                                                        AppColors.error,
                                                    duration: const Duration(
                                                        seconds: 3),
                                                  ),
                                                );
                                              }
                                              return;
                                            }
                                          }

                                          // Open app selection UI
                                          final result = await ref
                                              .read(appBlockerProvider.notifier)
                                              .selectAppsToBlock();

                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  result
                                                      ? LocaleKeys
                                                          .settings_screen_apps_selected_successfully
                                                          .tr()
                                                      : LocaleKeys
                                                          .settings_screen_app_selection_cancelled
                                                          .tr(),
                                                  style:
                                                      GoogleFonts.pressStart2p(
                                                          fontSize: 10.sp),
                                                ),
                                                backgroundColor: result
                                                    ? AppColors.success
                                                    : AppColors.primaryGold,
                                                duration:
                                                    const Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    // if (Platform.isIOS) SizedBox(height: 2.h),

                                    // // Test durations button
                                    // _buildActionButton(
                                    //   label: LocaleKeys
                                    //       .settings_screen_set_test_durations
                                    //       .tr(),
                                    //   color: AppColors.primaryGold,
                                    //   onTap: () {
                                    //     final settingsController = ref.read(
                                    //         settingsControllerProvider
                                    //             .notifier);
                                    //     settingsController.setTestDurations();

                                    //     // Update local state
                                    //     setState(() {
                                    //       _workDurationMinutes = 0;
                                    //       _shortBreakMinutes = 0;
                                    //       _longBreakMinutes = 0;
                                    //     });

                                    //     // Show feedback
                                    //     ScaffoldMessenger.of(context)
                                    //         .showSnackBar(
                                    //       SnackBar(
                                    //         content: Text(
                                    //           LocaleKeys
                                    //               .settings_screen_test_mode_activated
                                    //               .tr(),
                                    //           style: GoogleFonts.pressStart2p(
                                    //               fontSize: 12.sp),
                                    //         ),
                                    //         backgroundColor:
                                    //             AppColors.primaryGold,
                                    //         duration:
                                    //             const Duration(seconds: 3),
                                    //       ),
                                    //     );
                                    //   },
                                    // ),
                                    // SizedBox(height: 2.h),

                                    // // Reset to normal durations button
                                    // _buildActionButton(
                                    //   label: 'RESET TO NORMAL',
                                    //   color: AppColors.success,
                                    //   onTap: () {
                                    //     final settingsController = ref.read(
                                    //         settingsControllerProvider
                                    //             .notifier);
                                    //     settingsController.resetToDefaults();

                                    //     // Update local state
                                    //     setState(() {
                                    //       _workDurationMinutes = 25;
                                    //       _shortBreakMinutes = 5;
                                    //       _longBreakMinutes = 30;
                                    //     });

                                    //     // Show feedback
                                    //     ScaffoldMessenger.of(context)
                                    //         .showSnackBar(
                                    //       SnackBar(
                                    //         content: Text(
                                    //           LocaleKeys
                                    //               .settings_screen_normal_mode_activated
                                    //               .tr(),
                                    //           style: GoogleFonts.pressStart2p(
                                    //               fontSize: 12.sp),
                                    //         ),
                                    //         backgroundColor: AppColors.success,
                                    //         duration:
                                    //             const Duration(seconds: 3),
                                    //       ),
                                    //     );
                                    //   },
                                    // ),
                                    // SizedBox(height: 2.h),

                                    // // Reset everything button
                                    // _buildActionButton(
                                    //   label: LocaleKeys
                                    //       .settings_screen_reset_everything_restart
                                    //       .tr(),
                                    //   color: AppColors.error,
                                    //   onTap: () =>
                                    //       _showResetConfirmationDialog(context),
                                    // ),
                                    // SizedBox(height: 2.h),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Center(
        child: LargeWoodButton(
          label: label,
          textColor: color,
          onTap: onTap,
          width: 90.w, // Ensure it typically fills the padded area
          height: 10.h,
        ),
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.primaryGold, width: 2),
          ),
          title: Text(
            LocaleKeys.settings_screen_reset_everything_title.tr(),
            style: GoogleFonts.pressStart2p(
              fontSize: 14.sp,
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            LocaleKeys.settings_screen_reset_everything_message.tr(),
            style: GoogleFonts.pressStart2p(
              fontSize: 10.sp,
              color: AppColors.primaryGold,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.containerBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryGold,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        LocaleKeys.settings_screen_cancel.tr(),
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10.sp,
                          color: AppColors.primaryGold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.of(context).pop();
                      await _performReset();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.containerBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.error,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        LocaleKeys.settings_screen_reset.tr(),
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10.sp,
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _performReset() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.secondaryBackground,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryGold,
                ),
                SizedBox(height: 16),
                Text(
                  LocaleKeys.settings_screen_resetting_everything.tr(),
                  style: TextStyle(color: AppColors.primaryGold),
                ),
              ],
            ),
          );
        },
      );

      // Perform the reset
      final settingsController = ref.read(settingsControllerProvider.notifier);
      await settingsController.resetEverything();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocaleKeys.settings_screen_everything_reset_restarting.tr(),
              style: GoogleFonts.pressStart2p(fontSize: 12.sp),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Restart the app by navigating to the root
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocaleKeys.settings_screen_error_resetting
                  .tr(namedArgs: {'error': e.toString()}),
              style: GoogleFonts.pressStart2p(fontSize: 12.sp),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: GoogleFonts.pressStart2p(
          fontSize: 14.sp,
          color: const Color.fromARGB(255, 0, 0, 0),
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.9),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.containerBackgroundAlt.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(0),
        border: Border.all(
          color: Colors.black,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10.sp,
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 8.sp,
                        color: AppColors.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: (newValue) {
                  HapticFeedback.lightImpact();
                  onChanged(newValue);
                },
                activeColor: AppColors.primaryGold,
                activeTrackColor: AppColors.secondaryBackground,
                inactiveThumbColor: AppColors.textSecondary,
                inactiveTrackColor: AppColors.containerBackground,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final currentLocale = context.locale;
    final supportedLocales = context.supportedLocales;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 3.w), // Remove top padding

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: supportedLocales.map((locale) {
              final isSelected =
                  currentLocale.languageCode == locale.languageCode;
              // Removed flags and kept only text as requested
              final languageName =
                  locale.languageCode == 'en' ? 'English' : 'Español';

              return Transform.translate(
                offset: const Offset(
                    0, 0), // Shift up to overlap border more for hanging effect
                child: SmallWoodButton(
                  label: languageName,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.setLocale(locale);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          LocaleKeys.settings_screen_language_changed.tr(),
                          style: GoogleFonts.pressStart2p(fontSize: 12.sp),
                        ),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSetting({
    required String title,
    required int currentValue,
    required int minValue,
    required int maxValue,
    required int increment,
    required Function(int) onChanged,
    int Function(int, bool)? customIncrementLogic,
  }) {
    // Determine icon based on title

    return Column(
      children: [
        // Title with icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.pressStart2p(
                  fontSize: 15.sp,
                  color: AppColors.primaryGold.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        // Value display and controls
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                // Minus button
                _buildControlButton(
                  '-',
                  _canDecrement(currentValue, minValue, customIncrementLogic)
                      ? () => onChanged(_getDecrementedValue(
                          currentValue, increment, customIncrementLogic))
                      : null,
                ),
                SizedBox(width: 4.w),
                // Value display with shield background
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      currentValue == 0
                          ? (() {
                              // Try to show '00:20' only for Long Break locale key, otherwise '00:10'
                              final longBreakTitle = LocaleKeys
                                  .settings_screen_long_break_time
                                  .tr();
                              if (title == longBreakTitle) {
                                return '00:20';
                              } else {
                                return '00:10';
                              }
                            })()
                          : '${currentValue.toString().padLeft(2, '0')}:00',
                      style: _safePressStart2p(
                        fontSize: 20,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withAlpha(204),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 4.w),
                // Plus button
                _buildControlButton(
                  '+',
                  _canIncrement(currentValue, maxValue, increment)
                      ? () => onChanged(_getIncrementedValue(
                          currentValue, increment, customIncrementLogic))
                      : null,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildControlButton(String label, VoidCallback? onPressed) {
    return _AnimatedControlButton(
      label: label,
      onPressed: onPressed,
    );
  }

  bool _canDecrement(int currentValue, int minValue,
      int Function(int, bool)? customIncrementLogic) {
    if (customIncrementLogic != null) {
      final newValue = customIncrementLogic(currentValue, false);
      return newValue != currentValue && newValue >= minValue;
    }
    return currentValue > minValue;
  }

  bool _canIncrement(int currentValue, int maxValue, int increment) {
    return currentValue < maxValue;
  }

  int _getDecrementedValue(int currentValue, int increment,
      int Function(int, bool)? customIncrementLogic) {
    if (customIncrementLogic != null) {
      return customIncrementLogic(currentValue, false);
    }
    return currentValue - increment;
  }

  int _getIncrementedValue(int currentValue, int increment,
      int Function(int, bool)? customIncrementLogic) {
    if (customIncrementLogic != null) {
      return customIncrementLogic(currentValue, true);
    }
    return currentValue + increment;
  }
}

class PaperWidget extends StatelessWidget {
  final Widget child;

  const PaperWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Background image - centered and sized to fit width while maintaining aspect ratio
            Center(
              child: Image.asset(
                'assets/sprites/paper-sprite.png',
                fit: BoxFit.fitWidth,
                width: 100.w,
                filterQuality: FilterQuality.none,
              ),
            ),
            // Content on top of the image
            child,
          ],
        );
      },
    );
  }
}

class _AnimatedControlButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  const _AnimatedControlButton({
    required this.label,
    this.onPressed,
  });

  @override
  State<_AnimatedControlButton> createState() => _AnimatedControlButtonState();
}

class _AnimatedControlButtonState extends State<_AnimatedControlButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
      // Subtle haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isEnabled
                    ? AppColors.containerBackground
                    : AppColors.containerBackground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isEnabled
                      ? Colors.black
                      : Colors.black.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.6 * _shadowAnimation.value),
                          blurRadius: 4 * _shadowAnimation.value,
                          offset: Offset(0, 2 * _shadowAnimation.value),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: GoogleFonts.pressStart2p(
                    fontSize: 14.sp,
                    color: isEnabled
                        ? (_isPressed
                            ? AppColors.primaryGold.withValues(alpha: 0.8)
                            : AppColors.primaryGold)
                        : AppColors.primaryGold.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                    shadows: isEnabled
                        ? [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(widget.label),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
