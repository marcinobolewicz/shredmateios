//
//  AppTheme+Default.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

// MARK: - Default ShredMate Theme

extension AppTheme {

    /// The default ShredMate theme.
    ///
    /// All surface and text colors use `UIColor` semantic system colors,
    /// so they automatically adapt to light and dark appearance.
    public static let `default` = AppTheme(
        colors: ColorTokens(
            // Brand
            primary: Color(.systemBlue),
            primaryForeground: .white,
            accent: Color(red: 0.47, green: 0.32, blue: 0.91),
            accentForeground: .white,

            // Semantic
            error: Color(.systemRed),
            errorForeground: .white,
            success: Color(.systemGreen),
            successForeground: .white,
            warning: Color(.systemOrange),
            warningForeground: .white,

            // Surface — automatically adapts to light/dark mode
            background: Color(.systemBackground),
            surface: Color(.secondarySystemBackground),
            surfaceSecondary: Color(.tertiarySystemBackground),
            surfaceTertiary: Color(.systemGray6),

            // Text — automatically adapts to light/dark mode
            textPrimary: Color(.label),
            textSecondary: Color(.secondaryLabel),
            textTertiary: Color(.tertiaryLabel),
            textInverse: Color(light: .white, dark: .black),

            // Border
            border: Color(.separator),
            borderFocused: Color(.systemBlue)
        )
    )
}

// MARK: - Adaptive Color Initializer

extension Color {

    /// Creates a color that adapts to the current `UIUserInterfaceStyle`.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}
