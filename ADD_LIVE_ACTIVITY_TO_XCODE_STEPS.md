# Step-by-Step Guide: Add LiveActivityManager.swift to Xcode Project

## 🚨 IMPORTANT: Fix the Build Error

The build is failing because `LiveActivityManager.swift` is not added to the Xcode project. Follow these steps to fix it:

## Step 1: Open Xcode Project
1. Xcode should already be open with `Runner.xcworkspace`
2. If not, run: `cd ios && open Runner.xcworkspace`

## Step 2: Add LiveActivityManager.swift to Project

### Option A: Drag and Drop Method (Recommended)
1. In Xcode's Project Navigator (left sidebar), find the **Runner** folder
2. Right-click on the **Runner** folder (not the project root)
3. Select **"Add Files to 'Runner'"**
4. Navigate to: `ios/Runner/LiveActivityManager.swift`
5. **IMPORTANT**: Make sure these options are checked:
   - ✅ **"Add to target: Runner"** (this is crucial!)
   - ✅ **"Copy items if needed"** (if not already in the project)
6. Click **"Add"**

### Option B: File Menu Method
1. In Xcode, go to **File → Add Files to "Runner"**
2. Navigate to: `ios/Runner/LiveActivityManager.swift`
3. Ensure **"Add to target: Runner"** is checked
4. Click **"Add"**

## Step 3: Verify File is Added
1. In the Project Navigator, you should see `LiveActivityManager.swift` under the **Runner** folder
2. Click on the file to make sure it opens and shows the Swift code
3. The file should be highlighted in blue (indicating it's part of the target)

## Step 4: Check Target Membership
1. Select `LiveActivityManager.swift` in the Project Navigator
2. Open the **File Inspector** (right sidebar, first tab)
3. Under **"Target Membership"**, make sure **"Runner"** is checked
4. If not, check the box next to **"Runner"**

## Step 5: Verify Live Activities Capability
1. Select the **Runner** target (top of Project Navigator)
2. Go to **"Signing & Capabilities"** tab
3. Look for **"Live Activities"** capability
4. If not present, click **"+ Capability"** and add **"Live Activities"**

## Step 6: Uncomment the Code
After adding the file, uncomment the Live Activity calls in `AppDelegate.swift`:

```swift
// In AppDelegate.swift, uncomment these lines:

// DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//   startHelloWorldLiveActivity()
// }

// And in applicationDidBecomeActive:
// startHelloWorldLiveActivity()
```

## Step 7: Build and Test
1. Clean the build: **Product → Clean Build Folder**
2. Build the project: **Product → Build**
3. Run on your device: **Product → Run**

## 🐛 Troubleshooting

### If you still get "Cannot find 'startHelloWorldLiveActivity'" error:
1. **Check Target Membership**: Make sure `LiveActivityManager.swift` is added to the **Runner** target
2. **Clean Build**: Product → Clean Build Folder
3. **Restart Xcode**: Sometimes Xcode needs a restart to recognize new files
4. **Check File Location**: Ensure the file is in the correct location: `ios/Runner/LiveActivityManager.swift`

### If the file doesn't appear in Xcode:
1. **Refresh Project Navigator**: Right-click in Project Navigator → "Refresh"
2. **Check File Exists**: Verify `LiveActivityManager.swift` exists in the file system
3. **Re-add the file**: Try adding it again using the steps above

### If you get other build errors:
1. **Check iOS Deployment Target**: Make sure it's set to iOS 16.1 or higher
2. **Check Swift Version**: Ensure Swift version is 5.0 or higher
3. **Check Entitlements**: Verify `Runner.entitlements` has the correct app group

## ✅ Success Indicators

When everything is working correctly:
1. ✅ `LiveActivityManager.swift` appears in Project Navigator under Runner
2. ✅ File opens and shows Swift code when clicked
3. ✅ Target Membership shows "Runner" is checked
4. ✅ Build succeeds without errors
5. ✅ App launches and Live Activity appears on device

## 🎯 Expected Result

After completing these steps:
- The app will build successfully
- Live Activity will start automatically when the app launches
- You'll see the animated knight emoji (⚔️) in the Dynamic Island
- The Live Activity will show on the lock screen

## 📱 Testing

Test on a physical device with:
- iPhone 14 Pro or newer (has Dynamic Island)
- iOS 16.1 or higher
- Live Activities enabled in device settings

The Live Activity should start automatically and show the medieval-themed animations!
