# Live Activity Integration Guide

This guide explains how to use the Live Activity service with your Medieval Pomodoro app.

## Overview

The Live Activity integration allows your app to show a countdown timer on the iOS Lock Screen and Dynamic Island (iOS 16.1+), and provides similar functionality for Android through RemoteViews. **The Live Activity automatically appears when you put the app in the background and disappears when you return to the app.**

## Files Structure

```
lib/
├── core/
│   ├── services/
│   │   └── live_activity_service.dart          # Core Live Activity service
│   └── widgets/
│       └── minimized_pomodoro_widget.dart      # Compact timer widget
├── providers/
│   ├── live_activity_provider.dart             # Riverpod provider for Live Activity
│   └── timer_provider.dart                     # Updated timer provider with Live Activity integration
└── widgets/
    └── live_activity_demo_widget.dart          # Demo widget showing usage
```

## Configuration

### 1. Update App Group ID and URL Scheme

In `lib/providers/live_activity_provider.dart`, update these values:

```dart
_liveActivityService = LiveActivityService(
  appGroupId: 'group.com.medieval.pomodoro', // TODO: Update with your actual app group ID
  urlScheme: 'medievalpomodoro', // TODO: Update with your actual URL scheme
  customActivityId: 'medieval-pomodoro-activity',
);
```

### 2. iOS Configuration

For iOS, you need to:

1. **Add App Group capability** in Xcode:
   - Open your iOS project in Xcode
   - Select your target
   - Go to "Signing & Capabilities"
   - Add "App Groups" capability
   - Create a group ID like `group.com.medieval.pomodoro`

2. **Configure URL Scheme** in Xcode:
   - In your iOS project, go to Info.plist
   - Add URL scheme: `medievalpomodoro`

3. **Create Widget Extension** (optional but recommended):
   - Follow the [live_activities package documentation](https://pub.dev/packages/live_activities)
   - This allows custom UI for the Live Activity

### 3. Android Configuration

For Android, the service will automatically use RemoteViews when Live Activities are not available.

## Usage

### 1. Automatic Integration

The Live Activity service is automatically integrated with your timer provider and **automatically manages background/foreground transitions**:

- **Start timer**: Live Activity is created/updated
- **Pause timer**: Live Activity is updated to show paused state
- **Resume timer**: Live Activity is updated to show running state
- **Complete session**: Live Activity is ended
- **Restart timer**: Live Activity is updated
- **App goes to background**: Live Activity automatically appears (if timer is active)
- **App comes to foreground**: Live Activity automatically disappears

### 2. Manual Control

You can also manually control the Live Activity:

```dart
// Get the Live Activity provider
final liveActivityProvider = ref.read(liveActivityControllerProvider.notifier);

// Sync current timer state
await liveActivityProvider.syncTimerState(timerState);

// Update specific fields
await liveActivityProvider.patchLiveActivity(
  isRunning: true,
  newEndAt: DateTime.now().add(Duration(minutes: 25)),
);

// End the Live Activity
await liveActivityProvider.endLiveActivity();
```

### 3. Using the Minimized Widget

The `MinimizedPomodoroWidget` can be used in your app for a compact timer display:

```dart
MinimizedPomodoroWidget(
  remaining: Duration(seconds: timerState.currentSeconds),
  isRunning: timerState.isActive,
  onPause: () => ref.read(timerProvider.notifier).pauseTimer(),
  onResume: () => ref.read(timerProvider.notifier).startTimer(),
  onStop: () => ref.read(timerProvider.notifier).restartTimer(),
  title: timerState.sessionType,
  compact: false, // Use true for smaller screens
)
```

### 4. Background/Foreground Behavior

The Live Activity automatically manages background/foreground transitions:

- **When app goes to background**: If a timer is active, the Live Activity automatically appears on the Lock Screen/Dynamic Island
- **When app comes to foreground**: The Live Activity automatically disappears
- **No manual intervention needed**: The system handles this automatically

### 5. Handling Live Activity Actions

The Live Activity can receive actions from the Dynamic Island or Lock Screen. These are automatically handled by the timer provider:

- `pause`: Pauses the timer
- `resume`: Resumes the timer
- `stop`: Restarts the timer

## Demo Widget

Use the `LiveActivityDemoWidget` to see how the integration works:

```dart
import 'package:medieval_pomodoro/widgets/live_activity_demo_widget.dart';

// In your screen
LiveActivityDemoWidget()
```

## Testing

### 1. iOS Simulator

- Live Activities work in iOS 16.1+ simulator
- Use the Dynamic Island or Lock Screen to interact with the Live Activity
- **Test background behavior**: Start a timer, then press Home button or switch apps to see Live Activity appear

### 2. Physical Device

- Test on a physical iOS device for best results
- Make sure to configure the App Group and URL Scheme properly
- **Test background behavior**: Start a timer, then put app in background to see Live Activity on Lock Screen/Dynamic Island

### 3. Android

- RemoteViews will be used when Live Activities are not available
- Test on Android API 24+ devices
- **Test background behavior**: Start a timer, then put app in background to see notification

## Troubleshooting

### Common Issues

1. **Live Activity not showing**:
   - Check if device supports Live Activities (iOS 16.1+)
   - Verify App Group configuration
   - Check console logs for initialization errors

2. **Actions not working**:
   - Verify URL Scheme configuration
   - Check that the timer provider is properly connected

3. **Widget not updating**:
   - Live Activity updates are throttled to avoid excessive updates
   - Updates happen every 30 seconds during timer countdown

### Debug Logs

The integration includes comprehensive logging. Look for these log messages:

- `🚀 Initializing Live Activity service...`
- `✅ Live Activity service initialized successfully`
- `✅ Timer state synced with Live Activity`
- `🎯 Live Activity action received: [action]`
- `🔄 App state changed: [background/foreground]`
- `📱 App went to background` / `📱 App came to foreground`
- `⏰ Timer is active in background, ensuring Live Activity is shown`

## Advanced Configuration

### Custom Live Activity UI

To customize the Live Activity appearance, you need to create a Widget Extension:

1. Follow the [live_activities package documentation](https://pub.dev/packages/live_activities)
2. Create custom UI for your Live Activity
3. Update the `PomodoroSnapshot.toLiveActivityPayload()` method to include your custom data

### Background Updates

The Live Activity can receive updates even when the app is in the background. The service handles this automatically.

## Security Notes

- The Live Activity service only shares timer state information
- No sensitive user data is transmitted
- The service respects user privacy settings

## Performance Considerations

- Live Activity updates are throttled to every 30 seconds during countdown
- The service automatically disposes resources when not needed
- Background updates are handled efficiently

## Future Enhancements

Potential improvements:

1. **Custom Live Activity UI**: Create medieval-themed Live Activity design
2. **Push Notifications**: Send Live Activity updates via push notifications
3. **Multiple Activities**: Support multiple concurrent pomodoro sessions
4. **Statistics**: Show session statistics in Live Activity

## Support

For issues or questions:

1. Check the console logs for error messages
2. Verify your iOS/Android configuration
3. Test on physical devices when possible
4. Refer to the [live_activities package documentation](https://pub.dev/packages/live_activities)
