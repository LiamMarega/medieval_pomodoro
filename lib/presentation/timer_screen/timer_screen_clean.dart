import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/pixel_frame.dart';
import './widgets/medieval_music_toggle.dart';
import './widgets/medieval_session_banner.dart';
import '../settings_screen/settings_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;

  // Timer state
  bool _isActive = false;
  int _currentSeconds = 1500; // 25 minutes default
  int _totalSeconds = 1500;
  int _sessionNumber = 1;
  String _sessionType = 'Work';
  bool _isMusicEnabled = false;

  final List<String> _motivationalMessages = [
    "A knight's focus is their greatest weapon!",
    "Every quest begins with a single step forward.",
    "The castle of success is built one stone at a time.",
    "Honor your commitment to excellence, brave warrior!",
    "In the realm of productivity, consistency reigns supreme.",
    "Your dedication today forges tomorrow's victories.",
    "Like a steadfast knight, persist through challenges.",
    "The path to mastery requires unwavering discipline.",
  ];

  String _currentMotivationalMessage = "";

  // Timer duration settings
  int _workDurationMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 30;

  @override
  void initState() {
    super.initState();
    _currentMotivationalMessage = _motivationalMessages.first;

    // Initialize timer durations
    _currentSeconds = _workDurationMinutes * 60;
    _totalSeconds = _workDurationMinutes * 60;

    // Keep screen awake during active sessions
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timer?.isActive ?? false) return;

    setState(() {
      _isActive = true;
    });

    // Keep screen awake
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentSeconds > 0) {
          _currentSeconds--;

          // Update motivational message every 5 minutes
          if (_currentSeconds % 300 == 0) {
            _updateMotivationalMessage();
          }
        } else {
          _completeSession();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
    });

    // Allow screen to sleep
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _restartTimer() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
      _currentSeconds = _totalSeconds;
    });

    // Allow screen to sleep
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _updateMotivationalMessage();
    HapticFeedback.mediumImpact();
  }

  void _completeSession() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
      _sessionNumber++;
    });

    // Allow screen to sleep
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Determine next session type
    _determineNextSession();

    // Show completion notification
    _showSessionCompleteDialog();

    // Haptic feedback and sound effect
    HapticFeedback.heavyImpact();
  }

  void _determineNextSession() {
    if (_sessionType == 'Work') {
      if (_sessionNumber % 4 == 0) {
        _sessionType = 'Long Break';
        _totalSeconds = _longBreakMinutes * 60;
      } else {
        _sessionType = 'Short Break';
        _totalSeconds = _shortBreakMinutes * 60;
      }
    } else {
      _sessionType = 'Work';
      _totalSeconds = _workDurationMinutes * 60;
    }

    setState(() {
      _currentSeconds = _totalSeconds;
    });
  }

  void _updateMotivationalMessage() {
    final random =
        DateTime.now().millisecondsSinceEpoch % _motivationalMessages.length;
    setState(() {
      _currentMotivationalMessage = _motivationalMessages[random];
    });
  }

  void _toggleMusic() {
    setState(() {
      _isMusicEnabled = !_isMusicEnabled;
    });

    // Enhanced feedback for music toggle
    HapticFeedback.mediumImpact();

    // Show a snackbar to indicate music status
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isMusicEnabled ? 'Medieval Music: ON' : 'Medieval Music: OFF',
          style: GoogleFonts.pressStart2p(fontSize: 8.sp),
        ),
        backgroundColor:
            _isMusicEnabled ? AppTheme.successColor : AppTheme.textSecondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSessionCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppTheme.borderColor,
              width: 2,
            ),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'celebration',
                color: AppTheme.secondaryLight,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'SESSION COMPLETE!',
                style: GoogleFonts.pressStart2p(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.normal,
                  color: AppTheme.secondaryLight,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Congratulations, brave knight! You have successfully completed your ${_sessionType.toLowerCase()} session.',
                style: GoogleFonts.roboto(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.successColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Next: ${_sessionType.toUpperCase()}',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8.sp,
                    color: AppTheme.successColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateMotivationalMessage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
              child: Text(
                'CONTINUE',
                style: GoogleFonts.pressStart2p(
                  fontSize: 8.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    if (_totalSeconds == 0) return 0.0;
    return (_totalSeconds - _currentSeconds) / _totalSeconds;
  }

  Widget _buildMedievalHeader() {
    return PixelFrame(
      cornerSize: 32,
      edgeThickness: 8,
      padding: 16,
      borderStyle: MedievalBorderStyle.stone,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Crossed swords decoration (left side)
            SizedBox(
              width: 15.w,
              height: 15.w,
              child: Stack(
                children: [
                  // First sword
                  Positioned(
                    top: 1.w,
                    right: 4.w,
                    child: Transform.rotate(
                      angle: 0.785398, // 45 degrees
                      child: Container(
                        width: 2.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC0C0C0), // Silver
                          borderRadius: BorderRadius.circular(1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Second sword
                  Positioned(
                    top: 1.w,
                    left: 4.w,
                    child: Transform.rotate(
                      angle: -0.785398, // -45 degrees
                      child: Container(
                        width: 2.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC0C0C0), // Silver
                          borderRadius: BorderRadius.circular(1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Title
            Expanded(
              child: Text(
                'POMODORO TIMER',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFFDAA520), // Golden color
                  letterSpacing: 2.0,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    Shadow(
                      color: const Color(0xFFDAA520).withValues(alpha: 0.5),
                      offset: const Offset(-1, -1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            // Music toggle on the right
            MedievalMusicToggle(
              isMusicEnabled: _isMusicEnabled,
              onToggle: _toggleMusic,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTimerContent() {
    return Container(
      padding: EdgeInsets.all(2.w),
      child: Column(
        children: [
          SizedBox(height: 2.h),
          // Session banner
          MedievalSessionBanner(
            sessionType: _sessionType,
            sessionNumber: _sessionNumber,
          ),
          SizedBox(height: 3.h),
          // Timer display unificado
          _buildUnifiedTimerDisplay(),
          SizedBox(height: 3.h),
          // Control buttons row
          _buildControlButtons(),
          SizedBox(height: 3.h),
          // Bottom row: Knight + Side controls
          Expanded(
            child: _buildBottomRow(),
          ),
          SizedBox(height: 2.h),
          // Motivational message
          _buildMotivationalMessage(),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildUnifiedTimerDisplay() {
    return PixelFrame(
      cornerSize: 32,
      edgeThickness: 8,
      padding: 16,
      borderStyle: MedievalBorderStyle.stone,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_currentSeconds),
              style: GoogleFonts.pressStart2p(
                fontSize: 36.sp,
                fontWeight: FontWeight.normal,
                color: const Color(0xFFDAA520),
                letterSpacing: 4.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                  Shadow(
                    color: const Color(0xFFDAA520).withValues(alpha: 0.5),
                    offset: const Offset(-2, -2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'SESSION $_sessionNumber - ${_sessionType.toUpperCase()}',
              style: GoogleFonts.pressStart2p(
                fontSize: 10.sp,
                color: const Color(0xFFB8860B),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Play/Stop button
        _buildSpriteButton(
          spritePath: _isActive
              ? 'assets/sprites/button_stop.png'
              : 'assets/sprites/button_play.png',
          label: _isActive ? 'STOP' : 'PLAY',
          onPressed: _isActive ? _pauseTimer : _startTimer,
        ),
        // Restart button
        _buildSpriteButton(
          spritePath:
              'assets/sprites/close_button.png', // Using close as restart
          label: 'RESTART',
          onPressed: _restartTimer,
        ),
        // Options button
        _buildSpriteButton(
          spritePath: 'assets/sprites/minize_button.png', // Settings icon
          label: 'OPTIONS',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  workDurationMinutes: _workDurationMinutes,
                  shortBreakMinutes: _shortBreakMinutes,
                  longBreakMinutes: _longBreakMinutes,
                  isMusicEnabled: _isMusicEnabled,
                  onSettingsChanged: (workMinutes, shortBreakMinutes,
                      longBreakMinutes, musicEnabled) {
                    setState(() {
                      _workDurationMinutes = workMinutes;
                      _shortBreakMinutes = shortBreakMinutes;
                      _longBreakMinutes = longBreakMinutes;
                      _isMusicEnabled = musicEnabled;

                      // Update current timer if in work session
                      if (_sessionType == 'Work') {
                        _totalSeconds = _workDurationMinutes * 60;
                        _currentSeconds = _totalSeconds;
                      }
                    });
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpriteButton({
    required String spritePath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return PixelFrame(
      cornerSize: 16,
      edgeThickness: 4,
      padding: 8,
      borderStyle: MedievalBorderStyle.stone,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 25.w,
          padding: EdgeInsets.all(2.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(spritePath),
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                label,
                style: GoogleFonts.pressStart2p(
                  fontSize: 8.sp,
                  color: const Color(0xFFDAA520),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        // Knight illustration (left side, aspect ratio 1:1)
        Expanded(
          flex: 1,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: PixelFrame(
              cornerSize: 24,
              edgeThickness: 6,
              padding: 8,
              borderStyle: MedievalBorderStyle.stone,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/knight.gif',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 2.w),
        // Right side controls
        Expanded(
          flex: 1,
          child: Column(
            children: [
              // Music control
              Expanded(
                child: PixelFrame(
                  cornerSize: 16,
                  edgeThickness: 4,
                  padding: 6,
                  borderStyle: MedievalBorderStyle.stone,
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          color: const Color(0xFFDAA520),
                          size: 24,
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          width: 15.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: _isMusicEnabled
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF757575),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: const Color(0xFFDAA520),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _isMusicEnabled ? 'ON' : 'OFF',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 6.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              // Progress indicator
              Expanded(
                child: PixelFrame(
                  cornerSize: 16,
                  edgeThickness: 4,
                  padding: 6,
                  borderStyle: MedievalBorderStyle.stone,
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'PROGRESS',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 8.sp,
                            color: const Color(0xFFDAA520),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        LinearProgressIndicator(
                          value: _getProgress(),
                          backgroundColor: const Color(0xFF4A3728),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFDAA520),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '${(_getProgress() * 100).toInt()}%',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 6.sp,
                            color: const Color(0xFFB8860B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalMessage() {
    return PixelFrame(
      cornerSize: 20,
      edgeThickness: 5,
      padding: 12,
      borderStyle: MedievalBorderStyle.stone,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(2.w),
        child: Text(
          _currentMotivationalMessage,
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 8.sp,
            color: const Color(0xFFB8860B),
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF2D1B0F), // Dark medieval brown background
      body: SafeArea(
        child: Column(
          children: [
            // Medieval title header
            _buildMedievalHeader(),
            // Main timer content
            Expanded(
              child: _buildMainTimerContent(),
            ),
          ],
        ),
      ),
    );
  }
}
