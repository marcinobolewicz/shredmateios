import SwiftUI
import Theme

/// A compact banner that slides in from the top of the screen.
///
/// Styled to match the app's design system tokens.
/// Supports tap-to-dismiss and an optional tap callback.
struct InAppNotificationBanner: View {
    let notification: InAppNotification
    var onTap: (() -> Void)?
    var onDismiss: (() -> Void)?

    @Environment(AppTheme.self) private var theme

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "message.fill")
                .font(.title3)
                .foregroundStyle(theme.colors.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(theme.typography.headline)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)

                Text(notification.body)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        )
        .padding(.horizontal, theme.spacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
            onDismiss?()
        }
    }
}
