import SwiftUI

// MARK: - Environment key

private struct PageSafeAreaInsetsKey: EnvironmentKey {
    static let defaultValue = EdgeInsets()
}

extension EnvironmentValues {
    /// Safe area insets captured by `VerticalPageView` before they are consumed
    /// by `.ignoresSafeArea()`. Slides read this to offset their bottom content.
    var pageSafeAreaInsets: EdgeInsets {
        get { self[PageSafeAreaInsetsKey.self] }
        set { self[PageSafeAreaInsetsKey.self] = newValue }
    }
}

// MARK: - View

/// A generic full-screen vertical paging container.
///
/// Uses `GeometryReader` + explicit `.frame(width:height:)` for each page —
/// the only reliable approach in a `TabView` context where
/// `containerRelativeFrame` may return incorrect dimensions.
struct VerticalPageView<Item: Identifiable, Content: View>: View {
    let items: [Item]
    @ViewBuilder var content: (Item) -> Content

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(items) { item in
                        content(item)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .environment(\.pageSafeAreaInsets, proxy.safeAreaInsets)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
        }
        .ignoresSafeArea(.all, edges: [.top, .bottom])
    }
}
