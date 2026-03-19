import SwiftUI

/// Compact pill-shaped outlined button for inline actions (e.g. "Follow", "Check In").
///
/// Fits its content — no full-width stretching. Smaller than `dsSecondary`.
public struct DSOutlineButtonStyle: ButtonStyle {

    @Environment(AppTheme.self) private var theme

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundStyle(theme.colors.primary)
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.vertical, Constants.Spacing.xs)
            .background(
                Capsule()
                    .stroke(theme.colors.primary, lineWidth: Constants.Size.borderWidth)
            )
            .opacity(configuration.isPressed ? Constants.Opacity.pressedSecondary : 1)
            .scaleEffect(configuration.isPressed ? Constants.Scale.pressed : Constants.Scale.normal)
            .animation(.easeInOut(duration: Constants.Animation.buttonDuration), value: configuration.isPressed)
    }
}

// MARK: - Convenience Extension

extension ButtonStyle where Self == DSOutlineButtonStyle {
    /// Compact outlined button style that fits its content.
    public static var dsOutline: DSOutlineButtonStyle { DSOutlineButtonStyle() }
}
