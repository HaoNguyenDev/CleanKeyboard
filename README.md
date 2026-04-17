# ⌨️ CleanKeyboard
A lightweight macOS utility to safely clean your keyboard without accidental inputs.

🌟 Overview
CleanKeyboard is a lightweight utility designed for MacBook and Magic Keyboard users. It allows you to wipe down your keys and perform physical maintenance without needing to shut down your machine or worrying about triggering unwanted commands, deleting files, or sending accidental messages.

By leveraging Core Graphics Event Taps, the app intercept keyboard events at a low level while maintaining mouse/trackpad functionality so you can always toggle the lock state.

✨ Features
Total Keyboard Lock: Disables all physical key presses including KeyDown, KeyUp, and Modifier Flags.

Modern SwiftUI Interface: A clean, native macOS UI featuring glassmorphism (translucency) and smooth transitions.

Visual Feedback: A clear "Locked" state with intuitive animations so you know exactly when it is safe to clean.

Safety First: Mouse and trackpad inputs remain active at all times, ensuring you are never locked out of your own system.

🛠 Tech Stack
Language: Swift 5.10+

Framework: SwiftUI

System API: CGEventTap (Core Graphics) for low-level system event interception.

Architecture: Observable Pattern (MVVM).

🚀 How It Works
The application requires Accessibility Permissions to monitor and swallow keyboard events before they reach the system event queue:

Swift
// Core interception logic
eventTap = CGEvent.tapCreate(
    tap: .cghidEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: [.keyDown, .keyUp, .flagsChanged],
    callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
        // Return nil to "swallow" the event and prevent it from reaching other apps
        return nil 
    },
    userInfo: nil
)
📋 Requirements & Installation
Requirements

macOS 13.0 (Ventura) or later.

Xcode 15.0+ (to build from source).

Installation

Clone the repository:

Bash
git clone https://github.com/HaoNguyenDev/CleanKeyboard.git
Open CleanKeyboard.xcodeproj in Xcode.

In the Signing & Capabilities tab, ensure App Sandbox is disabled (required for Event Taps to function).

Build and Run (Cmd + R).

[!IMPORTANT]

Granting Permissions: > On the first launch, macOS will block the event tap. You must manually grant permission under:

System Settings > Privacy & Security > Accessibility > Check the box/toggle next to CleanKeyboard.

📸 Screenshots
Idle State	Cleaning Mode
🤝 Contributing
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

Fork the Project

Create your Feature Branch (git checkout -b feature/AmazingFeature)

Commit your Changes (git commit -m 'Add some AmazingFeature')

Push to the Branch (git push origin feature/AmazingFeature)

Open a Pull Request

📄 License
Distributed under the MIT License. See LICENSE for more information.

Developed with ❤️ by Hao Nguyen
