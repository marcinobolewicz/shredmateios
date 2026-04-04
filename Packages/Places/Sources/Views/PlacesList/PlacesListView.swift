import SwiftUI
import Theme

struct PlacesListView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(PlacesRouter.self) private var router
    @Bindable var viewModel: PlacesViewModel

    var body: some View {
        content
            .refreshable { viewModel.refresh() }
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
            if viewModel.rows.isEmpty {
                ContentUnavailableView(
                    PlacesStrings.emptyTitle.localized,
                    systemImage: "mappin.and.ellipse",
                    description: Text(PlacesStrings.emptyDescription.localized)
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.rows.enumerated()), id: \.element.id) { index, row in
                            Button {
                                router.navigate(to: .placeDetails(row.placeDetailsData))
                            } label: {
                                SpotRow(viewData: row)
                                    .padding(.horizontal, theme.spacing.md)
                            }
                            .buttonStyle(.plain)

                            if index < viewModel.rows.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .dsCard()
                }
            }

        case .failed:
            ContentUnavailableView {
                Label(PlacesStrings.failedTitle.localized, systemImage: "exclamationmark.triangle")
            } description: {
                Text(PlacesStrings.failedDescription.localized)
            } actions: {
                Button(PlacesStrings.refreshButton.localized, action: viewModel.refresh)
                    .buttonStyle(.dsPrimary)
            }
        }
    }
}
