import SwiftUI
import Networking
import Common
import Theme

public struct FeedView: View {

    let feedService: any FeedServiceProtocol
    let placesService: any PlacesServiceProtocol
    let riderService: any RiderServiceProtocol
    @State private var router = FeedRouter()
    @State private var viewModel: FeedViewModel

    public init(
        feedService: any FeedServiceProtocol,
        placesService: any PlacesServiceProtocol,
        riderService: any RiderServiceProtocol
    ) {
        self.feedService = feedService
        self.placesService = placesService
        self.riderService = riderService
        _viewModel = State(wrappedValue: FeedViewModel(feedService: feedService))
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            content
                .navigationTitle(FeedStrings.navigationTitle.localized)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { router.navigate(to: .createPost) } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .feedDestinations(
                    feedService: feedService,
                    placesService: placesService,
                    riderService: riderService,
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
            loadingView
        case .loaded:
            viewModel.posts.isEmpty ? AnyView(emptyView) : AnyView(postsList)
        case .failed:
            errorView
        }
    }

    private var loadingView: some View {
        VStack { Spacer(); ProgressView(); Spacer() }
            .frame(maxWidth: .infinity)
    }

    private var emptyView: some View {
        ContentUnavailableView(
            FeedStrings.emptyTitle.localized,
            systemImage: "newspaper",
            description: Text(FeedStrings.emptyDescription.localized)
        )
        .refreshable { viewModel.refresh() }
    }

    private var errorView: some View {
        ContentUnavailableView {
            Label(FeedStrings.failedTitle.localized, systemImage: "exclamationmark.triangle")
        } description: {
            Text(FeedStrings.failedDescription.localized)
        } actions: {
            Button(FeedStrings.refreshButton.localized, action: viewModel.refresh)
                .buttonStyle(.dsPrimary)
        }
    }

    private var postsList: some View {
        _PostsList(viewModel: viewModel, router: router)
    }
}

// MARK: - Posts List

private struct _PostsList: View {
    @Environment(AppTheme.self) private var theme
    @Bindable var viewModel: FeedViewModel
    let router: FeedRouter

    var body: some View {
        List {
            ForEach(viewModel.posts) { post in
                ActivityPostRow(post: post) {
                    router.navigate(to: .riderDetails(post.rider))
                } onPlaceTap: {
                    router.navigate(to: .placeDetails(post.place))
                }
                .listRowInsets(EdgeInsets(
                    top: 0,
                    leading: theme.spacing.md,
                    bottom: 0,
                    trailing: theme.spacing.md
                ))
                .listRowSeparator(.visible)
                .listRowSeparatorTint(theme.colors.border.opacity(0.4))
                .listRowBackground(Color.clear)
                .onAppear { viewModel.loadNextPageIfNeeded(currentPost: post) }
            }

            if viewModel.isLoadingMore {
                HStack { Spacer(); ProgressView(); Spacer() }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(theme.colors.background)
        .refreshable { viewModel.refresh() }
    }
}

// MARK: - Post Row

private struct ActivityPostRow: View {
    @Environment(AppTheme.self) private var theme
    let post: ActivityPost
    let onRiderTap: () -> Void
    let onPlaceTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Button(action: onRiderTap) {
                AvatarView(
                    url: URL(string: post.rider.avatarUrl ?? ""),
                    initials: post.rider.initials
                )
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                HStack(spacing: theme.spacing.xxs) {
                    Button(action: onRiderTap) {
                        Text(post.rider.displayName)
                            .dsTextStyle(.heading)
                            .lineLimit(1)
                    }
                    .buttonStyle(.plain)

                    Text("·").dsTextStyle(.subheadline)

                    Button(action: onPlaceTap) {
                        Text(post.place.name)
                            .dsTextStyle(.subheadline)
                            .lineLimit(1)
                    }
                    .buttonStyle(.plain)
                }

                if let photoUrl = post.photoUrl, let url = URL(string: photoUrl) {
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    theme.colors.surfaceSecondary
                                default:
                                    theme.colors.surfaceSecondary
                                }
                            }
                        }
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: theme.radius.sm))
                }

                if let caption = post.caption, !caption.isEmpty {
                    Text(caption).dsTextStyle(.body)
                }

                Text(post.createdAt.relativeFormatted)
                    .dsTextStyle(.caption)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.vertical, theme.spacing.sm)
    }
}

// MARK: - Date Formatting

private extension String {
    var relativeFormatted: String {
        guard let date = ISO8601DateFormatter().date(from: self) else { return self }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: .now)
    }
}
