//
//  FullTextView.swift
//  FlashRead
//
//  Full text view with click-to-jump functionality.
//

import SwiftUI

struct FullTextView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var scrollTarget: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Full Text")
                    .font(.headline)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Text content
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        fullTextWithWords
                    }
                    .padding()
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
    
    private var fullTextWithWords: some View {
        Group {
            if let text = appState.loadedText {
                let words = text.split(separator: " ", omittingEmptySubsequences: true)
                
                ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                    Text(String(word))
                        .font(.system(size: 14))
                        .foregroundColor(index == appState.currentWordIndex ? .white : .primary)
                        .padding(2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(index == appState.currentWordIndex ? Color.green.opacity(0.3) : Color.clear)
                        )
                        .onTapGesture {
                            jumpToWord(at: index)
                        }
                }
            }
        }
    }
    
    private func jumpToWord(at index: Int) {
        guard index < appState.words.count else { return }
        
        appState.currentWordIndex = index
        appState.isPaused = true
        appState.isReading = false
        
        // Close the full text view and return to reader
        dismiss()
    }
}
