//
//  ShortcutManager.swift
//  FlashRead
//
//  Manages global keyboard shortcut registration using Carbon HotKey API.
//

import Cocoa
import Carbon.HIToolbox
import AppKit

class ShortcutManager {
    static let shared = ShortcutManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    // Default: Option+Command+R
    private var currentModifiers: UInt32 = UInt32(optionKey + cmdKey)
    private var currentKeyCode: UInt32 = 15  // 'R' key

    private init() {
        registerGlobalHotKey()
    }

    deinit {
        unregisterGlobalHotKey()
    }

    private func registerGlobalHotKey() {
        // Unregister any existing hotkey
        unregisterGlobalHotKey()

        // Create a unique signature for this hotkey
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = UInt32(0x46525348) // "FRSH" for FlashRead
        hotKeyID.id = 1

        // Register the hotkey
        let result = RegisterEventHotKey(
            currentKeyCode,
            currentModifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        if result == noErr {
            // Install event handler
            var eventType = EventTypeSpec()
            eventType.eventClass = OSType(kEventClassKeyboard)
            eventType.eventKind = UInt32(kEventHotKeyPressed)

            let handler: EventHandlerUPP = { _, event, _ in
                guard let event = event else { return OSStatus(eventNotHandledErr) }
                
                var hotKeyID = EventHotKeyID()
                let getResult = GetEventParameter(
                    event,
                    UInt32(kEventParamDirectObject),
                    UInt32(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                
                guard getResult == noErr, hotKeyID.signature == 0x46525348 else {
                    return OSStatus(eventNotHandledErr)
                }

                // Trigger the app on main thread
                DispatchQueue.main.async {
                    guard NSApp != nil, NSApp.isActive || NSApp.isHidden == false else { return }
                    if let delegate = NSApp.delegate as? AppDelegate {
                        delegate.openFlashRead()
                    }
                }
                
                return OSStatus(noErr)
            }
            
            let err = InstallEventHandler(
                GetEventDispatcherTarget(),
                handler,
                1,
                &eventType,
                nil,
                &eventHandler
            )

            if err != noErr {
                print("Failed to install event handler: \(err)")
            }
        } else {
            print("Failed to register hotkey: \(result)")
        }
    }

    private func unregisterGlobalHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }

    func updateShortcut(keyCode: UInt32, modifiers: UInt32) {
        currentKeyCode = keyCode
        currentModifiers = modifiers
        registerGlobalHotKey()
    }
}
