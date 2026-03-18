import Foundation
import Networking
import Common

@MainActor
@Observable
final class FeedViewModel {

    // MARK: - State

    private(set) var posts: [ActivityPost] = []
    private(set) var state: LoadState = .idle
    private(set) var isLoadingMore = false
    private(set) var hasMore = true

    // MARK: - Pagination

    private let limit = 20
    private var currentPage = 1

    // MARK: - Dependencies

    private let feedService: any FeedServiceProtocol

    // MARK: - Init

    init(feedService: any FeedServiceProtocol) {
        self.feedService = feedService
    }

    // MARK: - Actions

    func loadOnAppear() {
        guard case .idle = state else { return }
        load()
    }

    func refresh() {
        load(reset: true)
    }

    func loadNextPageIfNeeded(currentPost: ActivityPost) {
        guard !isLoadingMore, hasMore else { return }
        guard let last = posts.last, last.id == currentPost.id else { return }
        loadNextPage()
    }

    // MARK: - Private

    private func load(reset: Bool = false) {
        if case .loading = state { return }

        if reset {
            currentPage = 1
            hasMore = true
            posts = []
        }

        state = .loading

        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await feedService.fetchFeed(page: currentPage, limit: limit)
                self.posts = response.items
                self.hasMore = self.posts.count < response.total
                self.state = .loaded
            } catch {
                self.state = .failed(.from(error))
            }
        }
    }

    private func loadNextPage() {
        isLoadingMore = true
        let nextPage = currentPage + 1

        Task { [weak self] in
            guard let self else { return }
            defer { self.isLoadingMore = false }
            do {
                let response = try await feedService.fetchFeed(page: nextPage, limit: limit)
                self.posts.append(contentsOf: response.items)
                self.currentPage = nextPage
                self.hasMore = self.posts.count < response.total
            } catch {
                // pagination errors are silent — user can scroll up to refresh
            }
        }
    }
}
