# Adding LiveActivityManager.swift to Xcode Project

Since the LiveActivityManager.swift file was created but needs to be added to the Xcode project, follow these steps:

## Step 1: Open Xcode Project
1. Open the iOS project in Xcode: `ios/Runner.xcworkspace`
2. Make sure you're in the **Runner** target (not the widget extension)

## Step 2: Add LiveActivityManager.swift to Project
1. Right-click on the **Runner** folder in the project navigator
2. Select **"Add Files to 'Runner'"**
3. Navigate to `ios/Runner/LiveActivityManager.swift`
4. Make sure **"Add to target: Runner"** is checked
5. Click **"Add"**

## Step 3: Verify Build Settings
1. Select the **Runner** target
2. Go to **"Signing & Capabilities"**
3. Make sure **"Live Activities"** capability is added
4. If not, click **"+ Capability"** and add **"Live Activities"**

## Step 4: Test the Setup
1. Build and run the project on a physical device (iOS 16.1+)
2. The Live Activity should start automatically when the app launches
3. You should see the animated knight emoji (⚔️) in the Dynamic Island

## Troubleshooting
- Make sure you're testing on a device with Dynamic Island (iPhone 14 Pro or newer)
- Ensure iOS version is 16.1 or higher
- Check that Live Activities are enabled in device settings
- Verify the app group `group.com.focusknight.app` is properly configured

## Expected Behavior
- **Compact view**: Animated knight emoji (⚔️) that rotates and scales
- **Expanded view**: Shows "FOCUS" text with opacity animation
- **Minimal view**: Animated knight emoji
- **Lock screen**: Shows the Live Activity with animated elements

The Live Activity will start automatically when the app becomes active and will show the medieval-themed animations in the Dynamic Island.
