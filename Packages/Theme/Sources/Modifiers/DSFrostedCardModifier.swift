//
//  DSFrostedCardModifier.swift
//  Theme
//

import SwiftUI

/// Wraps content in a frosted glass card with rounded corners.
///
/// Pairs `.ultraThinMaterial` with the theme's extra-large radius and
/// `theme.spacing.lg` padding so the same treatment appears wherever a card
/// is overlaid on a photographic background (welcome, auth flow).
///
/// Usage:
/// ```swift
/// VStack { ... }
///     .dsFrostedCard()
/// ```
private struct DSFrostedCardModifier: ViewModifier {

    @Environment(AppTheme.self) private var theme

    func body(content: Content) -> some View {
        content
            .padding(theme.spacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
            )
    }
}

extension View {

    /// Applies frosted glass card styling: padded content over `.ultraThinMaterial`.
    public func dsFrostedCard() -> some View {
        modifier(DSFrostedCardModifier())
    }
}
