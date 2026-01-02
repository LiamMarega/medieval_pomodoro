//
//  FocusKnightWidgetLiveActivity.swift
//  FocusKnightWidgetExtension
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes
public struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState
    
    public struct ContentState: Codable, Hashable {
        public var paused: Bool = false
        public var timeRemaining: Int = 1500
        public var sessionType: String = "Focus"
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

// MARK: - Extension for prefixed keys
extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
}

// MARK: - Shared UserDefaults
// Safely unwrap UserDefaults with fallback to standard UserDefaults
// This prevents crashes if app groups aren't properly configured
let sharedDefault: UserDefaults = {
    if let shared = UserDefaults(suiteName: "group.com.focusknight.app") {
        return shared
    } else {
        // Fallback to standard UserDefaults if app group isn't available
        // This ensures the widget extension doesn't crash
        return UserDefaults.standard
    }
}()

// MARK: - Medieval Live Activity Widget
@available(iOS 16.1, *)
struct FocusKnightLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            // Lock Screen / Banner
            MedievalLockScreenView(context: context)
                .activityBackgroundTint(Color(red: 0.18, green: 0.11, blue: 0.07))
                .activitySystemActionForegroundColor(Color(red: 0.83, green: 0.63, blue: 0.09))
            
        } dynamicIsland: { context in
            DynamicIsland {
                // EXPANDED
                DynamicIslandExpandedRegion(.leading) {
                    let userName = sharedDefault.string(forKey: context.attributes.prefixedKey("name")) ?? "Knight"
                    
                    HStack(spacing: 8) {
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
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatTime(context.state.timeRemaining))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .monospacedDigit()
                        
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
                
                DynamicIslandExpandedRegion(.bottom) {
                    // Controls Row
                    HStack(spacing: 30) {
                        // Pause/Resume Button
                        Link(destination: URL(string: "focusknight://\(context.state.paused ? "resume" : "pause")")!) {
                            Label(context.state.paused ? "Resume" : "Pause", systemImage: context.state.paused ? "play.fill" : "pause.fill")
                                .font(.caption)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color(red: 0.83, green: 0.63, blue: 0.09).opacity(0.2))
                                .cornerRadius(20)
                                .foregroundColor(Color(red: 0.83, green: 0.63, blue: 0.09))
                        }
                        
                        // Skip Button
                        Link(destination: URL(string: "focusknight://skip")!) {
                            Label("Skip", systemImage: "forward.fill")
                                .font(.caption)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color(red: 0.83, green: 0.63, blue: 0.09).opacity(0.2))
                                .cornerRadius(20)
                                .foregroundColor(Color(red: 0.83, green: 0.63, blue: 0.09))
                        }
                    }
                    .padding(.top, 8)
                }
                
            } compactLeading: {
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
                Text(formatTimeCompact(context.state.timeRemaining))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(context.state.paused ? .orange : Color(red: 0.83, green: 0.63, blue: 0.09))
                    .monospacedDigit()
            } minimal: {
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
        let userName = sharedDefault.string(forKey: context.attributes.prefixedKey("name")) ?? "Knight"
        let quantity = sharedDefault.integer(forKey: context.attributes.prefixedKey("quantity"))
        
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Left side: Avatar y session info
                HStack(spacing: 12) {
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
                        
                        Text("\(context.state.sessionType) Session \(context.state.currentSession)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Right side: Timer
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatTime(context.state.timeRemaining))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.96, green: 0.90, blue: 0.83))
                        .monospacedDigit()
                }
            }
            .padding(.bottom, 12)
            
            // Controls Row (New)
            HStack(spacing: 40) {
                Spacer()
                
                // Pause/Resume
                Link(destination: URL(string: "focusknight://\(context.state.paused ? "resume" : "pause")")!) {
                    Image(systemName: context.state.paused ? "play.fill" : "pause.fill")
                        .font(.title2)
                        .foregroundColor(Color(red: 0.83, green: 0.63, blue: 0.09))
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                
                // Skip
                Link(destination: URL(string: "focusknight://skip")!) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .foregroundColor(Color(red: 0.83, green: 0.63, blue: 0.09))
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(red: 0.18, green: 0.11, blue: 0.07))
    }
    
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
