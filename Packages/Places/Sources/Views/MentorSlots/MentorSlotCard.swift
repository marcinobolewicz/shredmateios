import SwiftUI
import Theme

struct MentorSlotCard: View {
    @Environment(AppTheme.self) private var theme

    let viewData: MentorSlotRowViewData
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(viewData.timeRange)
                    .dsTextStyle(.heading)

                Text(viewData.duration)
                    .dsTextStyle(.caption)

                Text(viewData.sportName)
                    .dsTextStyle(.caption)
                    .foregroundStyle(theme.colors.textSecondary)

                if let placeName = viewData.placeName {
                    Text(placeName)
                        .dsTextStyle(.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                }

                Text(viewData.price)
                    .dsTextStyle(.subheadline)
                    .foregroundStyle(theme.colors.primary)
            }
            .padding(theme.spacing.md)
            .frame(minWidth: 150, alignment: .leading)
            .background(theme.colors.surfaceTertiary)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
        }
        .buttonStyle(.plain)
    }
}
