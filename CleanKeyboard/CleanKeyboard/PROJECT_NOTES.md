# CleanKeyboard — Project Notes

> Internal reference document covering the full structure, features, and implementation details of the project.

---

## App Description

**CleanKeyboard** is a lightweight macOS utility app for MacBook and Magic Keyboard users.  
Purpose: allows physical keyboard cleaning without shutting down the machine — no risk of triggering accidental keypresses, sending messages, or deleting files.

- Locks all keyboard input (keyDown, keyUp, modifier keys)
- Mouse / trackpad remain fully functional → the user is never locked out
- Dark SwiftUI interface with glassmorphism and smooth animations

---

## File Structure

```
CleanKeyboard/
├── CleanKeyboardApp.swift          Entry point, initialises 2 ObservableObjects
├── MainView.swift                  All primary UI
├── KeyboardLockManager.swift       Keyboard lock/unlock logic (CGEventTap)
├── LocalizationManager.swift       Runtime language switching
├── LanguagePickerView.swift        Language picker UI (top-right corner)
├── LedBorderButton.swift           Reusable button with LED comet border effect
├── Info.plist                      Declares NSAccessibilityUsageDescription
├── en.lproj/Localizable.strings
├── vi.lproj/Localizable.strings
├── zh-Hans.lproj/Localizable.strings
├── ja.lproj/Localizable.strings
├── fr.lproj/Localizable.strings
├── es.lproj/Localizable.strings
├── ko.lproj/Localizable.strings
└── de.lproj/Localizable.strings
```

---

## Feature 1 — Keyboard Lock (CGEventTap)

**File:** `KeyboardLockManager.swift`

### How it works

1. Calls `AXIsProcessTrustedWithOptions` to check Accessibility permission.
   - If not granted: sets `needsAccessibilityPermission = true` → UI shows an alert directing the user to System Settings.
2. Creates `CGEvent.tapCreate` with:
   - `tap: .cgSessionEventTap` — intercepts at the session level (system-wide)
   - `place: .headInsertEventTap` — intercepts before the event reaches any app
   - `eventsOfInterest`: keyDown + keyUp + flagsChanged
   - `callback`: returns `nil` to discard the event, or `Unmanaged.passRetained(event)` to pass it through
3. Adds the tap to the main run loop.
4. To unlock: `CGEvent.tapEnable(tap:enable:false)` + removes from run loop.

### Published properties

| Property | Type | Description |
|---|---|---|
| `isLocked` | `Bool` | Current lock state |
| `needsAccessibilityPermission` | `Bool` | Triggers the Accessibility permission alert |

### Public API

```swift
lockManager.enableLock()   // Lock the keyboard
lockManager.disableLock()  // Unlock the keyboard
lockManager.toggle()       // Toggle lock state
```

### Important notes

- The app **must** be granted **Accessibility** permission in System Settings → Privacy & Security → Accessibility.
- On first launch from Xcode: tap "Lock Keyboard" → system shows the permission dialog → accept → enable the toggle in System Settings.
- If the app does not appear in the Accessibility list: click **+** and navigate to the `.app` file in DerivedData.
- `NSAccessibilityUsageDescription` is already declared in `Info.plist`.

---

## Feature 2 — UI (MainView + LanguagePickerView)

**Files:** `MainView.swift`, `LanguagePickerView.swift`

### Layout (top to bottom)

```
[Language Picker]          ← top-right, flag emoji + chevron
[App Title]
[App Subtitle]
[Lock Icon + Glow Ring]    ← 130pt glass circle, 180pt glow
[Status Badge]             ← capsule: dot + text
[Description Text]
[Lock/Unlock Button]       ← full-width LedBorderButton
```

### Colors by state

| State | Background gradient | Icon gradient | Button gradient | Dot |
|---|---|---|---|---|
| Unlocked | Dark blue | Blue → Cyan | Blue → Cyan | Green |
| Locked | Dark purple | Purple → Pink | Purple → Pink | Purple |

### Animations

- Background gradient: slow `easeInOut(duration: 6).repeatForever` shift of start/end points
- Glow ring: `easeInOut(duration: 1.4).repeatForever` scale pulse when locked
- Status dot: `easeInOut(duration: 0.8).repeatForever` scale pulse when locked
- Lock icon: `.symbolEffect(.bounce)` on toggle
- Button: `easeInOut(duration: 0.4)` on state change
- LED border: comet sweeps the button border at 60 fps via a `Timer`

### UI fixes applied

- Background `LinearGradient` has `.allowsHitTesting(false)` to prevent blocking button clicks
- Button has `.contentShape(Rectangle())` to accept clicks across the full area
- Window uses `.windowResizability(.contentSize)` with no fixed height → auto-fits content
- Padding: `.horizontal: 28`, `.top: 16`, `.bottom: 36`

---

## Feature 3 — Multi-language (In-App Language Picker)

