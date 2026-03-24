import SwiftUI
import Theme

struct MentorSlotCard: View {
    @Environment(AppTheme.self) private var theme

    let viewData: MentorSlotRowViewData

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(viewData.timeRange)
                .dsTextStyle(.heading)

            Text(viewData.duration)
                .dsTextStyle(.caption)

            Text(viewData.price)
                .dsTextStyle(.subheadline)
                .foregroundStyle(theme.colors.primary)
        }
        .padding(theme.spacing.sm)
        .frame(minWidth: 120, alignment: .leading)
        .background(theme.colors.surfaceTertiary)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md))
    }
}
