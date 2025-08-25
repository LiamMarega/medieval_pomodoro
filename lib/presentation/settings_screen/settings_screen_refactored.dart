import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../providers/settings_provider.dart';
import '../../providers/audio_provider.dart';
import '../../widgets/pixel_frame.dart';
import 'widgets/settings_header_widget.dart';
import 'widgets/audio_controls_widget.dart';

class SettingsScreenRefactored extends ConsumerStatefulWidget {
  const SettingsScreenRefactored({super.key});

  @override
  ConsumerState<SettingsScreenRefactored> createState() =>
      _SettingsScreenRefactoredState();
}

class _SettingsScreenRefactoredState
    extends ConsumerState<SettingsScreenRefactored> {
  late int _workDurationMinutes = 25;
  late int _shortBreakMinutes = 5;
  late int _longBreakMinutes = 30;

  @override
  void initState() {
    super.initState();
    // Initialize with default values, will be updated when settings load

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

    return Scaffold(
      body: Column(
        children: [
          const SettingsHeaderWidget(),
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
                  child: Text('Error loading settings: $error'),
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
                        // Controles de audio en la parte superior
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: const AudioControlsWidget(),
                        ),

                        _buildDurationSetting(
                          title: 'WORK DURATION',
                          currentValue: _workDurationMinutes,
                          minValue: 1,
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
                              } else if (currentValue > 1) {
                                // If between 1 and 5, subtract 1
                                return currentValue - 1;
                              } else {
                                // If at 1, can't go lower
                                return currentValue;
                              }
                            }
                          },
                        ),
                        SizedBox(height: 4.h),
                        _buildDurationSetting(
                          title: 'SHORT BREAK TIME',
                          currentValue: _shortBreakMinutes,
                          minValue: 1,
                          maxValue: 15,
                          increment: 1,
                          onChanged: (value) {
                            setState(() => _shortBreakMinutes = value);
                            _autoSaveSettings();
                          },
                        ),
                        SizedBox(height: 4.h),
                        _buildDurationSetting(
                          title: 'LONG BREAK TIME',
                          currentValue: _longBreakMinutes,
                          minValue: 15,
                          maxValue: 60,
                          increment: 5,
                          onChanged: (value) {
                            setState(() => _longBreakMinutes = value);
                            _autoSaveSettings();
                          },
                        ),
                        SizedBox(height: 3.h),
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
                  child: Text('${currentValue.toString().padLeft(2, '0')}:00'),
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