**Files:** `LocalizationManager.swift`, `LanguagePickerView.swift`, 8 `.strings` files

### Supported languages

| Enum case | BCP-47 code | Native name | Flag |
|---|---|---|---|
| `.english` | `en` | English | 🇬🇧 |
| `.vietnamese` | `vi` | Tiếng Việt | 🇻🇳 |
| `.chineseSimplified` | `zh-Hans` | 简体中文 | 🇨🇳 |
| `.japanese` | `ja` | 日本語 | 🇯🇵 |
| `.french` | `fr` | Français | 🇫🇷 |
| `.spanish` | `es` | Español | 🇪🇸 |
| `.korean` | `ko` | 한국어 | 🇰🇷 |
| `.german` | `de` | Deutsch | 🇩🇪 |

### How it works (runtime bundle switching)

Standard Apple localization picks a language at process launch based on the system locale — it cannot switch at runtime.  
Solution: load the correct `Bundle` from the matching `.lproj` directory at runtime.

```
User selects a language
    → LocalizationManager.setLanguage(_:)
    → Loads Bundle from "vi.lproj" (or "zh-Hans.lproj", etc.)
    → @Published bundle changes
    → SwiftUI re-renders all of MainView
    → Every localization.string("key") reads from the new bundle
    → UI updates instantly with no restart required
```

The selection is persisted to `UserDefaults` under the key `"selectedAppLanguage"`.  
On app restart: reads from UserDefaults and loads the correct bundle.

### String keys (13 keys)

```
app.title              — App name (header)
app.subtitle           — "Safe keyboard cleaning mode"
status.locked          — "Keyboard Locked"
status.active          — "Keyboard Active"
description.locked     — Description shown when locked
description.unlocked   — Description shown when unlocked
button.unlock          — Button label when currently locked
button.lock            — Button label when currently unlocked
alert.title            — Accessibility alert title
alert.openSettings     — "Open System Settings" button
alert.cancel           — "Cancel" button
alert.message          — Accessibility alert body text
language.picker        — Picker label (available but not currently shown in UI)
```

### Usage in views

```swift
@EnvironmentObject var localization: LocalizationManager

Text(localization.string("app.title"))
Text(localization.string(isLocked ? "status.locked" : "status.active"))
```

### Adding a new language

1. Add a case to the `AppLanguage` enum in `LocalizationManager.swift`
2. Add `nativeName` and `flag` for that case
3. Create a `<code>.lproj/` directory inside `CleanKeyboard/`
4. Create `Localizable.strings` with all 13 keys
5. Build — Xcode detects it automatically (project uses `PBXFileSystemSynchronizedRootGroup`)

---

## Feature 4 — LedBorderButton (Reusable Component)

**File:** `LedBorderButton.swift`

A fully self-contained SwiftUI button with no app-specific dependencies.  
Drives a 60 fps `Timer` internally; exposes all visual properties as parameters.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `title` | `String` | — | Button label text |
| `icon` | `String` | — | SF Symbol name |
| `fillColors` | `[Color]` | — | Gradient fill colors |
| `cometColor` | `Color` | — | LED comet and border accent color |
| `shadowColor` | `Color` | — | Drop shadow color |
| `cornerRadius` | `CGFloat` | `14` | Corner radius |
| `borderWidth` | `CGFloat` | `1.5` | Border stroke width |
| `action` | `() -> Void` | — | Tap handler |

---

## Architecture Overview

```
CleanKeyboardApp
    ├── @StateObject KeyboardLockManager   → injected via environmentObject
    └── @StateObject LocalizationManager   → injected via environmentObject
            ↓
        MainView
            ├── @EnvironmentObject lockManager
            ├── @EnvironmentObject localization
            └── LanguagePickerView
                    └── @EnvironmentObject localization
```

### Data flow

- `lockManager.isLocked` → drives all UI state (colors, text, icons)
- `lockManager.needsAccessibilityPermission` → triggers the `.alert` for permission
- `localization.bundle` → every `localization.string("key")` reads from this bundle
- `localization.currentLanguage` → LanguagePickerView shows current flag + checkmark

---

## System Requirements

- macOS 26.2+
- **Accessibility** permission required for CGEventTap to function
- Bundle ID: `com.haonguyen.cleankeyboard.CleanKeyboard`

---

## Known Issues & Fixes

| Issue | Cause | Fix |
|---|---|---|
| Button not receiving clicks | Background `LinearGradient` in `ZStack` was blocking hit-testing | Added `.allowsHitTesting(false)` on the gradient |
| Button cropped by window | Fixed window height was too small | Removed fixed height; using `.windowResizability(.contentSize)` |
| `ObservableObject` conformance error | Missing `import Combine` | Added `import Combine` to `KeyboardLockManager.swift` |
| App not appearing in Accessibility list | Permission not granted + missing `NSAccessibilityUsageDescription` | Added key to `Info.plist`; reset TCC with `tccutil reset Accessibility` |
