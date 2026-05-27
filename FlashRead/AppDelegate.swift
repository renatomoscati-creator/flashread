//
//  AppDelegate.swift
//  FlashRead
//
//  Handles menu bar integration and app lifecycle.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var readerWindow: NSWindow?
    private var shortcutManager: ShortcutManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        shortcutManager = ShortcutManager.shared
        checkFirstLaunch()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "hare.fill", accessibilityDescription: "FlashRead")
            button.action = #selector(statusItemClicked)
            button.target = self
        }
        
        statusItem?.menu = buildMenu()
    }
    
    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open FlashRead", action: #selector(menuOpenFlashRead), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Paste / Import Text", action: #selector(menuOpenImport), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Resume Last Session", action: #selector(menuResumeSession), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(menuOpenSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit FlashRead", action: #selector(quitApp), keyEquivalent: "q"))
        return menu
    }
    
    @objc private func menuOpenFlashRead() { openFlashRead() }
    @objc private func menuOpenImport() { openImport() }
    @objc private func menuResumeSession() { resumeSession() }
    @objc private func menuOpenSettings() { openSettings() }
    
    @objc private func statusItemClicked() {
        if let window = readerWindow, window.isVisible {
            window.orderOut(nil)
        } else {
            showReaderWithText(fromClipboard: true)
        }
    }
    
    func openFlashRead() {
        showReaderWithText(fromClipboard: true)
    }
    
    func openImport() {
        showImportView()
    }
    
    func resumeSession() {
        guard AppState.shared.persistSession,
              let savedText = UserDefaults.standard.string(forKey: "savedSessionText"),
              let savedWords = UserDefaults.standard.array(forKey: "savedSessionWords") as? [String],
              !savedWords.isEmpty else {
            showReaderWithText(fromClipboard: true)
            return
        }
        
        AppState.shared.loadedText = savedText
        AppState.shared.words = savedWords
        AppState.shared.currentWordIndex = UserDefaults.standard.integer(forKey: "savedSessionIndex")
        AppState.shared.wpm = UserDefaults.standard.integer(forKey: "savedSessionWPM")
        AppState.shared.currentView = .reader
        showReaderWindow()
    }
    
    func openSettings() {
        SettingsWindowController.show(appState: AppState.shared)
    }
    
    @objc private func quitApp() {
        saveWindowPosition()
        AppState.shared.saveSession()
        NSApp.terminate(nil)
    }
    
    // MARK: - Window Management
    
    private func showReaderWithText(fromClipboard: Bool) {
        if fromClipboard {
            if let clipboardText = ClipboardService.shared.getText(),
               !clipboardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                AppState.shared.loadedText = clipboardText
                AppState.shared.tokenizeText()
                AppState.shared.currentView = .reader
            } else {
                AppState.shared.currentView = .import
                showReaderWindow()
                return
            }
        } else {
            AppState.shared.currentView = .reader
        }
        
        showReaderWindow()
    }
    
    private func showImportView() {
        AppState.shared.currentView = .import
        showReaderWindow()
    }
    
    private func showReaderWindow() {
        // Create window once with a RootView that switches content internally
        if readerWindow == nil {
            readerWindow = createWindow()
        }
        
        guard let window = readerWindow else { return }
        
        restoreWindowPosition(window)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func createWindow() -> NSWindow {
        let rootView = RootView().environmentObject(AppState.shared)
        let hostingController = NSHostingController(rootView: rootView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 360),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "FlashRead"
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.backgroundColor = NSColor.windowBackgroundColor
        window.hasShadow = true
        window.center()
        window.contentViewController = hostingController
        return window
    }
    
    private func restoreWindowPosition(_ window: NSWindow) {
        guard AppState.shared.rememberWindowPosition else {
            window.center()
            return
        }
        
        let savedX = UserDefaults.standard.double(forKey: "windowPositionX")
        let savedY = UserDefaults.standard.double(forKey: "windowPositionY")
        
        if savedX != 0 || savedY != 0 {
            window.setFrameOrigin(NSPoint(x: savedX, y: savedY))
        } else {
            window.center()
        }
    }
    
    private func saveWindowPosition() {
        guard let window = readerWindow else { return }
        let origin = window.frame.origin
        UserDefaults.standard.set(origin.x, forKey: "windowPositionX")
        UserDefaults.standard.set(origin.y, forKey: "windowPositionY")
    }
    
    private func checkFirstLaunch() {
        let hasLaunched = UserDefaults.standard.bool(forKey: "hasLaunched")
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: "hasLaunched")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let alert = NSAlert()
                alert.messageText = "Welcome to FlashRead!"
                alert.informativeText = "Click the rabbit icon or press Option-Command-R to start reading."
                alert.addButton(withTitle: "Got it")
                alert.runModal()
            }
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
