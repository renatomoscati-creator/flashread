//
//  ImportView.swift
//  FlashRead
//
//  View for manual paste, drag-and-drop, and file import.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    @StateObject private var viewModel = ImportViewModel()
    @EnvironmentObject var appState: AppState
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Import Text")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Paste area
            TextEditor(text: $viewModel.pasteText)
                .frame(minHeight: 150)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .onDrop(of: [.plainText, .text, .fileURL], isTargeted: $isDragging) { providers in
                    handleDrop(providers: providers)
                    return true
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isDragging ? Color.green.opacity(0.1) : Color.clear)
                )
            
            HStack(spacing: 12) {
                Button(action: viewModel.pasteFromClipboard) {
                    Label("Paste", systemImage: "doc.on.clipboard")
                }
                
                Button(action: viewModel.importFile) {
                    Label("Import File", systemImage: "doc.badge.plus")
                }
            }
            .buttonStyle(.bordered)
            
            // File type info
            Text("Supported: .txt, .md")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    appState.currentView = .none
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Button(action: loadText) {
                    Text("Start Reading")
                }
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(viewModel.pasteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 400, height: 350)
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, error in
                    if let data = item as? Data, let text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            viewModel.pasteText = text
                        }
                    }
                }
                return
            } else if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                    if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            viewModel.loadFile(at: url)
                        }
                    }
                }
                return
            }
        }
    }
    
    private func loadText() {
        let text = viewModel.pasteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        appState.loadText(text)
    }
}
