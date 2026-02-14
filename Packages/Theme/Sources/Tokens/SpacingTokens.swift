//
//  SpacingTokens.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// Spacing scale for consistent whitespace and padding throughout the app.
public struct SpacingTokens: Sendable {

    public let xxs: CGFloat
    public let xs: CGFloat
    public let sm: CGFloat
    public let md: CGFloat
    public let lg: CGFloat
    public let xl: CGFloat
    public let xxl: CGFloat

    public init(
        xxs: CGFloat = Constants.Spacing.xxs,
        xs: CGFloat = Constants.Spacing.xs,
        sm: CGFloat = Constants.Spacing.sm,
        md: CGFloat = Constants.Spacing.md,
        lg: CGFloat = Constants.Spacing.lg,
        xl: CGFloat = Constants.Spacing.xl,
        xxl: CGFloat = Constants.Spacing.xxl
    ) {
        self.xxs = xxs
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
    }
}
