import Foundation
import Networking
import Common

@MainActor
@Observable
final class MyPostsViewModel {

    private(set) var posts: [ActivityPost] = []
    private(set) var state: LoadState = .idle
    private(set) var isLoadingMore = false
    private(set) var total = 0
    var deleteError: AppError?

    private var currentPage = 0
    private var hasMore: Bool { posts.count < total }

    private let riderId: String
    private let feedService: any FeedServiceProtocol

    init(riderId: String, feedService: any FeedServiceProtocol) {
        self.riderId = riderId
        self.feedService = feedService
    }

    func loadOnAppear() {
        guard state == .idle else { return }
        Task { await load(reset: true) }
    }

    func refresh() {
        Task { await load(reset: true) }
    }

    func loadNextPageIfNeeded(currentPost: ActivityPost) {
        guard !isLoadingMore, hasMore, posts.last?.id == currentPost.id else { return }
        Task { await load(reset: false) }
    }

    func deletePost(id: String) {
        guard let index = posts.firstIndex(where: { $0.id == id }) else { return }
        let removed = posts.remove(at: index)
        total = max(0, total - 1)

        Task {
            do {
                try await feedService.deleteActivity(activityId: id)
            } catch {
                posts.insert(removed, at: min(index, posts.endIndex))
                total += 1
                deleteError = .from(error)
            }
        }
    }

    private func load(reset: Bool) async {
        if reset {
            state = .loading
            currentPage = 0
        } else {
            isLoadingMore = true
        }

        defer { isLoadingMore = false }

        let nextPage = currentPage + 1
        do {
            let response = try await feedService.fetchRiderPosts(riderId: riderId, page: nextPage, limit: 20)
            if reset {
                posts = response.items
            } else {
                posts.append(contentsOf: response.items)
            }
            total = response.total
            currentPage = nextPage
            state = .loaded
        } catch {
            if reset { state = .failed(.from(error)) }
        }
    }
}
