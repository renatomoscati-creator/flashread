//
//  SettingsWindowController.swift
//  FlashRead
//
//  Window controller for settings.
//

import SwiftUI
import AppKit

class SettingsWindowController: NSWindowController {
    private static var sharedController: SettingsWindowController?
    
    static func show(appState: AppState) {
        if sharedController == nil {
            sharedController = SettingsWindowController(appState: appState)
        }
        sharedController?.show()
    }
    
    init(appState: AppState) {
        let settingsView = SettingsView().environmentObject(appState)
        let hostingController = NSHostingController(rootView: settingsView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 350),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "FlashRead Settings"
        window.contentViewController = hostingController
        window.center()
        
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        window?.makeKeyAndOrderFront(nil)
        window?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
}
