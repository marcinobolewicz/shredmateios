import SwiftUI
import Networking
import Common
import Theme

public struct FeedView: View {
    @Environment(AppTheme.self) private var theme

    let feedService: any FeedServiceProtocol
    let placesService: any PlacesServiceProtocol
    let riderService: any RiderServiceProtocol
    let mentorSlotsService: any MentorSlotsServiceProtocol
    let sportPreferenceStorage: any SportPreferenceStorageProtocol
    let onOpenChat: (_ userId: UUID, _ displayName: String) -> Void
    @State private var router = FeedRouter()
    @State private var viewModel: FeedViewModel

    public init(
        feedService: any FeedServiceProtocol,
        placesService: any PlacesServiceProtocol,
        riderService: any RiderServiceProtocol,
        mentorSlotsService: any MentorSlotsServiceProtocol,
        sportPreferenceStorage: any SportPreferenceStorageProtocol,
        onOpenChat: @escaping (_ userId: UUID, _ displayName: String) -> Void = { _, _ in }
    ) {
        self.feedService = feedService
        self.placesService = placesService
        self.riderService = riderService
        self.mentorSlotsService = mentorSlotsService
        self.sportPreferenceStorage = sportPreferenceStorage
        self.onOpenChat = onOpenChat
        _viewModel = State(wrappedValue: FeedViewModel(feedService: feedService))
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            VStack(spacing: 0) {
                HStack {
                    DSScreenHeader(title: FeedStrings.navigationTitle.localized)
                    Spacer()
                    Button { router.navigate(to: .createPost) } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                    .padding(.trailing, theme.spacing.md)
                }
                content
            }
            .background(theme.colors.backgroundSecondary)
            .navigationBarHidden(true)
            .feedDestinations(
                feedService: feedService,
                placesService: placesService,
                riderService: riderService,
                mentorSlotsService: mentorSlotsService,
                sportPreferenceStorage: sportPreferenceStorage,
                router: router,
                onOpenChat: onOpenChat
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
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                ))
                .listRowSeparator(.hidden)
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
        .background(theme.colors.backgroundSecondary)
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
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            _PostHeader(post: post, onRiderTap: onRiderTap, onPlaceTap: onPlaceTap)
                .padding(.horizontal, theme.spacing.md)

            if let caption = post.caption, !caption.isEmpty {
                Text(caption)
                    .dsTextStyle(.body)
                    .padding(.horizontal, theme.spacing.md)
            }

            if let photoUrl = post.photoUrl, let url = URL(string: photoUrl) {
                _PostPhoto(url: url)
            }

            Text(DateFormatting.shared.timestamp(from: post.createdAt))
                .dsTextStyle(.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, theme.spacing.md)
        }
        .padding(.vertical, theme.spacing.md)
    }
}

// MARK: - Post Header

private struct _PostHeader: View {
    @Environment(AppTheme.self) private var theme
    let post: ActivityPost
    let onRiderTap: () -> Void
    let onPlaceTap: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            Button(action: onRiderTap) {
                AvatarView(
                    url: URL(string: post.rider.avatarUrl ?? ""),
                    initials: post.rider.initials
                )
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Button(action: onRiderTap) {
                    Text(post.rider.displayName)
                        .dsTextStyle(.heading)
                        .lineLimit(1)
                }
                .buttonStyle(.plain)

                Button(action: onPlaceTap) {
                    placeLabel
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var placeLabel: some View {
        if post.isCheckIn {
            (Text(FeedStrings.checkedInAt.localized + " ")
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary) +
            Text(post.place.name)
                .font(theme.typography.subheadline)
                .foregroundColor(theme.colors.textSecondary))
                .lineLimit(1)
        } else {
            Text(post.place.name)
                .dsTextStyle(.subheadline)
                .lineLimit(1)
        }
    }
}

// MARK: - Post Photo

private struct _PostPhoto: View {
    @Environment(AppTheme.self) private var theme
    let url: URL

    var body: some View {
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
    }
}

