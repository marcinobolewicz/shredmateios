import SwiftUI
import Networking

struct FeedNavigationDestinations: ViewModifier {
    let feedService: any FeedServiceProtocol
    let placesService: any PlacesServiceProtocol
    let router: FeedRouter

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: FeedRoute.self) { route in
                destination(for: route)
            }
    }

    @ViewBuilder
    private func destination(for route: FeedRoute) -> some View {
        switch route {
        case .createPost:
            CreatePostView(
                feedService: feedService,
                placesService: placesService,
                onSuccess: { router.pop() }
            )
        }
    }
}

extension View {
    func feedDestinations(
        feedService: any FeedServiceProtocol,
        placesService: any PlacesServiceProtocol,
        router: FeedRouter
    ) -> some View {
        modifier(FeedNavigationDestinations(
            feedService: feedService,
            placesService: placesService,
            router: router
        ))
    }
}
