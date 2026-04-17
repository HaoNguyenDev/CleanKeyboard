//
//  KeyboardLockManager.swift
//  CleanKeyboard
//
//  Created by Hao Nguyen on 17/04/2026.
//

import Cocoa
import CoreGraphics
import Combine

class KeyboardLockManager: ObservableObject {
    @Published var isLocked = false
    @Published var needsAccessibilityPermission = false

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    // The event tap callback must be a C function, so we use an unmanaged pointer
    private static let eventCallback: CGEventTapCallBack = { proxy, type, event, userInfo in
        // Block all keyboard-related events
        let blocked: [CGEventType] = [.keyDown, .keyUp, .flagsChanged]
        if blocked.contains(type) {
            return nil // Discard the event
        }
        return Unmanaged.passRetained(event)
    }

    func enableLock() {
        guard !isLocked else { return }

        // We need Accessibility permission to use event taps
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options)
        guard trusted else {
            // Prompt was shown; user needs to grant permission in System Settings
            needsAccessibilityPermission = true
            return
        }

        let eventMask: CGEventMask = (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.keyUp.rawValue)
            | (1 << CGEventType.flagsChanged.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: KeyboardLockManager.eventCallback,
            userInfo: nil
        ) else {
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        isLocked = true
    }

    func disableLock() {
        guard isLocked else { return }

        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil

        isLocked = false
    }

    func toggle() {
        if isLocked {
            disableLock()
        } else {
            enableLock()
        }
    }
}
