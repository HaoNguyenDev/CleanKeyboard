//
//  MainView.swift
//  CleanKeyboard
//
//  Created by Hao Nguyen on 17/04/2026.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var lockManager: KeyboardLockManager
    @EnvironmentObject private var localization: LocalizationManager
    @State private var isAnimating = false
    @State private var gradientShift = false

    var body: some View {
        ZStack {
            backgroundGradient
            mainContent
        }
        .frame(width: 380)
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                gradientShift = true
            }
        }

        .onChange(of: lockManager.isLocked) { _, newValue in
            isAnimating = newValue
        }
        .alert(
            localization.string("alert.title"),
            isPresented: $lockManager.needsAccessibilityPermission,
            actions: {
                Button(localization.string("alert.openSettings")) {
                    NSWorkspace.shared.open(
                        URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                    )
                }
                Button(localization.string("alert.cancel"), role: .cancel) {}
            },
            message: {
                Text(localization.string("alert.message"))
            }
        )
    }
}

// MARK: - Subviews

private extension MainView {

    var backgroundGradient: some View {
        // Colors shift based on lock state
        let c1: Color = lockManager.isLocked ? Color(red: 0.12, green: 0.08, blue: 0.28) : Color(red: 0.06, green: 0.12, blue: 0.32)
        let c2: Color = lockManager.isLocked ? Color(red: 0.22, green: 0.08, blue: 0.38) : Color(red: 0.08, green: 0.16, blue: 0.28)
        let c3: Color = lockManager.isLocked ? Color(red: 0.16, green: 0.06, blue: 0.32) : Color(red: 0.04, green: 0.10, blue: 0.24)

        // Gradient start/end points animate slowly back and forth
        let start: UnitPoint = gradientShift ? .bottomLeading : .topLeading
        let end: UnitPoint   = gradientShift ? .topTrailing   : .bottomTrailing

        return LinearGradient(colors: [c1, c2, c3], startPoint: start, endPoint: end)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .animation(.easeInOut(duration: 0.8), value: lockManager.isLocked)
    }

    var mainContent: some View {
        VStack(spacing: 32) {
            languagePickerRow
            headerSection
            lockIconSection
            statusBadge
            descriptionText
            toggleButton
        }
        .padding(.horizontal, 28)
        .padding(.top, 016 )
        .padding(.bottom, 36)
    }

    var languagePickerRow: some View {
        HStack {
            Spacer()
            LanguagePickerView()
        }
        .padding(.horizontal, 4)
    }

    var headerSection: some View {
        VStack(spacing: 8) {
            Text(localization.string("app.title"))
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Text(localization.string("app.subtitle"))
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    var lockIconSection: some View {
        ZStack {
            glowRing
            glassCircle
            lockSymbol
        }
    }

    var glowRing: some View {
        let colors: [Color] = lockManager.isLocked
            ? [Color.purple.opacity(0.3), Color.clear]
            : [Color.blue.opacity(0.2), Color.clear]

        return Circle()
            .fill(RadialGradient(colors: colors, center: .center, startRadius: 40, endRadius: 90))
            .frame(width: 180, height: 180)
            .scaleEffect(isAnimating && lockManager.isLocked ? 1.12 : 1.0)
            .animation(
                lockManager.isLocked
                    ? .easeInOut(duration: 1.4).repeatForever(autoreverses: true)
                    : .default,
                value: isAnimating
            )
    }

    var glassCircle: some View {
        Circle()
            .fill(.ultraThinMaterial)
            .frame(width: 130, height: 130)
            .overlay(
                Circle().strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            )
    }

    var lockSymbol: some View {
        let gradient: LinearGradient = lockManager.isLocked
            ? LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom)
            : LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)

        return Image(systemName: lockManager.isLocked ? "lock.fill" : "lock.open.fill")
            .font(.system(size: 44, weight: .medium))
            .foregroundStyle(gradient)
            .symbolEffect(.bounce, value: lockManager.isLocked)
    }

    var statusBadge: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(lockManager.isLocked ? Color.purple : Color.green)
                .frame(width: 8, height: 8)
                .shadow(color: lockManager.isLocked ? .purple : .green, radius: 4)
                .scaleEffect(isAnimating && lockManager.isLocked ? 1.3 : 1.0)
                .animation(
                    lockManager.isLocked
                        ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                        : .default,
                    value: isAnimating
                )

            Text(localization.string(lockManager.isLocked ? "status.locked" : "status.active"))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.white.opacity(0.08), in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.12), lineWidth: 1))
    }

    var descriptionText: some View {
        Text(localization.string(lockManager.isLocked ? "description.locked" : "description.unlocked"))
            .font(.system(size: 13, design: .rounded))
            .foregroundStyle(.white.opacity(0.55))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .animation(.easeInOut(duration: 0.3), value: lockManager.isLocked)
    }

    var toggleButton: some View {
        let isLocked = lockManager.isLocked

        return LedBorderButton(
            title: localization.string(isLocked ? "button.unlock" : "button.lock"),
            icon: isLocked ? "lock.open" : "lock",
            fillColors: isLocked
                ? [.purple, .pink.opacity(0.8)]
                : [.blue, .cyan.opacity(0.8)],
            cometColor: isLocked ? .pink : .cyan,
            shadowColor: isLocked ? .purple.opacity(0.5) : .blue.opacity(0.5),
            isBreathing: isLocked,
            action: lockManager.toggle
        )
        .padding(.horizontal, 4)
        .animation(.easeInOut(duration: 0.4), value: isLocked)
    }
}

// MARK: - Preview

#Preview {
    MainView()
        .environmentObject(KeyboardLockManager())
        .environmentObject(LocalizationManager())
}
