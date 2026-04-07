//
//  DSCloseButton.swift
//  Theme
//

import SwiftUI

/// Circular X button used to dismiss modal screens (welcome, auth flow, etc.).
///
/// Renders the SF Symbol `xmark.circle.fill` in palette mode so the glyph
/// and the disc background can be tinted independently. Defaults pair a
/// dark glyph with a fully opaque white disc — visible on any background,
/// photographic or solid — but both layers can be overridden via init for
/// other contexts.
///
/// Usage:
/// ```swift
/// DSCloseButton(accessibilityLabel: "Close") { dismiss() }
/// ```
public struct DSCloseButton: View {

    @Environment(AppTheme.self) private var theme

    private let accessibilityLabel: String
    private let foreground: KeyPath<ColorTokens, Color>
    private let background: KeyPath<ColorTokens, Color>
    private let foregroundOpacity: Double
    private let backgroundOpacity: Double
    private let action: () -> Void

    public init(
        accessibilityLabel: String,
        foreground: KeyPath<ColorTokens, Color> = \.textPrimary,
        background: KeyPath<ColorTokens, Color> = \.primaryForeground,
        foregroundOpacity: Double = 1,
        backgroundOpacity: Double = 1,
        action: @escaping () -> Void
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.foreground = foreground
        self.background = background
        self.foregroundOpacity = foregroundOpacity
        self.backgroundOpacity = backgroundOpacity
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    theme.colors[keyPath: foreground].opacity(foregroundOpacity),
                    theme.colors[keyPath: background].opacity(backgroundOpacity)
                )
                .frame(width: Self.size, height: Self.size)
                .contentShape(Circle())
        }
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Layout

    private static let size: CGFloat = 40
}
