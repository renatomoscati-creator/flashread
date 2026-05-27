//
//  FlashReadApp.swift
//  FlashRead
//
//  A native macOS menu bar RSVP speed-reading utility.
//

import SwiftUI

@main
struct FlashReadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        // No scenes - we're a pure menu bar app
        // Settings are handled via SettingsWindowController
    }
}
