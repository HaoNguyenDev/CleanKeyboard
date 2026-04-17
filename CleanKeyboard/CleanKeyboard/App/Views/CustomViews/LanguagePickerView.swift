//
//  LanguagePickerView.swift
//  CleanKeyboard
//
//  Created by Hao Nguyen on 17/04/2026.
//

import SwiftUI

struct LanguagePickerView: View {
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        Menu {
            ForEach(AppLanguage.allCases) { language in
                Button(action: {
                    localization.setLanguage(language)
                }) {
                    HStack {
                        Text("\(language.flag) \(language.nativeName)")
                        if language == localization.currentLanguage {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(localization.currentLanguage.flag)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.white.opacity(0.12), lineWidth: 1)
            )
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
    }
}
