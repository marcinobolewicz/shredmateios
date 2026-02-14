//
//  Constants.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

// MARK: - Design Constants

/// Centralized design constants eliminating magic values across the theme.
/// All numeric literals used in styles, components, and modifiers are sourced from here.
public enum Constants {

    // MARK: - Spacing

    public enum Spacing {
        public static let xxs: CGFloat = 4
        public static let xs: CGFloat = 8
        public static let sm: CGFloat = 12
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let xxl: CGFloat = 48
    }

    // MARK: - Radius

    public enum Radius {
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 24
        public static let full: CGFloat = 9999
    }

    // MARK: - Size

    public enum Size {
        public static let buttonMinHeight: CGFloat = 50
        public static let iconFrame: CGFloat = 20
        public static let borderWidth: CGFloat = 1.5
        public static let focusBorderWidth: CGFloat = 2
        public static let fieldMinHeight: CGFloat = 56
        public static let floatingLabelScale: CGFloat = 0.75
    }

    // MARK: - Opacity

    public enum Opacity {
        public static let pressed: Double = 0.85
        public static let pressedSecondary: Double = 0.75
        public static let pressedGhost: Double = 0.6
        public static let disabled: Double = 0.5
        public static let overlay: Double = 0.25
    }

    // MARK: - Scale

    public enum Scale {
        public static let pressed: CGFloat = 0.98
        public static let normal: CGFloat = 1.0
    }

    // MARK: - Animation

    public enum Animation {
        public static let buttonDuration: Double = 0.15
        public static let focusDuration: Double = 0.2
        public static let floatingLabelDuration: Double = 0.15
        public static let chipDuration: Double = 0.18
        public static let ghostDuration: Double = 0.1
    }
}
