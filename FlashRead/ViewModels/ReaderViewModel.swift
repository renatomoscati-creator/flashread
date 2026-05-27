//
//  ReaderViewModel.swift
//  FlashRead
//
//  ViewModel for reader with smart cadence and playback control.
//

import Foundation
import Combine

class ReaderViewModel: ObservableObject {
    @Published var currentWord: (before: String, focus: String, after: String) = ("", "", "")
    @Published var currentIndex: Int = 0
    @Published var totalWords: Int = 0
    @Published var wpmSlider: Double = 260
    @Published var speedZone: String = "Comfort"

    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var isRunning: Bool = false
    private var accumulatedTime: TimeInterval = 0

    private let tokenizer = TextTokenizer()
    private let cadenceEngine = CadenceEngine()
    
    deinit {
        stopObserving()
    }
    
    func startObserving() {
        // Initialize from app state
        totalWords = AppState.shared.words.count
        currentIndex = AppState.shared.currentWordIndex
        wpmSlider = Double(AppState.shared.wpm)
        
        updateWordDisplay()
        updateSpeedZone()
        
        // Observe WPM slider changes
        $wpmSlider
            .sink { [weak self] newValue in
                AppState.shared.wpm = Int(newValue)
                self?.updateSpeedZone()
            }
            .store(in: &cancellables)
    }
    
    func stopObserving() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        accumulatedTime = 0
    }
    
    func start() {
        guard !isRunning else { return }
        
        AppState.shared.isPaused = false
        AppState.shared.isReading = true
        isRunning = true
        accumulatedTime = 0
        
        startTimer()
    }
    
    func togglePause() {
        if AppState.shared.isPaused {
            start()
        } else {
            pause()
        }
    }
    
    func pause() {
        AppState.shared.isPaused = true
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func stepBackward() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        AppState.shared.currentWordIndex = currentIndex
        updateWordDisplay()
    }
    
    func stepForward() {
        guard currentIndex < totalWords - 1 else { return }
        currentIndex += 1
        AppState.shared.currentWordIndex = currentIndex
        updateWordDisplay()
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        guard isRunning else { return }

        let baseInterval = cadenceEngine.baseInterval(forWPM: Int(wpmSlider))
        accumulatedTime += 0.05

        if accumulatedTime >= baseInterval {
            accumulatedTime = 0
            DispatchQueue.main.async { [weak self] in
                self?.advanceWord()
            }
        }
    }
    
    private func advanceWord() {
        let words = AppState.shared.words
        guard currentIndex < words.count - 1 else {
            pause()
            return
        }

        currentIndex += 1
        AppState.shared.currentWordIndex = currentIndex

        // Get smart cadence adjustment for next word
        guard currentIndex < words.count else {
            pause()
            return
        }
        
        let word = words[currentIndex]
        let adjustment = cadenceEngine.adjustment(forWord: word)
        let baseInterval = cadenceEngine.baseInterval(forWPM: Int(wpmSlider))

        // Add extra time for punctuation pauses
        if adjustment > 1.0 {
            accumulatedTime = -baseInterval * (adjustment - 1.0)
        }

        updateWordDisplay()
    }

    private func updateWordDisplay() {
        let words = AppState.shared.words
        guard currentIndex >= 0, currentIndex < words.count else {
            currentWord = ("", "", "")
            return
        }

        let word = words[currentIndex]
        currentWord = tokenizer.getWordWithFocus(word)
    }
    
    private func updateSpeedZone() {
        let wpm = Int(wpmSlider)
        switch wpm {
        case 120..<180:
            speedZone = "Very Slow"
        case 180..<280:
            speedZone = "Comfort"
        case 280..<400:
            speedZone = "Fast"
        case 400..<600:
            speedZone = "Training"
        case 600...900:
            speedZone = "Extreme"
        default:
            speedZone = "Comfort"
        }
    }
    
    var sliderStep: Double {
        return Int(wpmSlider) <= 400 ? 10 : 25
    }
}
