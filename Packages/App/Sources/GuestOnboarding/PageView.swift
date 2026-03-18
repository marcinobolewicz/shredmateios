import SwiftUI

/// A generic full-screen horizontal paging container.
///
/// Uses `TabView` with `.tabViewStyle(.page)` — the simplest, most reliable
/// approach for full-screen horizontal paging on iOS.
struct PageView<Item: Identifiable, Content: View>: View {
    let items: [Item]
    @ViewBuilder var content: (Item) -> Content

    var body: some View {
        TabView {
            ForEach(items) { item in
                content(item)
                    .ignoresSafeArea()
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
}
