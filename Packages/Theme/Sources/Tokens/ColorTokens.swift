//
//  ColorTokens.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// Semantic color palette for the entire application.
/// Uses `UIColor` system colors for automatic light/dark mode adaptation.
public struct ColorTokens: Sendable {

    // MARK: - Brand

    public let primary: Color
    public let primaryForeground: Color
    public let accent: Color
    public let accentForeground: Color

    // MARK: - Semantic

    public let error: Color
    public let errorForeground: Color
    public let success: Color
    public let successForeground: Color
    public let warning: Color
    public let warningForeground: Color

    // MARK: - Surface

    public let background: Color
    public let backgroundSecondary: Color
    public let surface: Color
    public let surfaceSecondary: Color
    public let surfaceTertiary: Color

    // MARK: - Text

    public let textPrimary: Color
    public let textSecondary: Color
    public let textTertiary: Color
    public let textInverse: Color

    // MARK: - Border

    public let border: Color
    public let borderFocused: Color

    // MARK: - Init

    public init(
        primary: Color,
        primaryForeground: Color,
        accent: Color,
        accentForeground: Color,
        error: Color,
        errorForeground: Color,
        success: Color,
        successForeground: Color,
        warning: Color,
        warningForeground: Color,
        background: Color,
        backgroundSecondary: Color,
        surface: Color,
        surfaceSecondary: Color,
        surfaceTertiary: Color,
        textPrimary: Color,
        textSecondary: Color,
        textTertiary: Color,
        textInverse: Color,
        border: Color,
        borderFocused: Color
    ) {
        self.primary = primary
        self.primaryForeground = primaryForeground
        self.accent = accent
        self.accentForeground = accentForeground
        self.error = error
        self.errorForeground = errorForeground
        self.success = success
        self.successForeground = successForeground
        self.warning = warning
        self.warningForeground = warningForeground
        self.background = background
        self.backgroundSecondary = backgroundSecondary
        self.surface = surface
        self.surfaceSecondary = surfaceSecondary
        self.surfaceTertiary = surfaceTertiary
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textTertiary = textTertiary
        self.textInverse = textInverse
        self.border = border
        self.borderFocused = borderFocused
    }
}
