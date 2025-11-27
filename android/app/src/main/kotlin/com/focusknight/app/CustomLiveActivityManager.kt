package com.focusknight.app

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import com.example.live_activities.LiveActivityManager

class CustomLiveActivityManager(private val context: Context) : LiveActivityManager(context) {

    private val remoteViews = RemoteViews(context.packageName, R.layout.live_activity)

    override suspend fun buildNotification(
        notification: Notification.Builder,
        event: String,
        data: Map<String, Any>
    ): Notification {
        try {
            android.util.Log.d("CustomLiveActivity", "Building notification for event: $event")
            // Extract data from Flutter
            val timeRemaining = data["timeRemaining"] as? Int ?: 0
            val sessionType = data["sessionType"] as? String ?: "Focus"
            val currentSession = data["currentSession"] as? Int ?: 1
            val paused = data["paused"] as? Boolean ?: false

            // Update Text
            remoteViews.setTextViewText(R.id.session_type, sessionType)
            remoteViews.setTextViewText(R.id.session_info, "Session $currentSession")
            remoteViews.setTextViewText(R.id.timer_text, formatTime(timeRemaining))

            // Update Button Text/State
            remoteViews.setTextViewText(R.id.btn_toggle, if (paused) "Resume" else "Pause")
            
            // Setup Actions (Deep Links)
            val toggleAction = if (paused) "resume" else "pause"
            remoteViews.setOnClickPendingIntent(R.id.btn_toggle, createDeepLinkIntent("focusknight://$toggleAction"))
            remoteViews.setOnClickPendingIntent(R.id.btn_skip, createDeepLinkIntent("focusknight://skip"))

            // Build Notification
            return notification
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm) // Use a system icon or app icon
                .setCustomContentView(remoteViews)
                .setCustomBigContentView(remoteViews)
                .setStyle(Notification.DecoratedCustomViewStyle())
                .setOngoing(true)
                .build()
        } catch (e: Exception) {
            android.util.Log.e("CustomLiveActivity", "Error building notification", e)
            return notification.build() // Fallback to default
        }
    }

    private fun formatTime(seconds: Int): String {
        val minutes = seconds / 60
        val remainingSeconds = seconds % 60
        return String.format("%02d:%02d", minutes, remainingSeconds)
    }

    private fun createDeepLinkIntent(url: String): PendingIntent {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            setPackage(context.packageName) // Ensure it opens our app
        }
        
        return PendingIntent.getActivity(
            context,
            url.hashCode(), // Unique Request Code
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}
