//
//  RootView.swift
//  FlashRead
//
//  Single root view that switches between reader/import/empty views.
//  This prevents crashes from replacing window content.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            switch appState.currentView {
            case .reader:
                ReaderView()
            case .import:
                ImportView()
            case .settings:
                SettingsView()
            case .none:
                EmptyView()
            }
        }
        .environmentObject(appState)
    }
}
