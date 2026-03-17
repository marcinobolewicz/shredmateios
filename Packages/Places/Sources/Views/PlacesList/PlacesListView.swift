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
                List(viewModel.rows) { row in
                    SpotRow(viewData: row)
                        .listRowInsets(
                            EdgeInsets(
                                top: 0,
                                leading: theme.spacing.md,
                                bottom: 0,
                                trailing: theme.spacing.md
                            )
                        )
                        .listRowSeparator(.visible)
                        .listRowSeparatorTint(theme.colors.border.opacity(0.4))
                        .listRowBackground(Color.clear)
                        .onTapGesture {
                            let detailData = PlaceDetailsViewData(
                                id: row.id,
                                name: row.title,
                                description: row.description,
                                sportTags: row.sportTags,
                                placeTags: row.placeTags,
                                sportIds: row.sportIds,
                                sportSlugs: row.sportSlugs,
                                ridersCount: row.ridersCount,
                                mentorsCount: row.mentorsCount,
                                avatar: row.avatar
                            )
                            router.navigate(to: .placeDetails(detailData))
                        }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(theme.colors.background)
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
