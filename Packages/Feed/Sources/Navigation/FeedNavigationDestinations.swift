import SwiftUI
import Networking
import Places
import Common

struct FeedNavigationDestinations: ViewModifier {
    let feedService: any FeedServiceProtocol
    let placesService: any PlacesServiceProtocol
    let riderService: any RiderServiceProtocol
    let mentorSlotsService: any MentorSlotsServiceProtocol
    let router: FeedRouter

    @Environment(AuthState.self) private var authState

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
            RiderDetailLoadingView(
                partialViewData: RiderCardViewData(
                    id: rider.id,
                    riderId: rider.id,
                    userId: UUID(),
                    displayName: rider.displayName,
                    avatarInitials: rider.initials,
                    avatarURL: rider.avatarUrl.flatMap(URL.init),
                    description: ""
                ),
                riderService: riderService,
                mentorSlotsService: mentorSlotsService
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
            RiderDetailLoadingView(
                partialViewData: viewData,
                riderService: riderService,
                mentorSlotsService: mentorSlotsService
            )
        }
    }
}

extension View {
    func feedDestinations(
        feedService: any FeedServiceProtocol,
        placesService: any PlacesServiceProtocol,
        riderService: any RiderServiceProtocol,
        mentorSlotsService: any MentorSlotsServiceProtocol,
        router: FeedRouter
    ) -> some View {
        modifier(FeedNavigationDestinations(
            feedService: feedService,
            placesService: placesService,
            riderService: riderService,
            mentorSlotsService: mentorSlotsService,
            router: router
        ))
    }
}
