import SwiftUI

/// Placeholder for the authenticated user's main feed.
/// Content will be added in subsequent iterations.
public struct FeedView: View {

    public init() {}

    public var body: some View {
        NavigationStack {
            ContentUnavailableView(
                AppStrings.feedNavigationTitle.localized,
                systemImage: "newspaper"
            )
            .navigationTitle(AppStrings.feedNavigationTitle.localized)
        }
    }
}
