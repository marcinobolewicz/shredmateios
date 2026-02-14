//
//  DSTextStyle.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

// MARK: - Variant

/// Semantic text variants mapping to `TypographyTokens` and default color rules.
public enum DSTextVariant {
    case largeTitle
    case title
    case title2
    case title3
    case heading
    case body
    case callout
    case subheadline
    case footnote
    case caption
}

// MARK: - Modifier

/// Applies themed font, weight, and color to any `View` (typically `Text`).
///
/// Usage:
/// ```swift
/// Text("Hello")
///     .dsTextStyle(.heading)
///
/// Text("Error")
///     .dsTextStyle(.caption, color: \.error)
/// ```
private struct DSTextStyleModifier: ViewModifier {

    @Environment(AppTheme.self) private var theme

    let variant: DSTextVariant
    let color: KeyPath<ColorTokens, Color>?

    func body(content: Content) -> some View {
        content
            .font(font)
            .fontWeight(weight)
            .foregroundStyle(resolvedColor)
    }

    // MARK: - Private Helpers

    private var font: Font {
        switch variant {
        case .largeTitle:  theme.typography.largeTitle
        case .title:       theme.typography.title
        case .title2:      theme.typography.title2
        case .title3:      theme.typography.title3
        case .heading:     theme.typography.headline
        case .body:        theme.typography.body
        case .callout:     theme.typography.callout
        case .subheadline: theme.typography.subheadline
        case .footnote:    theme.typography.footnote
        case .caption:     theme.typography.caption
        }
    }

    private var weight: Font.Weight? {
        switch variant {
        case .largeTitle, .title:           .bold
        case .title2, .title3, .heading:    .semibold
        default:                            nil
        }
    }

    private var resolvedColor: Color {
        if let color {
            return theme.colors[keyPath: color]
        }
        switch variant {
        case .caption, .footnote, .subheadline:
            return theme.colors.textSecondary
        default:
            return theme.colors.textPrimary
        }
    }
}

// MARK: - View Extension

extension View {

    /// Applies a themed text style with an optional explicit color override.
    ///
    /// - Parameters:
    ///   - variant: The semantic text variant to apply.
    ///   - color: An optional key path into `ColorTokens` to override the default color.
    public func dsTextStyle(
        _ variant: DSTextVariant,
        color: KeyPath<ColorTokens, Color>? = nil
    ) -> some View {
        modifier(DSTextStyleModifier(variant: variant, color: color))
    }
}
