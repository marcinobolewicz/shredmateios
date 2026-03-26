import SwiftUI

/// Wraps content in a themed card container with rounded corners and elevated background.
///
/// Usage:
/// ```swift
/// LazyVStack { ... }
///     .dsCard()
/// ```
private struct DSCardModifier: ViewModifier {
    @Environment(AppTheme.self) private var theme

    func body(content: Content) -> some View {
        content
            .padding(.vertical, theme.spacing.xs)
            .background(theme.colors.background)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
            .padding(.horizontal, theme.spacing.md)
    }
}

extension View {

    /// Applies card styling: vertical padding, background, rounded corners, horizontal margin.
    public func dsCard() -> some View {
        modifier(DSCardModifier())
    }
}
