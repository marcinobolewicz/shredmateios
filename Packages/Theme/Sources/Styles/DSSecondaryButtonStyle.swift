//
//  DSSecondaryButtonStyle.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// Full-width outlined button used for secondary actions (e.g. "Sign Out").
///
/// Uses a stroked rounded rectangle with the primary color and transparent fill.
public struct DSSecondaryButtonStyle: ButtonStyle {

    @Environment(AppTheme.self) private var theme

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(theme.colors.primary)
            .frame(maxWidth: .infinity, minHeight: Constants.Size.buttonMinHeight)
            .background(
                Capsule()
                    .stroke(theme.colors.primary, lineWidth: Constants.Size.borderWidth)
                    .fill(theme.colors.background)
            )
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? Constants.Opacity.pressedSecondary : 1)
            .scaleEffect(configuration.isPressed ? Constants.Scale.pressed : Constants.Scale.normal)
            .animation(.easeInOut(duration: Constants.Animation.buttonDuration), value: configuration.isPressed)
    }
}

// MARK: - Convenience Extension

extension ButtonStyle where Self == DSSecondaryButtonStyle {
    /// Outlined secondary button style sourced from the current `AppTheme`.
    public static var dsSecondary: DSSecondaryButtonStyle { DSSecondaryButtonStyle() }
}
