//
//  DSFrostedCardModifier.swift
//  Theme
//

import SwiftUI

/// Wraps content in a frosted glass card with a dark tint and rounded corners.
///
/// `.ultraThinMaterial` alone is too bright in light mode for white text to
/// read on photographic backgrounds, so we layer a translucent black fill
/// on top of the material. The result is a consistently darkened frosted
/// surface across light and dark mode, where the brand foreground white is
/// always legible.
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
            .background {
                ZStack {
                    shape.fill(.ultraThinMaterial)
                    shape.fill(Color.black.opacity(Self.darkOverlayOpacity))
                }
            }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
    }

    private static let darkOverlayOpacity: Double = 0.35
}

extension View {

    /// Applies dark frosted glass card styling: padded content over a dimmed
    /// `.ultraThinMaterial`, clipped to the theme's extra-large radius.
    public func dsFrostedCard() -> some View {
        modifier(DSFrostedCardModifier())
    }
}
