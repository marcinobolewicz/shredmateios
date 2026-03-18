import SwiftUI
import Networking

public struct FeedView: View {

    let feedService: any FeedServiceProtocol
    @State private var router = FeedRouter()

    public init(feedService: any FeedServiceProtocol) {
        self.feedService = feedService
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            ContentUnavailableView(
                FeedStrings.navigationTitle.localized,
                systemImage: "newspaper"
            )
            .navigationTitle(FeedStrings.navigationTitle.localized)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        router.navigate(to: .createPost)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .feedDestinations(feedService: feedService, router: router)
        }
    }
}
