import SwiftUI
import Theme

struct ContactView: View {
    @Environment(AppTheme.self) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                headerSection
                contactOptions
            }
            .padding(theme.spacing.md)
        }
        .background(theme.colors.backgroundSecondary)
        .navigationTitle(ProfileStrings.contactTitle.localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Image(systemName: "envelope.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(theme.colors.primary)

            Text(ProfileStrings.contactDescription.localized)
                .dsTextStyle(.body)
                .foregroundStyle(theme.colors.textSecondary)
        }
    }

    private var contactOptions: some View {
        VStack(spacing: theme.spacing.sm) {
            contactRow(
                icon: "envelope.fill",
                title: ProfileStrings.contactEmailLabel.localized,
                value: "support@shredmate.eu",
                url: URL(string: "mailto:support@shredmate.eu")
            )

            contactRow(
                icon: "globe",
                title: ProfileStrings.contactWebsiteLabel.localized,
                value: "shredmate.eu",
                url: URL(string: "https://shredmate.eu")
            )
        }
    }

    private func contactRow(icon: String, title: String, value: String, url: URL?) -> some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(theme.colors.primary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(title)
                    .dsTextStyle(.caption)

                if let url {
                    Link(value, destination: url)
                        .font(.subheadline.weight(.medium))
                        .tint(theme.colors.primary)
                } else {
                    Text(value)
                        .dsTextStyle(.body)
                }
            }

            Spacer()
        }
        .padding(theme.spacing.md)
        .background(theme.colors.background)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
    }
}
