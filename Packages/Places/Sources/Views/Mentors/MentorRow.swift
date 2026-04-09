import SwiftUI
import Theme
import Common
import Networking

struct MentorRow: View {
    @Environment(AppTheme.self) private var theme
    let mentor: MentorListItem

    private enum Layout {
        static let avatarSize: CGFloat = 56
    }

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            AvatarView(url: avatarURL, initials: initials, size: Layout.avatarSize)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(mentor.displayName ?? PlacesStrings.spotSubtitlePlaceholder.localized)
                    .dsTextStyle(.body)
                    .lineLimit(1)

                if let subtitle = sportsSubtitle {
                    Text(subtitle)
                        .dsTextStyle(.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                }

                MentorStatsView(
                    sessionCount: mentor.sessionCount,
                    recommendationCount: mentor.recommendationCount
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(alignment: .trailing) {
            ChevronCircleView()
        }
        .padding(.vertical, theme.spacing.sm)
        .contentShape(Rectangle())
    }



    // MARK: - Helpers

    var initials: String {
        Self.initials(for: mentor.displayName)
    }

    static func initials(for name: String?) -> String {
        guard let name, !name.isEmpty else { return "?" }
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private var avatarURL: URL? {
        mentor.avatarUrl.flatMap(URL.init(string:))
    }

    private var sportsSubtitle: String? {
        let names = mentor.riderSports.map(\.sport.name)
        return names.isEmpty ? nil : names.joined(separator: " · ")
    }
}
