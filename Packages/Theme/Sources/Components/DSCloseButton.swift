//
//  DSCloseButton.swift
//  Theme
//

import SwiftUI

/// Circular X button used to dismiss modal screens (welcome, auth flow, etc.).
///
/// Renders the SF Symbol `xmark.circle.fill` in palette mode so the glyph and
/// the disc background can be tinted independently. Defaults pair a white
/// glyph with a translucent white disc — readable on dark/photographic
/// backgrounds — but both layers can be overridden via init for use on
/// light surfaces.
///
/// Usage:
/// ```swift
/// DSCloseButton(accessibilityLabel: "Close") { dismiss() }
///
/// // On a light background:
/// DSCloseButton(
///     accessibilityLabel: "Close",
///     foreground: \.textPrimary,
///     background: \.surfaceTertiary
/// ) { dismiss() }
/// ```
public struct DSCloseButton: View {

    @Environment(AppTheme.self) private var theme

    private let accessibilityLabel: String
    private let foreground: KeyPath<ColorTokens, Color>
    private let background: KeyPath<ColorTokens, Color>
    private let backgroundOpacity: Double
    private let action: () -> Void

    public init(
        accessibilityLabel: String,
        foreground: KeyPath<ColorTokens, Color> = \.primaryForeground,
        background: KeyPath<ColorTokens, Color> = \.primaryForeground,
        backgroundOpacity: Double = Constants.Opacity.overlay,
        action: @escaping () -> Void
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.foreground = foreground
        self.background = background
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
                    theme.colors[keyPath: foreground],
                    theme.colors[keyPath: background].opacity(backgroundOpacity)
                )
                .frame(width: Self.size, height: Self.size)
        }
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Layout

    private static let size: CGFloat = 32
}
