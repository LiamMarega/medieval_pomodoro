//
//  FocusKnightWidgetLiveActivity.swift
//  FocusKnightWidgetExtension
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes (must match the one in LiveActivityManager.swift)
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

// MARK: - Medieval Live Activity Widget

@available(iOS 16.1, *)
struct FocusKnightLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            // Lock Screen / Banner: Medieval Knight Timer
            MedievalLockScreenView(context: context)
                .activityBackgroundTint(Color(red: 0.18, green: 0.11, blue: 0.07)) // Deep brown
                .activitySystemActionForegroundColor(Color(red: 0.83, green: 0.63, blue: 0.09)) // Gold
            
        } dynamicIsland: { context in
            DynamicIsland {
                // EXPANDED: Full medieval timer display
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Text("⚔️")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.sessionType)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.83, green: 0.63, blue: 0.09))
                            Text("Session \(context.state.currentSession)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formatTime(context.state.timeRemaining))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text(context.state.paused ? "⏸️ Paused" : "⏱️ Active")
                            .font(.caption2)
                            .foregroundColor(context.state.paused ? .orange : .green)
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    // Progress bar
                    let totalTime = getTotalTimeForSession(context.state.sessionType)
                    let progress = Double(totalTime - context.state.timeRemaining) / Double(totalTime)
                    
                    VStack(spacing: 4) {
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.83, green: 0.63, blue: 0.09)))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                        
                        Text("\(Int(progress * 100))% Complete")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                
            } compactLeading: {
                // Compact leading: Knight icon with session indicator
                ZStack {
                    Circle()
                        .fill(Color(red: 0.18, green: 0.11, blue: 0.07))
                        .frame(width: 20, height: 20)
                    Text("⚔️")
                        .font(.caption)
                }
            } compactTrailing: {
                // Compact trailing: Time remaining
                Text(formatTimeCompact(context.state.timeRemaining))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(context.state.paused ? .orange : Color(red: 0.83, green: 0.63, blue: 0.09))
            } minimal: {
                // Minimal: Just the knight icon with status color
                ZStack {
                    Circle()
                        .fill(context.state.paused ? .orange : Color(red: 0.83, green: 0.63, blue: 0.09))
                        .frame(width: 16, height: 16)
                    Text("⚔️")
                        .font(.system(size: 10))
                }
            }
            .keylineTint(Color(red: 0.83, green: 0.63, blue: 0.09))
        }
    }
    
    // Helper function to format time
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    // Helper function to format time for compact view
    private func formatTimeCompact(_ seconds: Int) -> String {
        let minutes = seconds / 60
        return "\(minutes)m"
    }
    
    // Helper function to get total time for session type
    private func getTotalTimeForSession(_ sessionType: String) -> Int {
        switch sessionType {
        case "Focus":
            return 1500 // 25 minutes
        case "Break":
            return 300  // 5 minutes
        case "Long Break":
            return 900  // 15 minutes
        default:
            return 1500
        }
    }
}

// MARK: - Medieval Lock Screen View
@available(iOS 16.1, *)
struct MedievalLockScreenView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side: Knight icon and session info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("⚔️")
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Focus Knight")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.96, green: 0.90, blue: 0.83)) // Warm off-white
                        Text("\(context.state.sessionType) Session \(context.state.currentSession)")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.83, green: 0.63, blue: 0.09)) // Gold
                    }
                }
                
                // Status indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(context.state.paused ? .orange : .green)
                        .frame(width: 8, height: 8)
                    Text(context.state.paused ? "Paused" : "In Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Right side: Timer and progress
            VStack(alignment: .trailing, spacing: 8) {
                // Time display
                Text(formatTime(context.state.timeRemaining))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.96, green: 0.90, blue: 0.83)) // Warm off-white
                    .monospacedDigit()
                
                // Progress indicator
                let totalTime = getTotalTimeForSession(context.state.sessionType)
                let progress = Double(totalTime - context.state.timeRemaining) / Double(totalTime)
                
                VStack(alignment: .trailing, spacing: 4) {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.83, green: 0.63, blue: 0.09)))
                        .frame(width: 100)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                    
                    Text("\(Int(progress * 100))% Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.29, green: 0.17, blue: 0.11), // Medium brown
                            Color(red: 0.23, green: 0.14, blue: 0.09)  // Darker brown
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.83, green: 0.63, blue: 0.09).opacity(0.3), // Gold border
                                    Color(red: 0.42, green: 0.26, blue: 0.14).opacity(0.5)  // Brown border
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // Helper functions (same as in main widget)
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func getTotalTimeForSession(_ sessionType: String) -> Int {
        switch sessionType {
        case "Focus":
            return 1500 // 25 minutes
        case "Break":
            return 300  // 5 minutes
        case "Long Break":
            return 900  // 15 minutes
        default:
            return 1500
        }
    }
}

@available(iOS 16.1, *)
#Preview("Live", as: .content, using: LiveActivitiesAppAttributes()) {
    FocusKnightLiveActivity()
} contentStates: {
    LiveActivitiesAppAttributes.ContentState(paused: false, timeRemaining: 900, sessionType: "Focus", currentSession: 2)
    LiveActivitiesAppAttributes.ContentState(paused: true, timeRemaining: 300, sessionType: "Break", currentSession: 1)
}
