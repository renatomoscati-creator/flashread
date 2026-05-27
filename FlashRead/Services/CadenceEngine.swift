//
//  CadenceEngine.swift
//  FlashRead
//
//  Smart cadence algorithm for natural reading rhythm.
//

import Foundation

class CadenceEngine {
    /// Returns the base interval in seconds for a given WPM.
    func baseInterval(forWPM wpm: Int) -> TimeInterval {
        // 60 seconds / WPM = seconds per word
        return 60.0 / Double(wpm)
    }
    
    /// Returns a multiplier adjustment for a word based on punctuation and length.
    /// Values > 1.0 mean the word should take longer (pause at punctuation).
    /// Values < 1.0 mean the word should be faster.
    func adjustment(forWord word: String) -> Double {
        var adjustment: Double = 1.0
        
        let trimmedWord = word.trimmingCharacters(in: .whitespaces)
        let lastChar = trimmedWord.last
        
        // Punctuation adjustments (add time)
        switch lastChar {
        case ",":
            adjustment += 0.15  // 15% longer
        case ".", "?", "!":
            adjustment += 0.30  // 30% longer
        case ";", ":":
            adjustment += 0.20  // 20% longer
        case "-":
            adjustment += 0.10  // 10% longer
        default:
            break
        }
        
        // Long word adjustment (slightly slower for comprehension)
        let cleanWord = trimmedWord.trimmingCharacters(in: .punctuationCharacters)
        if cleanWord.count > 12 {
            adjustment += 0.10
        } else if cleanWord.count > 8 {
            adjustment += 0.05
        }
        
        // Very short words can be slightly faster
        if cleanWord.count <= 2 && lastChar == nil {
            adjustment -= 0.05
        }
        
        return max(0.8, adjustment)  // Never go below 80% of base time
    }
    
    /// Returns adjustment for paragraph breaks.
    func adjustmentForParagraphBreak() -> Double {
        return 1.5  // 50% longer pause
    }
}
