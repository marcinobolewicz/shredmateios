import SwiftUI
import Theme
import Networking

public struct RiderCardViewData: Equatable, Hashable, Sendable, Identifiable {
    public let id: String
    public let riderId: UUID
    public let userId: UUID
    public let displayName: String
    public let avatarInitials: String
    public let avatarURL: URL?
    public let description: String
    public let hasHomeLocation: Bool

    public init(
        id: String,
        riderId: UUID,
        userId: UUID,
        displayName: String,
        avatarInitials: String,
        avatarURL: URL?,
        description: String,
        hasHomeLocation: Bool = false
    ) {
        self.id = id
        self.riderId = riderId
        self.userId = userId
        self.displayName = displayName
        self.avatarInitials = avatarInitials
        self.avatarURL = avatarURL
        self.description = description
        self.hasHomeLocation = hasHomeLocation
    }
}

public struct RiderCardView: View {
    @Environment(AppTheme.self) private var theme

    let viewData: RiderCardViewData
    let onMessageTap: (_ userId: UUID, _ displayName: String) -> Void
    @State private var viewModel: RiderCardViewModel

    public init(
        viewData: RiderCardViewData,
        followRepository: FollowRepository,
        onMessageTap: @escaping (_ userId: UUID, _ displayName: String) -> Void = { _, _ in }
    ) {
        self.viewData = viewData
        self.onMessageTap = onMessageTap
        _viewModel = State(wrappedValue: RiderCardViewModel(
            riderId: viewData.riderId.uuidString,
            followRepository: followRepository
        ))
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                header
                descriptionSection
                actionButtons
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
        .task { await viewModel.loadOnAppear() }
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

    private var avatarSize: CGFloat { viewData.hasHomeLocation ? 132 : 88 }

    @ViewBuilder
    private var avatar: some View {
        if let avatarURL = viewData.avatarURL {
            AsyncImage(url: avatarURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                avatarFallback
            }
            .frame(width: avatarSize, height: avatarSize)
            .clipShape(Circle())
        } else {
            avatarFallback
        }
    }

    private var avatarFallback: some View {
        ZStack {
            Circle().fill(theme.colors.surfaceTertiary)
            Text(viewData.avatarInitials)
                .font(.system(size: avatarSize * 0.34, weight: .bold))
                .foregroundStyle(theme.colors.textSecondary)
        }
        .frame(width: avatarSize, height: avatarSize)
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

    private var actionButtons: some View {
        HStack(spacing: theme.spacing.sm) {
            followButton
            messageButton
            Spacer()
        }
    }

    @ViewBuilder
    private var followButton: some View {
        Button(action: viewModel.toggleFollow) {
            if viewModel.isLoading {
                ProgressView().controlSize(.small)
            } else {
                Text(viewModel.isFollowing ? PlacesStrings.unfollowButton.localized : PlacesStrings.followButton.localized)
            }
        }
        .buttonStyle(.dsOutline)
        .disabled(viewModel.isLoading)
    }

    private var messageButton: some View {
        Button(PlacesStrings.messageButton.localized) {
            onMessageTap(viewData.userId, viewData.displayName)
        }
        .buttonStyle(.dsGhost)
    }
}
