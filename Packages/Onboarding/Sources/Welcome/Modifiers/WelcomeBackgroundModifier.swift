//
//  WelcomeBackgroundModifier.swift
//  Onboarding
//
//  Created by ShredMate on 06/04/2026.
//

import SwiftUI
import Theme

// MARK: - Modifier

/// Paints the edge-to-edge background used by the welcome screen.
///
/// Blends the current theme's brand primary into the app background so the
/// screen reads as "branded hero" without dropping off the theme tokens.
private struct WelcomeBackgroundModifier: ViewModifier {

    @Environment(AppTheme.self) private var theme

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [
                        theme.colors.primary.opacity(Self.topOpacity),
                        theme.colors.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
    }

    // MARK: - Tuning

    private static let topOpacity: Double = 0.28
}

// MARK: - View Extension

extension View {

    /// Applies the first-run welcome screen branded background.
    func welcomeBackground() -> some View {
        modifier(WelcomeBackgroundModifier())
    }
}
