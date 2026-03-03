import SwiftUI
import Theme

struct PlaceRiderRow: View {
    @Environment(AppTheme.self) private var theme
    let viewData: PlaceRiderRowViewData

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            avatarView()

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(viewData.displayName)
                    .dsTextStyle(.body)
                    .lineLimit(1)

                Text(viewData.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func avatarView() -> some View {
        if let url = viewData.avatarURL {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                initialsAvatarView()
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
        } else {
            initialsAvatarView()
        }
    }

    private func initialsAvatarView() -> some View {
        ZStack {
            Circle().fill(theme.colors.surfaceTertiary)
            Text(viewData.avatarInitials)
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
        }
        .frame(width: 40, height: 40)
    }
}
