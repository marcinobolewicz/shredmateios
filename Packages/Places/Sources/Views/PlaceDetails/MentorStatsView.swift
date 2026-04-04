import SwiftUI
import Theme

struct MentorStatsView: View {
    @Environment(AppTheme.self) private var theme

    let sessionCount: Int
    let recommendationCount: Int

    var body: some View {
        HStack(spacing: theme.spacing.md) {
            statItem(
                icon: "person.2.fill",
                text: PlacesStrings.mentorSessions(sessionCount)
            )
            statItem(
                icon: "hand.thumbsup.fill",
                text: PlacesStrings.mentorRecommendations(recommendationCount)
            )
            Spacer(minLength: 0)
        }
    }

    private func statItem(icon: String, text: String) -> some View {
        HStack(spacing: theme.spacing.xs) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundStyle(theme.colors.primary)
            Text(text)
                .dsTextStyle(.footnote)
                .foregroundStyle(theme.colors.textSecondary)
        }
    }
}
