import UIKit
import Flutter
import SwiftUI
import ActivityKit
import FamilyControls
import ManagedSettings
import DeviceActivity

// MARK: - Live Activity Attributes (shared between app and widget)
public struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState
    
    public struct ContentState: Codable, Hashable {
        public var paused: Bool = false
        public var timeRemaining: Int = 1500 // 25 minutes in seconds
        public var sessionType: String = "Focus" // "Focus", "Break", "Long Break"
        public var currentSession: Int = 1
        
        public init(paused: Bool = false, timeRemaining: Int = 1500, sessionType: String = "Focus", currentSession: Int = 1) {
            self.paused = paused
            self.timeRemaining = timeRemaining
            self.sessionType = sessionType
            self.currentSession = currentSession
        }
    }
    
    public var id = UUID()
    
    public init(id: UUID = UUID()) {
        self.id = id
    }
}

@available(iOS 16.1, *)
func startHelloWorldLiveActivity() {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { 
        print("Live Activities not enabled")
        return 
    }

    // Evitar duplicados si ya hay una Live Activity igual corriendo
    if !Activity<LiveActivitiesAppAttributes>.activities.isEmpty { 
        print("Live Activity already running")
        return 
    }

    let attributes = LiveActivitiesAppAttributes()
    let contentState = LiveActivitiesAppAttributes.ContentState(
      paused: false,
      timeRemaining: 1500,
      sessionType: "Focus",
      currentSession: 1
    )

    do {
        _ = try Activity<LiveActivitiesAppAttributes>.request(
            attributes: attributes,
            contentState: contentState,
            pushType: nil
        )
        print("Live Activity started successfully")
    } catch {
        print("No se pudo iniciar la Live Activity: \(error)")
    }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  // Screen Time components - using computed properties to avoid @available on stored properties
  @available(iOS 16.0, *)
  private var authCenter: AuthorizationCenter {
    AuthorizationCenter.shared
  }
  
  @available(iOS 15.0, *)
  private var managedSettingsStore: ManagedSettingsStore {
    ManagedSettingsStore()
  }
  
  private let userDefaults = UserDefaults.standard
  private let appsSelectedKey = "apps_selected_tokens"
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup Screen Time method channel
    if #available(iOS 16.0, *) {
      setupScreenTimeChannel()
    }
    
    // Start Live Activity when app launches
    if #available(iOS 16.1, *) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        startHelloWorldLiveActivity()
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    // Start Live Activity when app becomes active
    if #available(iOS 16.1, *) {
      startHelloWorldLiveActivity()
    }
  }
  
  @available(iOS 16.0, *)
  private func setupScreenTimeChannel() {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.focusknight.app/screen_time",
      binaryMessenger: controller.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      
      switch call.method {
      case "checkAuthorizationStatus":
        self.checkAuthorizationStatus(result: result)
      case "requestFamilyControlsAuth":
        self.requestFamilyControlsAuth(result: result)
      case "selectAppsToBlock":
        self.selectAppsToBlock(result: result)
      case "blockApps":
        self.blockApps(result: result)
      case "unblockApps":
        self.unblockApps(result: result)
      case "checkAppsSelected":
        self.checkAppsSelected(result: result)
      case "updateShieldStatus":
        self.updateShieldStatus(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  @available(iOS 16.0, *)
  private func updateShieldStatus(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let title = args["title"] as? String,
          let subtitle = args["subtitle"] as? String,
          let buttonLabel = args["buttonLabel"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing arguments", details: nil))
      return
    }

    if let userDefaults = UserDefaults(suiteName: "group.com.focusknight.app") {
        userDefaults.set(title, forKey: "shield_title")
        userDefaults.set(subtitle, forKey: "shield_subtitle")
        userDefaults.set(buttonLabel, forKey: "shield_button_label")
        userDefaults.synchronize()
        print("🛡️ Shield status updated: \(title)")
        result(nil)
    } else {
        print("❌ Failed to access App Group UserDefaults")
        result(FlutterError(code: "USER_DEFAULTS_ERROR", message: "Failed to access App Group", details: nil))
    }
  }
  
  @available(iOS 16.0, *)
  private func checkAuthorizationStatus(result: @escaping FlutterResult) {
    let status = authCenter.authorizationStatus
    let isAuthorized = (status == .approved)
    print("🔐 Authorization status: \(status.rawValue), isAuthorized: \(isAuthorized)")
    result(isAuthorized)
  }
  
  @available(iOS 16.0, *)
  private func requestFamilyControlsAuth(result: @escaping FlutterResult) {
    print("🔒 Requesting Family Controls authorization...")
    
    Task {
      do {
        try await authCenter.requestAuthorization(for: .individual)
        let isAuthorized = authCenter.authorizationStatus == .approved
        print("✅ Authorization result: \(isAuthorized)")
        await MainActor.run {
          result(isAuthorized)
        }
      } catch {
        print("❌ Authorization error: \(error)")
        await MainActor.run {
          result(false)
        }
      }
    }
  }
  
  @available(iOS 16.0, *)
  private func selectAppsToBlock(result: @escaping FlutterResult) {
    print("📱 Showing app selection UI...")
    
    guard authCenter.authorizationStatus == .approved else {
      print("❌ Not authorized to select apps")
      result(false)
      return
    }
    
    let controller = window?.rootViewController as! FlutterViewController
    
    Task {
      await MainActor.run {
        // Load previous selection if it exists
        var selection = self.loadAppSelection() ?? FamilyActivitySelection()
        var hostingController: UIHostingController<FamilyActivityPickerWrapper>!
        
        let pickerWrapper = FamilyActivityPickerWrapper(
          selection: selection,
          onComplete: { finalSelection in
            // Always save the selection, even if empty (user deselected all apps)
            self.saveAppSelection(finalSelection)
            
            // Update SharedPreferences status based on whether apps are selected
            let hasApps = !finalSelection.applicationTokens.isEmpty || !finalSelection.categoryTokens.isEmpty
            UserDefaults.standard.set(hasApps, forKey: "screen_time_apps_selected")
            UserDefaults.standard.synchronize()
            
            if hasApps {
              print("✅ Apps selected and saved: \(finalSelection.applicationTokens.count) apps, \(finalSelection.categoryTokens.count) categories")
            } else {
              print("✅ All apps deselected - selection cleared")
            }
            
            result(hasApps)
            hostingController.dismiss(animated: true)
          },
          onCancel: {
            result(false)
            hostingController.dismiss(animated: true)
          }
        )
        
        hostingController = UIHostingController(rootView: pickerWrapper)
        hostingController.modalPresentationStyle = .formSheet
        hostingController.isModalInPresentation = true
        controller.present(hostingController, animated: true)
      }
    }
  }
  
  @available(iOS 16.0, *)
  private func saveAppSelection(_ selection: FamilyActivitySelection) {
    do {
      let encoder = JSONEncoder()
      let appTokensData = try encoder.encode(selection.applicationTokens)
      let categoryTokensData = try encoder.encode(selection.categoryTokens)
      
      userDefaults.set(appTokensData, forKey: appsSelectedKey + "_apps")
      userDefaults.set(categoryTokensData, forKey: appsSelectedKey + "_categories")
      userDefaults.synchronize()
      
      print("💾 Saved app selection to UserDefaults")
    } catch {
      print("❌ Error saving app selection: \(error)")
    }
  }
  
  @available(iOS 16.0, *)
  private func loadAppSelection() -> FamilyActivitySelection? {
    guard let appTokensData = userDefaults.data(forKey: appsSelectedKey + "_apps"),
          let categoryTokensData = userDefaults.data(forKey: appsSelectedKey + "_categories") else {
      print("⚠️ No saved app selection found")
      return nil
    }
    
    do {
      let decoder = JSONDecoder()
      let appTokens = try decoder.decode(Set<ApplicationToken>.self, from: appTokensData)
      let categoryTokens = try decoder.decode(Set<ActivityCategoryToken>.self, from: categoryTokensData)
      
      var selection = FamilyActivitySelection()
      selection.applicationTokens = appTokens
      selection.categoryTokens = categoryTokens
      
      print("📂 Loaded app selection: \(appTokens.count) apps")
      return selection
    } catch {
      print("❌ Error loading app selection: \(error)")
      return nil
    }
  }
  
  @available(iOS 16.0, *)
  private func blockApps(result: @escaping FlutterResult) {
    print("🚫 Blocking apps...")
    
    guard let selection = loadAppSelection() else {
      print("❌ No apps selected to block")
      result(FlutterError(code: "NO_APPS_SELECTED", message: "No apps selected", details: nil))
      return
    }
    
    // Block selected apps using ManagedSettingsStore
    managedSettingsStore.shield.applications = selection.applicationTokens
    managedSettingsStore.shield.applicationCategories = .specific(selection.categoryTokens)
    
    print("✅ Apps blocked successfully")
    result(nil)
  }
  
  @available(iOS 16.0, *)
  private func unblockApps(result: @escaping FlutterResult) {
    print("🔓 Unblocking apps...")
    
    // Clear all shields
    managedSettingsStore.shield.applications = nil
    managedSettingsStore.shield.applicationCategories = nil
    
    print("✅ Apps unblocked successfully")
    result(nil)
  }
  
  @available(iOS 16.0, *)
  private func checkAppsSelected(result: @escaping FlutterResult) {
    guard let selection = loadAppSelection() else {
      result(false)
      return
    }
    
    let hasApps = !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
    print("📱 Checking apps selected: \(hasApps) (\(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories)")
    result(hasApps)
  }
}

// MARK: - FamilyActivityPicker Wrapper
@available(iOS 16.0, *)
private struct FamilyActivityPickerWrapper: View {
  @State private var selection: FamilyActivitySelection
  let onComplete: (FamilyActivitySelection) -> Void
  let onCancel: () -> Void
  
  init(selection: FamilyActivitySelection, onComplete: @escaping (FamilyActivitySelection) -> Void, onCancel: @escaping () -> Void) {
    _selection = State(initialValue: selection)
    self.onComplete = onComplete
    self.onCancel = onCancel
  }
  
  var body: some View {
    NavigationView {
      FamilyActivityPicker(selection: $selection)
        .navigationTitle("Select Apps to Block")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
              onCancel()
            }
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Done") {
              onComplete(selection)
            }
          }
        }
    }
  }
}

