import SwiftUI
import Networking
import Places
import Common

struct FeedNavigationDestinations: ViewModifier {
    let feedService: any FeedServiceProtocol
    let placesService: any PlacesServiceProtocol
    let riderService: any RiderServiceProtocol
    let router: FeedRouter

    @Environment(AuthState.self) private var authState
    @Environment(FollowRepository.self) private var followRepository

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: FeedRoute.self) { route in
                feedDestination(for: route)
            }
            // Handles NavigationLink(value: PlacesRoute) inside PlaceDetailsView
            .navigationDestination(for: PlacesRoute.self) { route in
                placesDestination(for: route)
            }
    }

    @ViewBuilder
    private func feedDestination(for route: FeedRoute) -> some View {
        switch route {
        case .createPost:
            CreatePostView(
                feedService: feedService,
                placesService: placesService,
                onSuccess: { router.pop() }
            )

        case .placeDetails(let place):
            if let id = UUID(uuidString: place.id) {
                PlaceDetailsView(
                    viewData: PlaceDetailsViewData(
                        id: id,
                        name: place.name,
                        description: "",
                        sportTags: [],
                        placeTags: [],
                        sportIds: [],
                        sportSlugs: [],
                        ridersCount: 0,
                        mentorsCount: 0,
                        avatar: .imageRemote(place.avatarUrl.flatMap(URL.init))
                    ),
                    placesService: placesService,
                    authState: authState
                )
            }

        case .riderDetails(let rider):
            FeedRiderDetailView(
                rider: rider,
                riderService: riderService,
                onMessageTap: { _, _ in }
            )
        }
    }

    @ViewBuilder
    private func placesDestination(for route: PlacesRoute) -> some View {
        switch route {
        case .placeDetails(let viewData):
            PlaceDetailsView(
                viewData: viewData,
                placesService: placesService,
                authState: authState
            )
        case .riderCard(let viewData):
            RiderCardView(
                viewData: viewData,
                followRepository: followRepository
            )
        }
    }
}

extension View {
    func feedDestinations(
        feedService: any FeedServiceProtocol,
        placesService: any PlacesServiceProtocol,
        riderService: any RiderServiceProtocol,
        router: FeedRouter
    ) -> some View {
        modifier(FeedNavigationDestinations(
            feedService: feedService,
            placesService: placesService,
            riderService: riderService,
            router: router
        ))
    }
}
