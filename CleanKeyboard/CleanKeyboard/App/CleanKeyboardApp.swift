//
//  CleanKeyboardApp.swift
//  CleanKeyboard
//
//  Created by Hao Nguyen on 17/04/2026.
//

import SwiftUI

@main
struct CleanKeyboardApp: App {
    @StateObject private var lockManager = KeyboardLockManager()
    @StateObject private var localization = LocalizationManager()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(lockManager)
                .environmentObject(localization)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
