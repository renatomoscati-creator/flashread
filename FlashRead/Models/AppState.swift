//
//  AppState.swift
//  FlashRead
//
//  Centralized app state management.
//

import Foundation
import Combine

class AppState: ObservableObject {
    static let shared = AppState()
    
    private let queue = DispatchQueue(label: "com.flashread.appstate", attributes: .concurrent)
    
    // MARK: - Published Properties
    
    @Published var currentView: AppView = .none
    @Published var loadedText: String?
    @Published var showShortcutSetup: Bool = false
    
    // MARK: - Reader State
    
    @Published var isReading: Bool = false
    @Published var isPaused: Bool = true
    @Published var currentWordIndex: Int = 0
    @Published var words: [String] = []
    @Published var wpm: Int = 260
    
    // MARK: - Settings
    
    @Published var persistSession: Bool = true
    @Published var rememberWindowPosition: Bool = true
    @Published var globalShortcut: String = "⌥⌘R"
    
    // MARK: - Initialization
    
    private init() {
        loadSettings()
    }
    
    // MARK: - Text Processing
    
    func tokenizeText() {
        guard let text = loadedText else {
            words = []
            return
        }
        
        let tokenizer = TextTokenizer()
        words = tokenizer.tokenize(text)
        currentWordIndex = 0
    }
    
    func loadText(_ text: String) {
        loadedText = text
        tokenizeText()
        // Defer view switch to next runloop to avoid tearing down ImportView mid-event
        DispatchQueue.main.async {
            self.currentView = .reader
        }
    }
    
    // MARK: - Settings Persistence
    
    func loadSettings() {
        persistSession = UserDefaults.standard.object(forKey: "persistSession") != nil
            ? UserDefaults.standard.bool(forKey: "persistSession")
            : true
        
        rememberWindowPosition = UserDefaults.standard.object(forKey: "rememberWindowPosition") != nil
            ? UserDefaults.standard.bool(forKey: "rememberWindowPosition")
            : true
        
        if let savedShortcut = UserDefaults.standard.string(forKey: "globalShortcut") {
            globalShortcut = savedShortcut
        }
        
        if let savedWPM = UserDefaults.standard.object(forKey: "wpm") as? Int {
            wpm = savedWPM
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(persistSession, forKey: "persistSession")
        UserDefaults.standard.set(rememberWindowPosition, forKey: "rememberWindowPosition")
        UserDefaults.standard.set(globalShortcut, forKey: "globalShortcut")
        UserDefaults.standard.set(wpm, forKey: "wpm")
    }
    
    // MARK: - Session Persistence
    
    func saveSession() {
        guard persistSession else { return }
        
        UserDefaults.standard.set(loadedText, forKey: "savedSessionText")
        UserDefaults.standard.set(words, forKey: "savedSessionWords")
        UserDefaults.standard.set(currentWordIndex, forKey: "savedSessionIndex")
        UserDefaults.standard.set(wpm, forKey: "savedSessionWPM")
    }
    
    func clearSession() {
        UserDefaults.standard.removeObject(forKey: "savedSessionText")
        UserDefaults.standard.removeObject(forKey: "savedSessionWords")
        UserDefaults.standard.removeObject(forKey: "savedSessionIndex")
        UserDefaults.standard.removeObject(forKey: "savedSessionWPM")
    }
}

// MARK: - AppView Enum

enum AppView {
    case none
    case reader
    case `import`
    case settings
}
