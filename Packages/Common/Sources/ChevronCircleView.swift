import SwiftUI
import Theme

public struct ChevronCircleView: View {
    @Environment(AppTheme.self) private var theme

    private enum Layout {
        static let size: CGFloat = 32
        static let iconSize: CGFloat = 11
    }

    public init() {}

    public var body: some View {
        ZStack {
            Circle()
                .fill(theme.colors.background)
                .frame(width: Layout.size, height: Layout.size)
                .shadow(color: .black.opacity(0.08), radius: Constants.Spacing.xxs, x: 0, y: 1)

            Image(systemName: "chevron.right")
                .font(.system(size: Layout.iconSize, weight: .semibold))
                .foregroundStyle(theme.colors.textTertiary)
        }
    }
}
