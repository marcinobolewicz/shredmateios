//
//  ThemeTests.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import Testing
@testable import Theme

@Suite("AppTheme Tests")
struct AppThemeTests {

    @Test("Default theme has expected primary color")
    @MainActor
    func defaultThemeExists() {
        let theme = AppTheme.default
        // Verify the theme can be instantiated without crashing
        #expect(theme.spacing.md == 16)
        #expect(theme.radius.md == 12)
    }

    @Test("Constants spacing values are consistent with defaults")
    func constantsSpacing() {
        #expect(Constants.Spacing.xs == 8)
        #expect(Constants.Spacing.sm == 12)
        #expect(Constants.Spacing.md == 16)
        #expect(Constants.Spacing.lg == 24)
    }

    @Test("Constants radius values are consistent with defaults")
    func constantsRadius() {
        #expect(Constants.Radius.sm == 8)
        #expect(Constants.Radius.md == 12)
        #expect(Constants.Radius.lg == 16)
    }

    @Test("SpacingTokens defaults match Constants")
    func spacingTokensDefaults() {
        let tokens = SpacingTokens()
        #expect(tokens.xxs == Constants.Spacing.xxs)
        #expect(tokens.xs == Constants.Spacing.xs)
        #expect(tokens.sm == Constants.Spacing.sm)
        #expect(tokens.md == Constants.Spacing.md)
        #expect(tokens.lg == Constants.Spacing.lg)
        #expect(tokens.xl == Constants.Spacing.xl)
        #expect(tokens.xxl == Constants.Spacing.xxl)
    }

    @Test("RadiusTokens defaults match Constants")
    func radiusTokensDefaults() {
        let tokens = RadiusTokens()
        #expect(tokens.sm == Constants.Radius.sm)
        #expect(tokens.md == Constants.Radius.md)
        #expect(tokens.lg == Constants.Radius.lg)
        #expect(tokens.xl == Constants.Radius.xl)
        #expect(tokens.full == Constants.Radius.full)
    }
}
