//
//  FocusKnightWidgetLiveActivity.swift
//  FocusKnightWidget
//
//  Created by Liam on 22/08/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FocusKnightWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FocusKnightWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusKnightWidgetAttributes.self) { context in
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

extension FocusKnightWidgetAttributes {
    fileprivate static var preview: FocusKnightWidgetAttributes {
        FocusKnightWidgetAttributes(name: "World")
    }
}

extension FocusKnightWidgetAttributes.ContentState {
    fileprivate static var smiley: FocusKnightWidgetAttributes.ContentState {
        FocusKnightWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FocusKnightWidgetAttributes.ContentState {
         FocusKnightWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FocusKnightWidgetAttributes.preview) {
   FocusKnightWidgetLiveActivity()
} contentStates: {
    FocusKnightWidgetAttributes.ContentState.smiley
    FocusKnightWidgetAttributes.ContentState.starEyes
}
