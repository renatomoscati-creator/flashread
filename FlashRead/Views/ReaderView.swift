//
//  ReaderView.swift
//  FlashRead
//
//  Main RSVP reading panel.
//

import SwiftUI

struct ReaderView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ReaderViewModel()
    @State private var showingFullText = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with WPM
            HStack {
                Text("\(appState.wpm) WPM")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: { showingFullText = true }) {
                    Image(systemName: "text.alignleft")
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            
            // Word display area
            ZStack {
                if viewModel.currentWord.focus.isEmpty {
                    Text("Ready")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.secondary)
                } else {
                    HStack(spacing: 0) {
                        Text(viewModel.currentWord.before)
                            .font(.system(size: 32, weight: .regular, design: .monospaced))
                            .foregroundColor(.primary)

                        Text(viewModel.currentWord.focus)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)

                        Text(viewModel.currentWord.after)
                            .font(.system(size: 32, weight: .regular, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                }
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    )
            )
            
            // Progress
            ProgressView(value: Double(viewModel.currentIndex), total: Double(viewModel.totalWords))
                .progressViewStyle(.linear)
                .tint(.green)
            
            // Controls
            HStack(spacing: 20) {
                if appState.isPaused {
                    Button(action: viewModel.start) {
                        Label("Start", systemImage: "play.fill")
                    }
                    .keyboardShortcut(.space, modifiers: [])
                } else {
                    Button(action: viewModel.togglePause) {
                        Label("Pause", systemImage: "pause.fill")
                    }
                    .keyboardShortcut(.space, modifiers: [])
                }
                
                Button(action: viewModel.stepBackward) {
                    Image(systemName: "arrow.left")
                }
                .keyboardShortcut(.leftArrow, modifiers: [])
                
                Button(action: viewModel.stepForward) {
                    Image(systemName: "arrow.right")
                }
                .keyboardShortcut(.rightArrow, modifiers: [])
            }
            .buttonStyle(.bordered)
            
            // WPM Slider
            VStack(spacing: 8) {
                HStack {
                    Text("Speed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(viewModel.speedZone)
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Slider(value: $viewModel.wpmSlider, in: 120...900, step: viewModel.sliderStep)
                    .tint(.green)
            }
        }
        .padding(20)
        .frame(width: 400, height: 320)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
        )
        .sheet(isPresented: $showingFullText) {
            FullTextView()
                .environmentObject(appState)
        }
        .onAppear {
            viewModel.startObserving()
        }
        .onDisappear {
            viewModel.stopObserving()
            appState.saveSession()
        }
    }
}
