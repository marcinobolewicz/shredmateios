import SwiftUI
import Theme

struct PlacesListView: View {
    @Environment(AppTheme.self) private var theme
    @Bindable var viewModel: PlacesViewModel

    var body: some View {
        content
            .navigationTitle(PlacesStrings.listNavigationTitle.localized)
            .searchable(text: $viewModel.searchText)
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.load(force: true)
            }
            .refreshable { viewModel.refresh() }
            .errorAlert(state: viewModel.state) { viewModel.refresh() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            List {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)

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
                                top: theme.spacing.xs,
                                leading: theme.spacing.md,
                                bottom: theme.spacing.xs,
                                trailing: theme.spacing.md
                            )
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
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
