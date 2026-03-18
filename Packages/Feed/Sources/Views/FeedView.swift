import SwiftUI
import Networking
import Common

public struct FeedView: View {

    let feedService: any FeedServiceProtocol
    let placesService: any PlacesServiceProtocol
    @State private var router = FeedRouter()
    @State private var viewModel: FeedViewModel

    public init(
        feedService: any FeedServiceProtocol,
        placesService: any PlacesServiceProtocol
    ) {
        self.feedService = feedService
        self.placesService = placesService
        _viewModel = State(wrappedValue: FeedViewModel(feedService: feedService))
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            content
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
                .feedDestinations(
                    feedService: feedService,
                    placesService: placesService,
                    router: router
                )
        }
        .task { viewModel.loadOnAppear() }
        .errorAlert(state: viewModel.state) { viewModel.refresh() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .frame(maxWidth: .infinity)

        case .loaded:
            if viewModel.posts.isEmpty {
                ContentUnavailableView(
                    FeedStrings.emptyTitle.localized,
                    systemImage: "newspaper",
                    description: Text(FeedStrings.emptyDescription.localized)
                )
                .refreshable { viewModel.refresh() }
            } else {
                postsList
            }

        case .failed:
            ContentUnavailableView {
                Label(FeedStrings.failedTitle.localized, systemImage: "exclamationmark.triangle")
            } description: {
                Text(FeedStrings.failedDescription.localized)
            } actions: {
                Button(FeedStrings.refreshButton.localized, action: viewModel.refresh)
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private var postsList: some View {
        List {
            ForEach(viewModel.posts) { post in
                ActivityPostRow(post: post)
                    .listRowSeparator(.visible)
                    .listRowBackground(Color.clear)
                    .onAppear { viewModel.loadNextPageIfNeeded(currentPost: post) }
            }

            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .refreshable { viewModel.refresh() }
    }
}

// MARK: - Post Row

private struct ActivityPostRow: View {
    let post: ActivityPost

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RiderAvatar(url: URL(string: post.rider.avatarUrl ?? ""), initials: post.rider.initials)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(post.rider.displayName)
                        .font(.subheadline.weight(.semibold))
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text(post.place.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text(post.createdAt.relativeFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let caption = post.caption, !caption.isEmpty {
                    Text(caption)
                        .font(.body)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Date formatting

private extension String {
    var relativeFormatted: String {
        guard let date = ISO8601DateFormatter().date(from: self) else { return self }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: .now)
    }
}

private struct RiderAvatar: View {
    let url: URL?
    let initials: String

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        fallback
                    }
                }
            } else {
                fallback
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
    }

    private var fallback: some View {
        ZStack {
            Circle().fill(Color(.systemGray4))
            Text(initials)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}
