import SwiftUI
import Networking
import Common
import Theme

struct MyPostsView: View {
    @Environment(AppTheme.self) private var theme
    @State private var viewModel: MyPostsViewModel

    init(riderId: String, feedService: any FeedServiceProtocol) {
        _viewModel = State(wrappedValue: MyPostsViewModel(riderId: riderId, feedService: feedService))
    }

    var body: some View {
        content
            .navigationTitle(ProfileStrings.myPostsNavigationTitle.localized)
            .navigationBarTitleDisplayMode(.inline)
            .task { viewModel.loadOnAppear() }
            .refreshable { viewModel.refresh() }
            .alert(item: $viewModel.deleteError) { err in
                Alert(
                    title: Text(err.title),
                    message: Text(err.message),
                    dismissButton: .default(Text(ProfileStrings.ok.localized)) {
                        viewModel.deleteError = nil
                    }
                )
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            VStack { Spacer(); ProgressView(); Spacer() }
                .frame(maxWidth: .infinity)

        case .loaded:
            if viewModel.posts.isEmpty {
                ContentUnavailableView(
                    ProfileStrings.myPostsEmpty.localized,
                    systemImage: "newspaper",
                    description: Text(ProfileStrings.myPostsEmptyDescription.localized)
                )
            } else {
                postsList
            }

        case .failed:
            ContentUnavailableView(
                ProfileStrings.myPostsFailed.localized,
                systemImage: "exclamationmark.triangle"
            )
        }
    }

    private var postsList: some View {
        List {
            ForEach(viewModel.posts) { post in
                MyPostRow(post: post)
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
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.deletePost(id: post.id)
                        } label: {
                            Label(ProfileStrings.deletePost.localized, systemImage: "trash")
                        }
                    }
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
    }
}

// MARK: - Post Row

private struct MyPostRow: View {
    @Environment(AppTheme.self) private var theme
    let post: ActivityPost

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(theme.colors.primary)
                    .font(.subheadline)
                Text(post.place.name)
                    .dsTextStyle(.heading)
                    .lineLimit(1)
            }

            if let caption = post.caption, !caption.isEmpty {
                Text(caption)
                    .dsTextStyle(.body)
            }

            Text(post.createdAt.relativeFormatted)
                .dsTextStyle(.caption)
                .frame(maxWidth: .infinity, alignment: .trailing)
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
