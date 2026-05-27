//
//  ClipboardService.swift
//  FlashRead
//
//  Handles clipboard text ingestion.
//

import AppKit

class ClipboardService {
    static let shared = ClipboardService()
    
    private init() {}
    
    func getText() -> String? {
        guard let pasteboard = NSPasteboard.general.string(forType: .string) else {
            return nil
        }
        return pasteboard
    }
    
    func hasValidText() -> Bool {
        return getText()?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}
