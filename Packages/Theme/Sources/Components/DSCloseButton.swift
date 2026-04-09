//
//  DSCloseButton.swift
//  Theme
//

import SwiftUI

/// Circular X button used to dismiss modal screens (welcome, auth flow, etc.).
///
/// Uses a frosted-glass disc (matching the `dsFrostedCard` content boxes)
/// with an `xmark` glyph tinted to match the card text color. Both layers
/// are visible in light and dark mode.
///
/// Usage:
/// ```swift
/// DSCloseButton(accessibilityLabel: "Close") { dismiss() }
/// ```
public struct DSCloseButton: View {

    @Environment(AppTheme.self) private var theme

    private let accessibilityLabel: String
    private let foreground: KeyPath<ColorTokens, Color>
    private let action: () -> Void

    public init(
        accessibilityLabel: String,
        foreground: KeyPath<ColorTokens, Color> = \.primaryForeground,
        action: @escaping () -> Void
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.foreground = foreground
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(Circle().fill(Color.black.opacity(Self.darkOverlayOpacity)))
                Image(systemName: "xmark")
                    .font(.system(size: Self.iconSize, weight: .bold))
                    .foregroundStyle(theme.colors[keyPath: foreground])
            }
            .frame(width: Self.size, height: Self.size)
            .contentShape(Circle())
        }
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Layout

    private static let size: CGFloat = 40
    private static let iconSize: CGFloat = 14
    private static let darkOverlayOpacity: Double = 0.35
}
