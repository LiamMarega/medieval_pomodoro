import 'package:flutter/material.dart';

class AssetManager {
  // Singleton instance
  static final AssetManager _instance = AssetManager._internal();
  factory AssetManager() => _instance;
  AssetManager._internal();

  /// Images to pre-cache
  static const List<String> _imageAssets = [
    // Logos
    'assets/images/focus_knight_logo.png',

    // Backgrounds for TimerScreen & others
    'assets/sprites/bricks_background.png',
    'assets/sprites/bricks_background_mobile.png',
    'assets/sprites/dirt_sprite.png',
    'assets/sprites/dirt_sprite_2.png',
    'assets/sprites/dirt_sprite_3.png',
    'assets/sprites/paper-sprite.png',
    'assets/sprites/paper-sprite-2.png',

    // UI Elements
    'assets/sprites/play_button.png',
    'assets/sprites/stop_button.png',
    'assets/sprites/reset_button.png',
    'assets/sprites/settings_button.png',
    'assets/sprites/minize_button.png',
    'assets/sprites/close_button.png',
    'assets/sprites/button_play.png',

    // Knight Sprites (GIFs)
    'assets/animations/knight_way_1.gif',
    'assets/animations/knight_way_2.gif',
    'assets/animations/knight_bridge.gif',
    'assets/animations/dragon_dark_room.gif',
    'assets/animations/break_time.gif',
  ];

  /// Preload all critical assets
  Future<void> preloadAssets(BuildContext context) async {
    debugPrint('🔄 AssetManager: Starting asset preloading...');
    final stopwatch = Stopwatch()..start();

    try {
      await Future.wait([
        _preloadImages(context),
        // Add other asset types here if needed (e.g. SVGs, Rive)
      ]);
    } catch (e) {
      debugPrint('❌ AssetManager: Error preloading assets: $e');
    } finally {
      stopwatch.stop();
      debugPrint(
          '✅ AssetManager: Assets preloaded in ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  Future<void> _preloadImages(BuildContext context) async {
    final List<Future<void>> tasks = [];

    for (final assetPath in _imageAssets) {
      tasks.add(precacheImage(AssetImage(assetPath), context));
    }

    await Future.wait(tasks);
  }
}
