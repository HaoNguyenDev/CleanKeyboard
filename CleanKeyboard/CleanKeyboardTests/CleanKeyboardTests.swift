//
//  CleanKeyboardTests.swift
//  CleanKeyboardTests
//
//  Created by Hao Nguyen on 17/04/2026.
//

import Testing
import Foundation
@testable import CleanKeyboard

// MARK: - AppLanguage Tests

@Suite("AppLanguage")
struct AppLanguageTests {

    @Test("All cases have a non-empty native name")
    func allCasesHaveNativeName() {
        for language in AppLanguage.allCases {
            #expect(!language.nativeName.isEmpty, "nativeName is empty for \(language.rawValue)")
        }
    }

    @Test("All cases have a non-empty flag")
    func allCasesHaveFlag() {
        for language in AppLanguage.allCases {
            #expect(!language.flag.isEmpty, "flag is empty for \(language.rawValue)")
        }
    }

    @Test("id equals rawValue")
    func idEqualsRawValue() {
        for language in AppLanguage.allCases {
            #expect(language.id == language.rawValue)
        }
    }

    @Test("Exactly 8 supported languages")
    func languageCount() {
        #expect(AppLanguage.allCases.count == 8)
    }

    @Test("Known native names are correct")
    func knownNativeNames() {
        #expect(AppLanguage.english.nativeName == "English")
        #expect(AppLanguage.vietnamese.nativeName == "Tiếng Việt")
        #expect(AppLanguage.chineseSimplified.nativeName == "简体中文")
        #expect(AppLanguage.japanese.nativeName == "日本語")
        #expect(AppLanguage.french.nativeName == "Français")
        #expect(AppLanguage.spanish.nativeName == "Español")
        #expect(AppLanguage.korean.nativeName == "한국어")
        #expect(AppLanguage.german.nativeName == "Deutsch")
    }

    @Test("Known flags are correct")
    func knownFlags() {
        #expect(AppLanguage.english.flag == "🇬🇧")
        #expect(AppLanguage.vietnamese.flag == "🇻🇳")
        #expect(AppLanguage.chineseSimplified.flag == "🇨🇳")
        #expect(AppLanguage.japanese.flag == "🇯🇵")
        #expect(AppLanguage.french.flag == "🇫🇷")
        #expect(AppLanguage.spanish.flag == "🇪🇸")
        #expect(AppLanguage.korean.flag == "🇰🇷")
        #expect(AppLanguage.german.flag == "🇩🇪")
    }
}

// MARK: - LocalizationManager Tests

@Suite("LocalizationManager")
struct LocalizationManagerTests {

    // Use a fresh UserDefaults suite per test run to avoid polluting the real defaults.
    private func makeSUT(savedLanguage: String? = nil) -> LocalizationManager {
        let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        if let code = savedLanguage {
            defaults.set(code, forKey: "selectedAppLanguage")
        }
        return LocalizationManager(defaults: defaults)
    }

    @Test("Defaults to English when no preference is saved")
    func defaultsToEnglish() {
        let sut = makeSUT()
        #expect(sut.currentLanguage == .english)
    }

    @Test("Restores saved language on init")
    func restoresSavedLanguage() {
        let sut = makeSUT(savedLanguage: "vi")
        #expect(sut.currentLanguage == .vietnamese)
    }

    @Test("Falls back to English for unknown saved code")
    func fallsBackToEnglishForUnknownCode() {
        let sut = makeSUT(savedLanguage: "xx")
        #expect(sut.currentLanguage == .english)
    }

    @Test("setLanguage updates currentLanguage")
    func setLanguageUpdatesCurrentLanguage() {
        let sut = makeSUT()
        sut.setLanguage(.japanese)
        #expect(sut.currentLanguage == .japanese)
    }

    @Test("setLanguage with same language is a no-op")
    func setLanguageSameLanguageIsNoOp() {
        let sut = makeSUT()
        let bundleBefore = sut.bundle
        sut.setLanguage(.english)
        #expect(sut.bundle === bundleBefore)
    }

    @Test("setLanguage updates bundle")
    func setLanguageUpdatesBundle() {
        let sut = makeSUT()
        let bundleBefore = sut.bundle
        sut.setLanguage(.german)
        #expect(sut.bundle !== bundleBefore)
    }

    @Test("string(_:) returns non-empty value for all languages and known keys")
    func stringReturnsNonEmptyForAllLanguages() {
        let keys = [
            "app.title", "app.subtitle",
            "status.locked", "status.active",
            "description.locked", "description.unlocked",
            "button.lock", "button.unlock",
            "alert.title", "alert.message", "alert.openSettings", "alert.cancel",
            "language.picker"
        ]
        for language in AppLanguage.allCases {
            let sut = makeSUT()
            sut.setLanguage(language)
            for key in keys {
                let value = sut.string(key)
                #expect(!value.isEmpty, "Empty string for key '\(key)' in language '\(language.rawValue)'")
                // If localisation is missing the key falls back to the key itself — catch that too.
                #expect(value != key, "Missing localisation for key '\(key)' in language '\(language.rawValue)'")
            }
        }
    }
}

// MARK: - KeyboardLockManager Tests

@Suite("KeyboardLockManager")
struct KeyboardLockManagerTests {

    @Test("Initial state is unlocked")
    func initialStateIsUnlocked() {
        let sut = KeyboardLockManager()
        #expect(sut.isLocked == false)
    }

    @Test("Initial needsAccessibilityPermission is false")
    func initialNeedsPermissionIsFalse() {
        let sut = KeyboardLockManager()
        #expect(sut.needsAccessibilityPermission == false)
    }

    @Test("disableLock when already unlocked does not change state")
    func disableLockWhenAlreadyUnlocked() {
        let sut = KeyboardLockManager()
        sut.disableLock()
        #expect(sut.isLocked == false)
    }

    @Test("toggle calls enableLock when unlocked (requires Accessibility in CI — checks permission flag)")
    func toggleFromUnlockedState() {
        let sut = KeyboardLockManager()
        sut.toggle()
        // In a sandboxed test environment Accessibility is not granted, so either:
        // - isLocked becomes true (permission granted), or
        // - needsAccessibilityPermission becomes true (permission denied).
        let handledCorrectly = sut.isLocked || sut.needsAccessibilityPermission
        #expect(handledCorrectly)
    }
}
