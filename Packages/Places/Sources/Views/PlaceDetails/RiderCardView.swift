import SwiftUI
import Theme

public struct RiderCardViewData: Equatable, Hashable, Sendable, Identifiable {
    public let id: String
    public let riderId: UUID
    public let userId: UUID
    public let displayName: String
    public let avatarInitials: String
    public let avatarURL: URL?
    public let description: String

    public init(
        id: String,
        riderId: UUID,
        userId: UUID,
        displayName: String,
        avatarInitials: String,
        avatarURL: URL?,
        description: String
    ) {
        self.id = id
        self.riderId = riderId
        self.userId = userId
        self.displayName = displayName
        self.avatarInitials = avatarInitials
        self.avatarURL = avatarURL
        self.description = description
    }
}

struct RiderCardView: View {
    @Environment(AppTheme.self) private var theme

    let viewData: RiderCardViewData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                header
                descriptionSection
                messageButton
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, theme.spacing.md)
            .padding(.top, theme.spacing.md)
            .padding(.bottom, theme.spacing.lg)
        }
        .background(theme.colors.background)
        .navigationTitle(viewData.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: theme.spacing.md) {
            avatar

            Text(viewData.displayName)
                .dsTextStyle(.title)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var avatar: some View {
        if let avatarURL = viewData.avatarURL {
            AsyncImage(url: avatarURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                avatarFallback
            }
            .frame(width: 88, height: 88)
            .clipShape(Circle())
        } else {
            avatarFallback
        }
    }

    private var avatarFallback: some View {
        ZStack {
            Circle().fill(theme.colors.surfaceTertiary)
            Text(viewData.avatarInitials)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(theme.colors.textSecondary)
        }
        .frame(width: 88, height: 88)
    }

    @ViewBuilder
    private var descriptionSection: some View {
        if !viewData.description.isEmpty {
            Text(viewData.description)
                .dsTextStyle(.subheadline)
                .foregroundStyle(theme.colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var messageButton: some View {
        Button("Napisz wiadomość") {}
            .buttonStyle(.dsPrimary)
    }
}
