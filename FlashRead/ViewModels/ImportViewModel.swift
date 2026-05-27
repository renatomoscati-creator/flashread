//
//  ImportViewModel.swift
//  FlashRead
//
//  ViewModel for import view.
//

import Foundation
import SwiftUI

class ImportViewModel: ObservableObject {
    @Published var pasteText: String = ""
    
    func pasteFromClipboard() {
        if let clipboardText = ClipboardService.shared.getText() {
            pasteText = clipboardText
        }
    }
    
    func importFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText, .text]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.message = "Select a text file to import"
        panel.prompt = "Import"

        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            DispatchQueue.main.async {
                self?.loadFile(at: url)
            }
        }
    }
    
    func loadFile(at url: URL) {
        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            pasteText = text
        } catch {
            print("Failed to load file: \(error.localizedDescription)")
        }
    }
}
