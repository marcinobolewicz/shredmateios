import SwiftUI

/// A generic full-screen horizontal paging container.
///
/// Uses `TabView` with `.tabViewStyle(.page)` — the simplest, most reliable
/// approach for full-screen horizontal paging on iOS. Renders a custom dot
/// indicator positioned near the bottom, above any host tab bar.
struct PageView<Item: Identifiable, Content: View>: View {
    let items: [Item]
    @ViewBuilder var content: (Item) -> Content
    @State private var selectedIndex: Int = 0

    var body: some View {
        GeometryReader { geo in
            TabView(selection: $selectedIndex) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    content(item)
                        .ignoresSafeArea()
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                PageIndicator(count: items.count, currentIndex: selectedIndex)
                    .padding(.bottom, geo.safeAreaInsets.bottom - 60)
            }
        }
    }
}

private struct PageIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.white : Color.white.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentIndex)
    }
}
