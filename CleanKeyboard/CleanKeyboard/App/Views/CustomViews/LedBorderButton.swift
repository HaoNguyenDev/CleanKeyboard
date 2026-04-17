//
//  LedBorderButton.swift
//  CleanKeyboard
//
//  Created by Hao Nguyen on 17/04/2026.
//
//  Reusable button with an LED comet effect running around the border.
//  Has no dependency on any app-specific logic.
//

import SwiftUI
import Combine

// MARK: - LedBorderButton

/// Full-width button with a gradient fill and an LED comet effect running around the border.
/// Optionally displays a breathing glow effect to draw the user's attention.
///
/// Usage:
/// ```swift
/// LedBorderButton(
///     title: "Lock Keyboard",
///     icon: "lock",
///     fillColors: [.blue, .cyan.opacity(0.8)],
///     cometColor: .cyan,
///     shadowColor: .blue.opacity(0.5),
///     isBreathing: false,
///     action: { ... }
/// )
/// ```
struct LedBorderButton: View {

    // MARK: - Configuration

    let title: String
    let icon: String
    let fillColors: [Color]
    let cometColor: Color
    let shadowColor: Color
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    /// When true, the button pulses with a breathing glow to attract attention.
    let isBreathing: Bool
    let action: () -> Void

    // MARK: - Init

    init(
        title: String,
        icon: String,
        fillColors: [Color],
        cometColor: Color,
        shadowColor: Color,
        cornerRadius: CGFloat = 14,
        borderWidth: CGFloat = 1.5,
        isBreathing: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.fillColors = fillColors
        self.cometColor = cometColor
        self.shadowColor = shadowColor
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.isBreathing = isBreathing
        self.action = action
    }

    // MARK: - State

    @State private var ledPhase: Double = 0
    @State private var breathPhase: Bool = false
    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onAppear {
            if isBreathing {
                startBreathing()
            }
        }
        .onChange(of: isBreathing) { _, newValue in
            if newValue {
                startBreathing()
            } else {
                breathPhase = false
            }
        }
        .onReceive(timer) { _ in
            ledPhase = (ledPhase + 1.2).truncatingRemainder(dividingBy: 360)
        }
    }

    // MARK: - Private views

    private var label: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(fillGradient, in: RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(ledBorderGradient, lineWidth: borderWidth)
        )
        // Breathing outer glow layer
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(cometColor.opacity(isBreathing ? (breathPhase ? 0.65 : 0.15) : 0))
                .blur(radius: isBreathing ? (breathPhase ? 20 : 8) : 0)
                .scaleEffect(isBreathing ? (breathPhase ? 1.10 : 0.97) : 1)
                .animation(
                    isBreathing
                        ? .easeInOut(duration: 1.6).repeatForever(autoreverses: true)
                        : .default,
                    value: breathPhase
                )
        )
        .shadow(
            color: shadowColor.opacity(isBreathing ? (breathPhase ? 1.0 : 0.3) : 0.5),
            radius: isBreathing ? (breathPhase ? 24 : 8) : 12,
            y: 4
        )
    }

    private var fillGradient: LinearGradient {
        LinearGradient(colors: fillColors, startPoint: .leading, endPoint: .trailing)
    }

    /// AngularGradient with a single bright comet sweeping along the border, driven by ledPhase.
    private var ledBorderGradient: AngularGradient {
        let base = cometColor.opacity(0.2)
        return AngularGradient(
            stops: [
                .init(color: base,                    location: 0.00),
                .init(color: base,                    location: 0.65),
                .init(color: cometColor.opacity(0.5), location: 0.75),
                .init(color: .white,                  location: 0.82),
                .init(color: cometColor.opacity(0.5), location: 0.89),
                .init(color: base,                    location: 1.00),
            ],
            center: .center,
            startAngle: .degrees(ledPhase),
            endAngle: .degrees(ledPhase + 360)
        )
    }

    private func startBreathing() {
        breathPhase = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            breathPhase = true
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        LedBorderButton(
            title: "Lock Keyboard",
            icon: "lock",
            fillColors: [.blue, .cyan.opacity(0.8)],
            cometColor: .cyan,
            shadowColor: .blue.opacity(0.5),
            isBreathing: false,
            action: {}
        )

        LedBorderButton(
            title: "Unlock Keyboard",
            icon: "lock.open",
            fillColors: [.purple, .pink.opacity(0.8)],
            cometColor: .pink,
            shadowColor: .purple.opacity(0.5),
            isBreathing: true,
            action: {}
        )
    }
    .padding(28)
    .background(Color(red: 0.06, green: 0.12, blue: 0.32))
}
