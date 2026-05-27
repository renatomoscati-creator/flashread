//
//  ShortcutSetupView.swift
//  FlashRead
//
//  First-launch shortcut setup wizard.
//

import SwiftUI

struct ShortcutSetupView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hare.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            
            Text("Welcome to FlashRead")
                .font(.title)
            
            Text("Set up your global shortcut to start reading from anywhere.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text("Current Shortcut:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(appState.globalShortcut)
                    .font(.system(.title, design: .monospaced))
                    .padding()
                    .frame(minWidth: 200)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
            }
            
            HStack(spacing: 16) {
                Button("Skip") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Button("Done") {
                    appState.saveSettings()
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding(30)
        .frame(width: 400, height: 350)
    }
}
