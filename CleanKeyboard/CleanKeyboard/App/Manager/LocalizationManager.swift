//
//  LocalizationManager.swift
//  CleanKeyboard
//
//  Created by Hao Nguyen on 17/04/2026.
//

import Foundation
import Combine

// MARK: - AppLanguage

/// Supported languages with their BCP-47 code, native display name, and flag.
enum AppLanguage: String, CaseIterable, Identifiable {
    case english           = "en"
    case vietnamese        = "vi"
    case chineseSimplified = "zh-Hans"
    case japanese          = "ja"
    case french            = "fr"
    case spanish           = "es"
    case korean            = "ko"
    case german            = "de"

    var id: String { rawValue }

    /// Language name written in its own script.
    var nativeName: String {
        switch self {
        case .english:           return "English"
        case .vietnamese:        return "Tiếng Việt"
        case .chineseSimplified: return "简体中文"
        case .japanese:          return "日本語"
        case .french:            return "Français"
        case .spanish:           return "Español"
        case .korean:            return "한국어"
        case .german:            return "Deutsch"
        }
    }

    /// Flag emoji for the language.
    var flag: String {
        switch self {
        case .english:           return "🇬🇧"
        case .vietnamese:        return "🇻🇳"
        case .chineseSimplified: return "🇨🇳"
        case .japanese:          return "🇯🇵"
        case .french:            return "🇫🇷"
        case .spanish:           return "🇪🇸"
        case .korean:            return "🇰🇷"
        case .german:            return "🇩🇪"
        }
    }
}

// MARK: - LocalizationManager

/// Manages runtime language switching independent of the system locale.
/// Inject as an EnvironmentObject; call `string(_:)` to get localized strings.
final class LocalizationManager: ObservableObject {

    private static let userDefaultsKey = "selectedAppLanguage"

    @Published private(set) var currentLanguage: AppLanguage
    @Published private(set) var bundle: Bundle

    init() {
        let savedCode = UserDefaults.standard.string(forKey: Self.userDefaultsKey) ?? "en"
        let language = AppLanguage(rawValue: savedCode) ?? .english
        self.currentLanguage = language
        self.bundle = Self.loadBundle(for: language)
    }

    /// Returns the localized string for the given key from the active language bundle.
    func string(_ key: String) -> String {
        NSLocalizedString(key, bundle: bundle, comment: "")
    }

    /// Switches the active language, persists the choice, and triggers a UI re-render.
    func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language
        bundle = Self.loadBundle(for: language)
        UserDefaults.standard.set(language.rawValue, forKey: Self.userDefaultsKey)
    }

    /// Loads the Bundle from the `.lproj` directory for the given language.
    /// Falls back to the main bundle if the directory is not found.
    private static func loadBundle(for language: AppLanguage) -> Bundle {
        let candidates = [language.rawValue, String(language.rawValue.prefix(2))]
        for candidate in candidates {
            if let path = Bundle.main.path(forResource: candidate, ofType: "lproj"),
               let langBundle = Bundle(path: path) {
                return langBundle
            }
        }
        return Bundle.main
    }
}
