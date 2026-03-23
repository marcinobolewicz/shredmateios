import SwiftUI
import Networking
import Common
import Places

struct FeedRiderDetailView: View {
    let rider: ActivityPostRider
    let riderService: any RiderServiceProtocol
    let onMessageTap: (_ userId: UUID, _ displayName: String) -> Void

    @Environment(FollowRepository.self) private var followRepository
    @State private var fullRider: Rider?
    @State private var state: LoadState = .idle

    var body: some View {
        Group {
            switch state {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded:
                if let viewData {
                    RiderCardView(
                        viewData: viewData,
                        followRepository: followRepository,
                        onMessageTap: onMessageTap
                    )
                }

            case .failed:
                ContentUnavailableView(
                    "Nie udało się załadować profilu",
                    systemImage: "person.slash"
                )
            }
        }
        .task { await load() }
    }

    private var viewData: RiderCardViewData? {
        guard
            let r = fullRider,
            let riderId = UUID(uuidString: r.id),
            let userId = UUID(uuidString: r.userId)
        else { return nil }

        return RiderCardViewData(
            id: r.id,
            riderId: riderId,
            userId: userId,
            displayName: r.displayName ?? rider.displayName,
            avatarInitials: rider.initials,
            avatarURL: r.avatarUrl.flatMap(URL.init),
            description: r.description ?? ""
        )
    }

    private func load() async {
        state = .loading
        do {
            fullRider = try await riderService.fetchRider(id: rider.id)
            state = .loaded
        } catch {
            state = .failed(.from(error))
        }
    }
}
