import SwiftUI
import Theme
import Networking
import Payment

public struct RiderCardViewData: Equatable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public let riderId: UUID
    public let userId: UUID?
    public let displayName: String
    public let avatarInitials: String
    public let avatarURL: URL?
    public let description: String
    public let hasHomeLocation: Bool
    public let isMentor: Bool

    public init(
        id: UUID,
        riderId: UUID,
        userId: UUID?,
        displayName: String,
        avatarInitials: String,
        avatarURL: URL?,
        description: String,
        hasHomeLocation: Bool = false,
        isMentor: Bool = false
    ) {
        self.id = id
        self.riderId = riderId
        self.userId = userId
        self.displayName = displayName
        self.avatarInitials = avatarInitials
        self.avatarURL = avatarURL
        self.description = description
        self.hasHomeLocation = hasHomeLocation
        self.isMentor = isMentor
    }
}

public struct RiderCardView: View {
    @Environment(AppTheme.self) private var theme

    let viewData: RiderCardViewData
    let isOwnProfile: Bool
    let onMessageTap: (_ userId: UUID, _ displayName: String) -> Void
    @State private var viewModel: RiderCardViewModel
    @State private var slotsViewModel: MentorSlotsViewModel?

    public init(
        viewData: RiderCardViewData,
        followRepository: FollowRepository,
        mentorSlotsService: (any MentorSlotsServiceProtocol)? = nil,
        stripePaymentService: StripePaymentService? = nil,
        currentRiderId: String? = nil,
        onMessageTap: @escaping (_ userId: UUID, _ displayName: String) -> Void = { _, _ in }
    ) {
        self.viewData = viewData
        self.onMessageTap = onMessageTap
        let riderIdString = viewData.riderId.uuidString.lowercased()
        self.isOwnProfile = currentRiderId == riderIdString
        _viewModel = State(wrappedValue: RiderCardViewModel(
            riderId: riderIdString,
            followRepository: followRepository
        ))
        if let service = mentorSlotsService {
            _slotsViewModel = State(wrappedValue: MentorSlotsViewModel(
                mentorRiderId: riderIdString,
                currentRiderId: currentRiderId,
                service: service,
                stripePaymentService: stripePaymentService
            ))
        }
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                header
                descriptionSection
                mentorStatsSection
                if !isOwnProfile {
                    actionButtons
                }
                mentorSlotsContent
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, theme.spacing.md)
            .padding(.top, theme.spacing.md)
            .padding(.bottom, theme.spacing.lg)
        }
        .background(theme.colors.backgroundSecondary)
        .navigationTitle(viewData.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            async let follow: Void = viewModel.loadOnAppear()
            async let slots: Void = slotsViewModel?.refresh() ?? ()
            _ = await (follow, slots)
        }
        .task { await viewModel.loadOnAppear() }
        .task { await slotsViewModel?.loadSlots() }
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

    @ViewBuilder
    private var mentorStatsSection: some View {
        if let slotsVM = slotsViewModel,
           let sessions = slotsVM.sessionCount, sessions > 0,
           let recommendations = slotsVM.recommendationCount, recommendations > 0 {
            MentorStatsView(
                sessionCount: sessions,
                recommendationCount: recommendations
            )
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

    @ViewBuilder
    private var messageButton: some View {
        if let userId = viewData.userId {
            Button(PlacesStrings.messageButton.localized) {
                onMessageTap(userId, viewData.displayName)
            }
            .buttonStyle(.dsGhost)
        }
    }

    // MARK: - Mentor Slots

    @ViewBuilder
    private var mentorSlotsContent: some View {
        if let slotsVM = slotsViewModel {
            if slotsVM.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 60)
            } else if slotsVM.hasSlots {
                Divider()
                    .padding(.vertical, theme.spacing.xs)
                MentorSlotsSection(viewModel: slotsVM)
            }
        }
    }
}
