//
//  AppTheme.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// Observable theme object injected via SwiftUI `@Environment`.
///
/// Holds all design tokens (colors, typography, spacing, radius) required
/// to render the UI consistently. Swap the instance at the root of the view
/// hierarchy to change the entire look of the app.
///
/// Usage:
/// ```swift
/// // Root
/// ContentView()
///     .environment(AppTheme.default)
///
/// // In views
/// @Environment(AppTheme.self) private var theme
/// ```
@MainActor
@Observable
public final class AppTheme {

    public var colors: ColorTokens
    public var typography: TypographyTokens
    public var spacing: SpacingTokens
    public var radius: RadiusTokens

    public init(
        colors: ColorTokens,
        typography: TypographyTokens = TypographyTokens(),
        spacing: SpacingTokens = SpacingTokens(),
        radius: RadiusTokens = RadiusTokens()
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.radius = radius
    }
}
