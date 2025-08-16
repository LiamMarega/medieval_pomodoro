import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/app_export.dart';
import '../../widgets/pixel_frame.dart';
import '../settings_screen/settings_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  Timer? _volumeTimer;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;
  double _currentVolume = 0.0;
  static const double _maxVolume = 0.7; // Volumen máximo para no ser muy fuerte
  static const double _volumeStep = 0.05; // Incremento gradual del volumen
  static const int _volumeStepDuration = 500; // Milisegundos entre incrementos

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

    // Initialize audio player
    _initializeAudio();

    // Keep screen awake during active sessions
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _volumeTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _initializeAudio() async {
    try {
      await _audioPlayer.setAsset('assets/songs/medieval_lofi.mp3');
      await _audioPlayer.setLoopMode(LoopMode.all);
      await _audioPlayer.setVolume(0.0);
    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

  void _startMusicWithFadeIn() async {
    if (!_isMusicEnabled) return;

    try {
      _volumeTimer?.cancel();
      _currentVolume = _maxVolume;
      await _audioPlayer.setVolume(_maxVolume);
      await _audioPlayer.play();

      setState(() {
        _isMusicPlaying = true;
      });
    } catch (e) {
      print('Error starting music: $e');
    }
  }

  void _stopMusicWithFadeOut() async {
    try {
      _volumeTimer?.cancel();

      // Decrementar volumen gradualmente
      _volumeTimer = Timer.periodic(Duration(milliseconds: _volumeStepDuration),
          (timer) async {
        if (_currentVolume > 0.0) {
          _currentVolume -= _volumeStep;
          await _audioPlayer.setVolume(_currentVolume);
        } else {
          timer.cancel();
          await _audioPlayer.pause();
          setState(() {
            _isMusicPlaying = false;
          });
        }
      });
    } catch (e) {
      print('Error stopping music: $e');
    }
  }

  void _startTimer() {
    print('_startTimer called'); // Debug log
    if (_timer?.isActive ?? false) return;

    setState(() {
      _isActive = true;
    });

    // Start music if enabled
    if (_isMusicEnabled) {
      _startMusicWithFadeIn();
    }

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
    print('_pauseTimer called'); // Debug log
    _timer?.cancel();
    setState(() {
      _isActive = false;
    });

    // Stop music if playing
    if (_isMusicPlaying) {
      _stopMusicWithFadeOut();
    }

    // Allow screen to sleep
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _restartTimer() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
      _currentSeconds = _totalSeconds;
    });

    // Stop music if playing
    if (_isMusicPlaying) {
      _stopMusicWithFadeOut();
    }

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

    // Stop music if playing
    if (_isMusicPlaying) {
      _stopMusicWithFadeOut();
    }

    // Allow screen to sleep
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Determine next session type (automatically switch to break after work)
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
    print('_toggleMusic called'); // Debug log
    setState(() {
      _isMusicEnabled = !_isMusicEnabled;
    });

    // Stop music if disabling
    if (!_isMusicEnabled && _isMusicPlaying) {
      _stopMusicWithFadeOut();
    }

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
                // Automatically start the next session after a short delay
                Future.delayed(Duration(seconds: 2), () {
                  if (mounted) {
                    _startTimer();
                  }
                });
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

  Widget _buildMedievalHeader() {
    return PixelFrame(
      padding: 16,
      showBottomBorder: false,
      borderStyle: MedievalBorderStyle.stone,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Crossed swords decoration (left side)

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
            // // Music toggle on the right
            // MedievalMusicToggle(
            //   isMusicEnabled: _isMusicEnabled,
            //   onToggle: _toggleMusic,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTimerContent() {
    return Container(
      child: Column(
        children: [
          _buildUnifiedTimerDisplay(),
          // Control buttons row

          Expanded(
            child: PixelFrame(
              showTopBorder: false,
              showBottomBorder: false,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/sprites/dirt_sprite_2.png'),
                    fit: BoxFit.none,
                    repeat: ImageRepeat.repeat,
                    scale: 8,
                    filterQuality: FilterQuality.low,
                    colorFilter: ColorFilter.mode(
                      Color(0x6b2f01),
                      BlendMode.color,
                    ),
                    opacity: 0.8, // Hace la imagen más chica y repetida
                  ),
                ),
                child: Column(
                  children: [
                    _buildControlButtons(),
                    SizedBox(height: 1.h),
                    Expanded(
                      child: _buildBottomRow(),
                    ),
                    // Motivational message
                  ],
                ),
              ),
            ),
          ),

          _buildMotivationalMessage(),
          // Bottom row: Knight + Side controls
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
      showBottomBorder: false,
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
              'assets/sprites/button_stop.png', // Using close as restart
          label: 'RESTART',
          onPressed: _restartTimer,
        ),
        // Music toggle button
        _buildSpriteButton(
          spritePath: 'assets/sprites/button_stop.png', // Music icon
          label: _isMusicEnabled ? 'MUSIC ON' : 'MUSIC OFF',
          onPressed: _toggleMusic,
        ),
        // Options button
        _buildSpriteButton(
          spritePath: 'assets/sprites/button_stop.png', // Settings icon
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
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Haptic feedback
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(spritePath),
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.pressStart2p(
                  fontSize: 6.sp,
                  color: const Color(0xFFDAA520),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Knight illustration (left side, aspect ratio 1:1)
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.backgroundLight,
                  width: 5,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 5,
                  ),
                ),
                child: Image.asset(
                  'assets/images/knight.gif',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalMessage() {
    return PixelFrame(
      cornerSize: 20,
      edgeThickness: 5,
      padding: 4.5.h,
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
      body: SafeArea(
        bottom: false,
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
