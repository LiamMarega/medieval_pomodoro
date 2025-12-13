import 'package:flutter/material.dart';
import 'package:medieval_pomodoro/core/services/asset_manager.dart';
import 'package:medieval_pomodoro/presentation/onboarding/onboarding_integration.dart';
import 'package:medieval_pomodoro/presentation/timer_screen/timer_screen.dart';

class InitialLoadingScreen extends StatefulWidget {
  const InitialLoadingScreen({super.key});

  @override
  State<InitialLoadingScreen> createState() => _InitialLoadingScreenState();
}

class _InitialLoadingScreenState extends State<InitialLoadingScreen> {
  double _opacity = 0.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _startLoading();
    // Start fade in animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  Future<void> _startLoading() async {
    // Artificial delay to show logo if loading is too fast,
    // and to ensure smooth transition
    final minTime = Future.delayed(const Duration(seconds: 2));

    // Load assets
    final assetLoad = AssetManager().preloadAssets(context);

    await Future.wait([minTime, assetLoad]);

    if (mounted) {
      setState(() => _loading = false);
      _navigateToNext();
    }
  }

  void _navigateToNext() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OnboardingIntegration.buildInitialScreen(const TimerScreen()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
          opacity: _opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/focus_knight_logo.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 32),
              // Loading indicator
              if (_loading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Color(0xFFDAA520), // Gold
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
