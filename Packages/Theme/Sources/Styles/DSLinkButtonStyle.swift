import SwiftUI

/// Row-style button for external links — shows label + trailing arrow indicator.
public struct DSLinkButtonStyle: ButtonStyle {

    @Environment(AppTheme.self) private var theme

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .foregroundStyle(theme.colors.textPrimary)
            Spacer()
            Image(systemName: "arrow.up.right.square")
                .font(.footnote)
                .foregroundStyle(theme.colors.textTertiary)
        }
        .contentShape(Rectangle())
        .opacity(configuration.isPressed ? Constants.Opacity.pressedGhost : 1)
        .animation(.easeInOut(duration: Constants.Animation.ghostDuration), value: configuration.isPressed)
    }
}

// MARK: - Convenience Extension

extension ButtonStyle where Self == DSLinkButtonStyle {
    /// Link button style with trailing external-link indicator.
    public static var dsLink: DSLinkButtonStyle { DSLinkButtonStyle() }
}
