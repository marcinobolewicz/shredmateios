//
//  DSGhostButtonStyle.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// Transparent text-only button used for tertiary/link actions (e.g. "Forgot Password?").
///
/// No background or border — just tinted text with a subtle press effect.
public struct DSGhostButtonStyle: ButtonStyle {

    @Environment(AppTheme.self) private var theme

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(theme.colors.primary)
            .opacity(configuration.isPressed ? Constants.Opacity.pressedGhost : 1)
            .animation(.easeInOut(duration: Constants.Animation.ghostDuration), value: configuration.isPressed)
    }
}

// MARK: - Convenience Extension

extension ButtonStyle where Self == DSGhostButtonStyle {
    /// Transparent ghost button style sourced from the current `AppTheme`.
    public static var dsGhost: DSGhostButtonStyle { DSGhostButtonStyle() }
}
