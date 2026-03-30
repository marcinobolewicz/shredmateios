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
            primary: Color(
                light: Color(red: 0.50, green: 0.40, blue: 0.82),
                dark: Color(red: 0.65, green: 0.55, blue: 0.95)
            ),
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

            // Surface — grouped layout with custom dark-mode elevation
            background: Color(
                light: Color(.secondarySystemGroupedBackground),
                dark: Color(white: 0.11)
            ),
            backgroundSecondary: Color(.systemGroupedBackground),
            surface: Color(.tertiarySystemGroupedBackground),
            surfaceSecondary: Color(.tertiarySystemBackground),
            surfaceTertiary: Color(.systemGray5),

            // Text — automatically adapts to light/dark mode
            textPrimary: Color(.label),
            textSecondary: Color(.secondaryLabel),
            textTertiary: Color(.tertiaryLabel),
            textInverse: Color(light: .white, dark: .black),

            // Border
            border: Color(.separator),
            borderFocused: Color(
                light: Color(red: 0.40, green: 0.30, blue: 0.75),
                dark: Color(red: 0.65, green: 0.55, blue: 0.95)
            )
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
