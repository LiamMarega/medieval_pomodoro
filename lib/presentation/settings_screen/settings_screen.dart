import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../generated/locale_keys.g.dart';
import '../../providers/settings_provider.dart';
import '../../providers/audio_provider.dart';
import '../../widgets/pixel_frame.dart';
import '../../widgets/pixel_art_effect.dart';
import 'widgets/settings_header_widget.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late int _workDurationMinutes = 25;
  late int _shortBreakMinutes = 5;
  late int _longBreakMinutes = 30;

  @override
  void initState() {
    super.initState();

    // Initialize audio provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioControllerProvider.notifier).initialize();
    });
  }

  void _autoSaveSettings() {
    final settingsController = ref.read(settingsControllerProvider.notifier);

    // Update settings in the settings provider (this will persist to local storage)
    settingsController.updateSettings(
      workDurationMinutes: _workDurationMinutes,
      shortBreakMinutes: _shortBreakMinutes,
      longBreakMinutes: _longBreakMinutes,
      isMusicEnabled: true, // Always true
    );

    // The timer provider will automatically pick up the new settings
    // since it watches the settings provider
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return PixelArtEffect(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: PixelFrame(
                cornerSize: 24,
                edgeThickness: 6,
                padding: 20,
                borderStyle: MedievalBorderStyle.stone,
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
                        _longBreakMinutes != settings.longBreakMinutes) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _workDurationMinutes = settings.workDurationMinutes;
                          _shortBreakMinutes = settings.shortBreakMinutes;
                          _longBreakMinutes = settings.longBreakMinutes;
                        });
                      });
                    }

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SettingsHeaderWidget(),

                          // ElevatedButton(
                          //   onPressed: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => const GalleryView()),
                          //     );
                          //   },
                          //   child: const Text('Start Timer'),
                          // ),
                          // // Controles de audio en la parte superior
                          // Padding(
                          //   padding: const EdgeInsets.all(16.0),
                          //   child: const AudioControlsWidget(),
                          // ),

                          _buildDurationSetting(
                            title:
                                LocaleKeys.settings_screen_work_duration.tr(),
                            currentValue: _workDurationMinutes,
                            minValue:
                                0, // Allow 0 minutes (10 seconds for testing)
                            maxValue: 60,
                            increment: 5,
                            onChanged: (value) {
                              setState(() => _workDurationMinutes = value);
                              _autoSaveSettings();
                            },
                            customIncrementLogic: (currentValue, isIncrement) {
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
                          SizedBox(height: 4.h),
                          _buildDurationSetting(
                            title: LocaleKeys.settings_screen_short_break_time
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
                          SizedBox(height: 4.h),
                          _buildDurationSetting(
                            title:
                                LocaleKeys.settings_screen_long_break_time.tr(),
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
                          SizedBox(height: 4.h),

                          // Language selector
                          _buildLanguageSelector(context),

                          SizedBox(height: 3.h),

                          // Test durations button
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  final settingsController = ref.read(
                                      settingsControllerProvider.notifier);
                                  settingsController.setTestDurations();

                                  // Update local state
                                  setState(() {
                                    _workDurationMinutes = 0;
                                    _shortBreakMinutes = 0;
                                    _longBreakMinutes = 0;
                                  });

                                  // Show feedback
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        LocaleKeys
                                            .settings_screen_test_mode_activated
                                            .tr(),
                                        style: GoogleFonts.pressStart2p(
                                            fontSize: 12.sp),
                                      ),
                                      backgroundColor: const Color(0xFFDAA520),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A3728),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFDAA520),
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    LocaleKeys
                                        .settings_screen_set_test_durations
                                        .tr(),
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 12.sp,
                                      color: const Color(0xFFDAA520),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // Reset to normal durations button
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  final settingsController = ref.read(
                                      settingsControllerProvider.notifier);
                                  settingsController.resetToDefaults();

                                  // Update local state
                                  setState(() {
                                    _workDurationMinutes = 25;
                                    _shortBreakMinutes = 5;
                                    _longBreakMinutes = 30;
                                  });

                                  // Show feedback
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        LocaleKeys
                                            .settings_screen_normal_mode_activated
                                            .tr(),
                                        style: GoogleFonts.pressStart2p(
                                            fontSize: 12.sp),
                                      ),
                                      backgroundColor: const Color(0xFF4CAF50),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A3728),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF4CAF50),
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    '🔄 RESET TO NORMAL DURATIONS',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF4CAF50),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // View Stats button
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/stats-screen');
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A3728),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFDAA520),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.analytics,
                                        color: Color(0xFFDAA520),
                                        size: 20,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        LocaleKeys
                                            .settings_screen_view_statistics
                                            .tr(),
                                        style: GoogleFonts.pressStart2p(
                                          fontSize: 12.sp,
                                          color: const Color(0xFFDAA520),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // Reset everything button
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Center(
                              child: GestureDetector(
                                onTap: () =>
                                    _showResetConfirmationDialog(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A3728),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFFF4444),
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    LocaleKeys
                                        .settings_screen_reset_everything_restart
                                        .tr(),
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 12.sp,
                                      color: const Color(0xFFFF4444),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
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
          backgroundColor: const Color(0xFF2A1B0A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFDAA520), width: 2),
          ),
          title: Text(
            LocaleKeys.settings_screen_reset_everything_title.tr(),
            style: GoogleFonts.pressStart2p(
              fontSize: 14.sp,
              color: const Color(0xFFFF4444),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            LocaleKeys.settings_screen_reset_everything_message.tr(),
            style: GoogleFonts.pressStart2p(
              fontSize: 10.sp,
              color: const Color(0xFFDAA520),
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
                        color: const Color(0xFF4A3728),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFDAA520),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        LocaleKeys.settings_screen_cancel.tr(),
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10.sp,
                          color: const Color(0xFFDAA520),
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
                        color: const Color(0xFF4A3728),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFF4444),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        LocaleKeys.settings_screen_reset.tr(),
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10.sp,
                          color: const Color(0xFFFF4444),
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
            backgroundColor: Color(0xFF2A1B0A),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFFDAA520),
                ),
                SizedBox(height: 16),
                Text(
                  LocaleKeys.settings_screen_resetting_everything.tr(),
                  style: TextStyle(color: Color(0xFFDAA520)),
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
            backgroundColor: const Color(0xFF4CAF50),
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
            backgroundColor: const Color(0xFFFF4444),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final currentLocale = context.locale;
    final supportedLocales = context.supportedLocales;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          // Title
          Text(
            LocaleKeys.settings_screen_language.tr(),
            style: GoogleFonts.pressStart2p(
              fontSize: 16.sp,
              color: const Color(0xFFDAA520),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          // Language buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: supportedLocales.map((locale) {
              final isSelected =
                  currentLocale.languageCode == locale.languageCode;
              final languageName =
                  locale.languageCode == 'en' ? 'English' : 'Español';

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.setLocale(locale);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        LocaleKeys.settings_screen_language_changed.tr(),
                        style: GoogleFonts.pressStart2p(fontSize: 12.sp),
                      ),
                      backgroundColor: const Color(0xFF4CAF50),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4A3728)
                        : const Color(0xFF2A1B0A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFDAA520)
                          : const Color(0xFF666666),
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFDAA520)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    languageName,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 14.sp,
                      color: isSelected
                          ? const Color(0xFFDAA520)
                          : const Color(0xFF666666),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          // Title
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.pressStart2p(
              fontSize: 16.sp,
              color: const Color(0xFFDAA520),
              fontWeight: FontWeight.bold,
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 3.h),
          // Value display and controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Minus button
              _buildControlButton(
                '-',
                _canDecrement(currentValue, minValue, customIncrementLogic)
                    ? () => onChanged(_getDecrementedValue(
                        currentValue, increment, customIncrementLogic))
                    : null,
              ),
              // Value display
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3728),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFDAA520),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDAA520).withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.pressStart2p(
                    fontSize: 20.sp,
                    color: const Color(0xFFDAA520),
                    fontWeight: FontWeight.bold,
                  ),
                  child: Text(currentValue == 0
                      ? (title ==
                              LocaleKeys.settings_screen_long_break_time.tr()
                          ? '00:20'
                          : '00:10')
                      : '${currentValue.toString().padLeft(2, '0')}:00'),
                ),
              ),
              // Plus button
              _buildControlButton(
                '+',
                _canIncrement(currentValue, maxValue, increment)
                    ? () => onChanged(_getIncrementedValue(
                        currentValue, increment, customIncrementLogic))
                    : null,
              ),
            ],
          ),
        ],
      ),
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
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: isEnabled
                    ? const Color(0xFF4A3728)
                    : const Color(0xFF4A3728).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEnabled
                      ? const Color(0xFFDAA520)
                      : const Color(0xFFDAA520).withValues(alpha: 0.5),
                  width: 3,
                ),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: const Color(0xFFDAA520)
                              .withValues(alpha: 0.3 * _shadowAnimation.value),
                          blurRadius: 8 * _shadowAnimation.value,
                          offset: Offset(0, 4 * _shadowAnimation.value),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: GoogleFonts.pressStart2p(
                    fontSize: 24.sp,
                    color: isEnabled
                        ? (_isPressed
                            ? const Color(0xFFDAA520).withValues(alpha: 0.8)
                            : const Color(0xFFDAA520))
                        : const Color(0xFFDAA520).withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
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
