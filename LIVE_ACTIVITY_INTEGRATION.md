# Live Activity Integration Guide

## Overview

This guide explains how the Live Activity integration works in the Focus Knight Pomodoro app. The Live Activity displays on the iOS Lock Screen and Dynamic Island, showing real-time timer information with a medieval theme.

## Architecture

### Flutter Side (Dart)

1. **LiveActivityManager** (`lib/core/services/live_activity_manager.dart`)
   - Handles communication with the iOS Live Activity
   - Manages activity lifecycle (create, update, end)
   - Sends user data and timer state to iOS

2. **TimerProvider Integration** (`lib/providers/timer_provider.dart`)
   - Integrates with LiveActivityManager
   - Syncs timer state changes with Live Activity
   - Handles Live Activity actions from Dynamic Island

### iOS Side (Swift)

1. **FocusKnightWidgetLiveActivity.swift**
   - Defines the Live Activity UI for Lock Screen and Dynamic Island
   - Reads data from Flutter via UserDefaults
   - Displays medieval-themed timer interface

## Data Flow

### Static Data (sent once when creating activity)
```dart
final Map<String, dynamic> activityModel = {
  'name': userName,        // User name for avatar
  'ingredient': sessionType, // Session type info
  'quantity': currentSession, // Session number
};
```

### Dynamic Data (updated continuously)
```dart
await _liveActivityManager.updateActivity(
  timeRemaining: state.currentSeconds,
  sessionType: _getSessionTypeString(state.currentMode),
  currentSession: state.sessionNumber,
  paused: !state.isActive,
);
```

### Swift Data Reading
```swift
// Static data from Flutter
let userName = sharedDefault.string(forKey: context.attributes.prefixedKey("name")) ?? "Knight"

// Dynamic data from ContentState
let timeRemaining = context.state.timeRemaining
let sessionType = context.state.sessionType
let isPaused = context.state.paused
```

## Key Features

### 1. User Avatar with Initials
- Displays user's initials in a circular avatar
- Color changes based on timer state (gold for active, orange for paused)
- Shows in all Dynamic Island states and Lock Screen

### 2. Real-time Timer Updates
- Updates every 5 seconds for first 30 seconds
- Updates every 15 seconds for first 5 minutes
- Updates every 30 seconds after that
- Always updates in last 5 seconds

### 3. Session Type Display
- Shows current session type (Focus, Break, Long Break)
- Displays session number
- Progress bar shows completion percentage

### 4. Dynamic Island States
- **Expanded**: Full timer with avatar, time, progress
- **Compact**: Avatar + time remaining
- **Minimal**: Just avatar with status color

## Usage

### 1. Initialize Live Activity
```dart
final liveActivityManager = LiveActivityManager();
await liveActivityManager.init();

await liveActivityManager.createFocusActivity(
  userName: "Liam",
  sessionType: "Focus",
  currentSession: 1,
  timeRemaining: 1500,
  paused: false,
);
```

### 2. Update During Timer
```dart
// Called from timer provider
await liveActivityManager.updateActivity(
  timeRemaining: currentSeconds,
  sessionType: sessionType,
  currentSession: sessionNumber,
  paused: isPaused,
);
```

### 3. End Activity
```dart
await liveActivityManager.endActivity();
```

## Configuration

### App Group ID
- Must match between Flutter and iOS
- Current: `group.com.focusknight.app`

### URL Scheme
- Used for handling Live Activity actions
- Current: `focusknight`

### Widget Extension
- iOS Widget Extension must be configured in Xcode
- Target: `FocusKnightWidgetExtension`

## Troubleshooting

### Common Issues

1. **Live Activity not showing**
   - Check App Group permissions
   - Verify Widget Extension is enabled
   - Ensure iOS 16.1+ device

2. **Data not updating**
   - Check UserDefaults key prefixes
   - Verify ContentState structure matches
   - Check for errors in console

3. **Avatar not displaying**
   - Ensure `name` key is sent in activityModel
   - Check `getInitials()` function in Swift

### Debug Tips

1. **Flutter Side**
   ```dart
   debugPrint('Live Activity update: $timeRemaining seconds');
   ```

2. **iOS Side**
   ```swift
   print("User name: \(userName)")
   print("Time remaining: \(context.state.timeRemaining)")
   ```

## Future Enhancements

1. **User Preferences**
   - Allow users to customize avatar style
   - Add different medieval themes

2. **Interactive Actions**
   - Add pause/resume buttons in Dynamic Island
   - Quick session switching

3. **Advanced Features**
   - Multiple user support
   - Session history in Live Activity
   - Achievement notifications

## Files Modified

- `ios/FocusKnightWidget/FocusKnightWidgetLiveActivity.swift` - iOS Live Activity UI
- `lib/core/services/live_activity_manager.dart` - Flutter Live Activity service
- `lib/providers/timer_provider.dart` - Timer integration
- `lib/main.dart` - Initial setup
- `lib/presentation/timer_screen/timer_screen.dart` - Screen integration




