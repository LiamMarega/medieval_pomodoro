//
//  KnigthPomodoroLiveActivity.swift
//  KnigthPomodoro
//
//  Created by Liam on 19/08/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct KnigthPomodoroAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct KnigthPomodoroLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: KnigthPomodoroAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension KnigthPomodoroAttributes {
    fileprivate static var preview: KnigthPomodoroAttributes {
        KnigthPomodoroAttributes(name: "World")
    }
}

extension KnigthPomodoroAttributes.ContentState {
    fileprivate static var smiley: KnigthPomodoroAttributes.ContentState {
        KnigthPomodoroAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: KnigthPomodoroAttributes.ContentState {
         KnigthPomodoroAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: KnigthPomodoroAttributes.preview) {
   KnigthPomodoroLiveActivity()
} contentStates: {
    KnigthPomodoroAttributes.ContentState.smiley
    KnigthPomodoroAttributes.ContentState.starEyes
}
