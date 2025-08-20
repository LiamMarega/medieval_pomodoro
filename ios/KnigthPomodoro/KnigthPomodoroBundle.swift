//
//  KnigthPomodoroBundle.swift
//  KnigthPomodoro
//
//  Created by Liam on 19/08/2025.
//

import WidgetKit
import SwiftUI

@main
struct KnigthPomodoroBundle: WidgetBundle {
    var body: some Widget {
        KnigthPomodoro()
        KnigthPomodoroControl()
        KnigthPomodoroLiveActivity()
    }
}
