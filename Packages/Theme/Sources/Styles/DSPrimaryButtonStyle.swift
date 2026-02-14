//
//  DSPrimaryButtonStyle.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// Full-width filled button used for primary actions (e.g. "Sign In").
///
/// Reads colors and radius from `AppTheme` via `@Environment`.
/// Supports pressed animation and disabled state out of the box.
public struct DSPrimaryButtonStyle: ButtonStyle {

    @Environment(AppTheme.self) private var theme

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(theme.colors.primaryForeground)
            .frame(maxWidth: .infinity, minHeight: Constants.Size.buttonMinHeight)
            .background(
                Capsule()
                    .fill(theme.colors.primary)
            )
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? Constants.Opacity.pressed : 1)
            .scaleEffect(configuration.isPressed ? Constants.Scale.pressed : Constants.Scale.normal)
            .animation(.easeInOut(duration: Constants.Animation.buttonDuration), value: configuration.isPressed)
    }
}

// MARK: - Convenience Extension

extension ButtonStyle where Self == DSPrimaryButtonStyle {
    /// Filled primary button style sourced from the current `AppTheme`.
    public static var dsPrimary: DSPrimaryButtonStyle { DSPrimaryButtonStyle() }
}
