//
//  RadiusTokens.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// Corner radius scale for consistent rounding across UI elements.
public struct RadiusTokens: Sendable {

    public let sm: CGFloat
    public let md: CGFloat
    public let lg: CGFloat
    public let xl: CGFloat
    public let full: CGFloat

    public init(
        sm: CGFloat = Constants.Radius.sm,
        md: CGFloat = Constants.Radius.md,
        lg: CGFloat = Constants.Radius.lg,
        xl: CGFloat = Constants.Radius.xl,
        full: CGFloat = Constants.Radius.full
    ) {
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.full = full
    }
}
