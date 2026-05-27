# FlashRead

> Native macOS menu bar speed-reader — RSVP, one word at a time.

Copy any text, hit `⌥⌘R`, and read at up to 900 WPM in a floating window.

---

## Features

- **Menu bar app** — rabbit icon, always accessible
- **Global shortcut** (`⌥⌘R`) — works from any app
- **Clipboard-first** — paste, drag-and-drop, or open `.txt`/`.md` files
- **RSVP display** — one word at a time with optimal recognition point highlight
- **Smart cadence** — automatic pause at punctuation for natural rhythm
- **Speed zones** — 120–900 WPM (Very Slow → Extreme)
- **Full-text view** — click any word to jump to that position
- **Session persistence** — resumes text + position + WPM across launches
- **Frosted glass UI** — native macOS translucency, stays floating above other windows

## Install

1. Clone and open in Xcode:
   ```bash
   git clone https://github.com/renatomoscati-creator/flashread.git
   open flashread/FlashRead.xcodeproj
   ```
2. Build & run (`⌘R`)

**Requirements:** macOS 13.0+, Xcode 15+

## Usage

1. Select + copy text anywhere on your Mac
2. Press `⌥⌘R` (or click the menu bar icon)
3. Press **Start** — read

Spacebar pauses/resumes. Arrow keys step word by word. Drag the window anywhere.

## Project Structure

```
FlashRead/
├── FlashReadApp.swift          # App entry point
├── AppDelegate.swift           # Menu bar, window lifecycle
├── Models/AppState.swift       # Centralized state
├── Views/                      # SwiftUI views (reader, import, settings)
├── ViewModels/                 # Playback logic, import handling
├── Services/                   # Clipboard, tokenizer, cadence, shortcuts
└── Utils/                      # Event monitor, visual effects, window controller
```

## Tech

Swift · AppKit · SwiftUI · Carbon HotKey API · UserDefaults

## License

MIT © 2026 Renato Moscati
