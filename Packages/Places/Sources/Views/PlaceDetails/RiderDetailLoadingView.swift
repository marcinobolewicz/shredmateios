import SwiftUI
import Networking
import Common

/// Wrapper that fetches full rider profile before showing RiderCardView.
/// Ensures consistent experience (description + mentor slots) regardless of entry point.
public struct RiderDetailLoadingView: View {
    let partialViewData: RiderCardViewData
    let riderService: any RiderServiceProtocol
    let mentorSlotsService: any MentorSlotsServiceProtocol
    let onMessageTap: (_ userId: UUID, _ displayName: String) -> Void

    @Environment(FollowRepository.self) private var followRepository
    @State private var fullRider: Rider?
    @State private var state: LoadState = .idle

    public init(
        partialViewData: RiderCardViewData,
        riderService: any RiderServiceProtocol,
        mentorSlotsService: any MentorSlotsServiceProtocol,
        onMessageTap: @escaping (_ userId: UUID, _ displayName: String) -> Void = { _, _ in }
    ) {
        self.partialViewData = partialViewData
        self.riderService = riderService
        self.mentorSlotsService = mentorSlotsService
        self.onMessageTap = onMessageTap
    }

    public var body: some View {
        Group {
            switch state {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded:
                RiderCardView(
                    viewData: resolvedViewData,
                    followRepository: followRepository,
                    mentorSlotsService: mentorSlotsService,
                    onMessageTap: onMessageTap
                )

            case .failed:
                // Fallback: show card with partial data (no full description)
                RiderCardView(
                    viewData: partialViewData,
                    followRepository: followRepository,
                    mentorSlotsService: mentorSlotsService,
                    onMessageTap: onMessageTap
                )
            }
        }
        .task { await load() }
    }

    private var isMentor: Bool {
        if let type = fullRider?.type {
            return type == .mentor || type == .both
        }
        return partialViewData.isMentor
    }

    private var resolvedViewData: RiderCardViewData {
        guard
            let r = fullRider,
            let userId = UUID(uuidString: r.userId)
        else { return partialViewData }

        return RiderCardViewData(
            id: r.id,
            riderId: r.id,
            userId: userId,
            displayName: r.displayName ?? partialViewData.displayName,
            avatarInitials: partialViewData.avatarInitials,
            avatarURL: r.avatarUrl.flatMap(URL.init) ?? partialViewData.avatarURL,
            description: r.description ?? partialViewData.description,
            hasHomeLocation: partialViewData.hasHomeLocation,
            isMentor: isMentor
        )
    }

    private func load() async {
        state = .loading
        do {
            fullRider = try await riderService.fetchRider(id: partialViewData.riderId.uuidString.lowercased())
            state = .loaded
        } catch {
            state = .failed(.from(error))
        }
    }
}
