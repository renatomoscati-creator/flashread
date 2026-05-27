//
//  SettingsView.swift
//  FlashRead
//
//  Settings screen for shortcut and toggles.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.headline)
            
            Divider()
            
            Form {
                Section("Keyboard Shortcut") {
                    HStack {
                        Text("Global Shortcut:")
                        Spacer()
                        Text(appState.globalShortcut)
                            .font(.system(.body, design: .monospaced))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(4)
                    }
                }
                
                Section("Persistence") {
                    Toggle("Persist last session", isOn: $appState.persistSession)
                        .help("Save your reading progress and resume when you reopen the app")
                    
                    Toggle("Remember window position", isOn: $appState.rememberWindowPosition)
                        .help("Open the reader panel at the last used position")
                }
                
                Section("Reading") {
                    HStack {
                        Text("Default Speed:")
                        Slider(value: Binding(
                            get: { Double(self.appState.wpm) },
                            set: { self.appState.wpm = Int($0) }
                        ), in: 120...900, step: 10)
                        Text("\(appState.wpm) WPM")
                            .frame(width: 60)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version:")
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 350)
            
            Divider()
            
            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
        }
        .padding(20)
        .onChange(of: appState.persistSession) { _ in
            appState.saveSettings()
        }
        .onChange(of: appState.rememberWindowPosition) { _ in
            appState.saveSettings()
        }
    }
}
