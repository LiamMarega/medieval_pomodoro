package com.focusknight.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.live_activities.LiveActivityManagerHolder

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        LiveActivityManagerHolder.instance = CustomLiveActivityManager(this)
        super.configureFlutterEngine(flutterEngine)
    }
}