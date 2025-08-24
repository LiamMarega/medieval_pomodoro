import UIKit
import Flutter
import ActivityKit

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
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
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
}
