//
//  TextTokenizer.swift
//  FlashRead
//
//  Tokenizes text into word sequence for RSVP display.
//

import Foundation

class TextTokenizer {
    /// Tokenizes text into an array of words, preserving order.
    /// Handles punctuation and markdown gracefully.
    func tokenize(_ text: String) -> [String] {
        // Split by whitespace and newlines, filter empty strings
        let components = text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .split(separator: " ", omittingEmptySubsequences: true)
        
        var words: [String] = []
        
        for component in components {
            let word = String(component).trimmingCharacters(in: .whitespacesAndNewlines)
            if !word.isEmpty {
                words.append(word)
            }
        }
        
        return words
    }
    
    /// Returns the current word with optimal focal point for RSVP.
    /// For longer words, returns the word with the optimal recognition point highlighted.
    func getWordWithFocus(_ word: String) -> (before: String, focus: String, after: String) {
        let cleanedWord = word.trimmingCharacters(in: .punctuationCharacters)
        
        guard cleanedWord.count > 1 else {
            return ("", word, "")
        }
        
        // Optimal recognition point is roughly at 1/3 into the word
        let focusIndex = max(1, cleanedWord.count / 3)
        
        let before = String(cleanedWord.prefix(focusIndex))
        let focus = String(cleanedWord[cleanedWord.index(cleanedWord.startIndex, offsetBy: focusIndex)])
        let after = String(cleanedWord[cleanedWord.index(cleanedWord.startIndex, offsetBy: focusIndex + 1)...])
        
        return (before, focus, after)
    }
}
