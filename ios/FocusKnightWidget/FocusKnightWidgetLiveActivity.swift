//
//  FocusKnightWidgetLiveActivity.swift
//  FocusKnightWidgetExtension
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes (DEBE llamarse EXACTAMENTE LiveActivitiesAppAttributes)
public struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState // OBLIGATORIO para que funcione
    
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

// MARK: - Extension for prefixed keys (OBLIGATORIO)
extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
}

// MARK: - Shared UserDefaults
let sharedDefault = UserDefaults(suiteName: "group.com.focusknight.app")!

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
                    // Obtener datos desde Flutter
                    let userName = sharedDefault.string(forKey: context.attributes.prefixedKey("name")) ?? "Knight"
                    let ingredient = sharedDefault.string(forKey: context.attributes.prefixedKey("ingredient")) ?? ""
                    
                    HStack(spacing: 8) {
                        // Avatar círculo con iniciales
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.83, green: 0.63, blue: 0.09))
                                .frame(width: 32, height: 32)
                            Text(getInitials(from: userName))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(userName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            
                            Text(context.state.sessionType)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0.83, green: 0.63, blue: 0.09))
                            
                            Text("Session \(context.state.currentSession)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        // Tiempo restante
                        Text(formatTime(context.state.timeRemaining))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .monospacedDigit()
                        
                        // Estado
                        HStack(spacing: 4) {
                            Circle()
                                .fill(context.state.paused ? .orange : .green)
                                .frame(width: 6, height: 6)
                            
                            Text(context.state.paused ? "Paused" : "Active")
                                .font(.caption2)
                                .foregroundColor(context.state.paused ? .orange : .green)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    // Progress bar
                    let totalTime = getTotalTimeForSession(context.state.sessionType)
                    let progress = Double(totalTime - context.state.timeRemaining) / Double(totalTime)
                    
                    VStack(spacing: 6) {
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.83, green: 0.63, blue: 0.09)))
                            .scaleEffect(x: 1, y: 2.5, anchor: .center)
                        
                        Text("\(Int(progress * 100))% Complete")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                }
                
            } compactLeading: {
                // Compact leading: Avatar con iniciales del usuario
                let userName = sharedDefault.string(forKey: context.attributes.prefixedKey("name")) ?? "Knight"
                
                ZStack {
                    Circle()
                        .fill(context.state.paused ? .orange : Color(red: 0.83, green: 0.63, blue: 0.09))
                        .frame(width: 20, height: 20)
                    
                    Text(getInitials(from: userName))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                }
                
            } compactTrailing: {
                // Compact trailing: Time remaining
                Text(formatTimeCompact(context.state.timeRemaining))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(context.state.paused ? .orange : Color(red: 0.83, green: 0.63, blue: 0.09))
                    .monospacedDigit()
                    
            } minimal: {
                // Minimal: Solo las iniciales con color de estado
                let userName = sharedDefault.string(forKey: context.attributes.prefixedKey("name")) ?? "Knight"
                
                ZStack {
                    Circle()
                        .fill(context.state.paused ? .orange : Color(red: 0.83, green: 0.63, blue: 0.09))
                        .frame(width: 16, height: 16)
                    
                    Text(getInitials(from: userName))
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .keylineTint(Color(red: 0.83, green: 0.63, blue: 0.09))
        }
    }
    
    // MARK: - Helper Functions
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func formatTimeCompact(_ seconds: Int) -> String {
        let minutes = seconds / 60
        if minutes > 60 {
            let hours = minutes / 60
            return "\(hours)h"
        }
        return "\(minutes)m"
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
    
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }
}

// MARK: - Medieval Lock Screen View
@available(iOS 16.1, *)
struct MedievalLockScreenView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    
    var body: some View {
        // Obtener datos desde Flutter
        let userName = sharedDefault.string(forKey: context.attributes.prefixedKey("name")) ?? "Knight"
        let ingredient = sharedDefault.string(forKey: context.attributes.prefixedKey("ingredient")) ?? ""
        let quantity = sharedDefault.integer(forKey: context.attributes.prefixedKey("quantity"))
        
        HStack(spacing: 16) {
            // Left side: Avatar y session info
            HStack(spacing: 12) {
                // Avatar grande para lock screen
                ZStack {
                    Circle()
                        .fill(Color(red: 0.83, green: 0.63, blue: 0.09))
                        .frame(width: 40, height: 40)
                    
                    Text(getInitials(from: userName))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Focus Knight")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.96, green: 0.90, blue: 0.83))
                    
                    Text(userName)
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.83, green: 0.63, blue: 0.09))
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Text("\(context.state.sessionType) Session \(context.state.currentSession)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if quantity > 1 {
                            Text("× \(quantity)")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.83, green: 0.63, blue: 0.09))
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Right side: Timer and progress
            VStack(alignment: .trailing, spacing: 8) {
                // Time display
                Text(formatTime(context.state.timeRemaining))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.96, green: 0.90, blue: 0.83))
                    .monospacedDigit()
                
                // Status indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(context.state.paused ? .orange : .green)
                        .frame(width: 8, height: 8)
                    
                    Text(context.state.paused ? "Paused" : "In Progress")
                        .font(.caption)
                        .foregroundColor(context.state.paused ? .orange : .green)
                        .fontWeight(.medium)
                }
                
                // Progress indicator
                let totalTime = getTotalTimeForSession(context.state.sessionType)
                let progress = Double(totalTime - context.state.timeRemaining) / Double(totalTime)
                
                VStack(alignment: .trailing, spacing: 4) {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.83, green: 0.63, blue: 0.09)))
                        .frame(width: 120)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                    
                    Text("\(Int(progress * 100))% Complete")
                        .font(.caption2)
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
                            Color(red: 0.29, green: 0.17, blue: 0.11),
                            Color(red: 0.23, green: 0.14, blue: 0.09)
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
                                    Color(red: 0.83, green: 0.63, blue: 0.09).opacity(0.3),
                                    Color(red: 0.42, green: 0.26, blue: 0.14).opacity(0.5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // Helper functions específicas para MedievalLockScreenView
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func getTotalTimeForSession(_ sessionType: String) -> Int {
        switch sessionType {
        case "Focus":
            return 1500
        case "Break":
            return 300
        case "Long Break":
            return 900
        default:
            return 1500
        }
    }
}

// MARK: - Previews
@available(iOS 16.1, *)
#Preview("Live", as: .content, using: LiveActivitiesAppAttributes()) {
    FocusKnightLiveActivity()
} contentStates: {
    LiveActivitiesAppAttributes.ContentState(
        paused: false, 
        timeRemaining: 900, 
        sessionType: "Focus", 
        currentSession: 2
    )
    LiveActivitiesAppAttributes.ContentState(
        paused: true, 
        timeRemaining: 300, 
        sessionType: "Break", 
        currentSession: 1
    )
}
