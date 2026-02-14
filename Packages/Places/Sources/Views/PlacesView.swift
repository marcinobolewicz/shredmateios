import SwiftUI
import Networking
import Theme

public struct PlacesView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(PlacesRouter.self) private var router
    @State private var viewModel: PlacesViewModel

    public init(
            placesService: any PlacesServiceProtocol,
            authState: AuthState
    ) {
        let repository = PlacesRepository(service: placesService)
        let presenter = SpotRowPresenter()

        _viewModel = State(
            wrappedValue: PlacesViewModel(
                repository: repository,
                presenter: presenter
            )
        )
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerSection
            sportChips
            contentSection
        }
        .task { viewModel.loadOnAppear() }
        .errorAlert(state: viewModel.state) { viewModel.refresh() }
    }

    private var headerSection: some View {
        VStack(spacing: theme.spacing.sm) {
            Picker("Display Mode", selection: $viewModel.displayMode) {
                ForEach(PlacesDisplayMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            DSSearchBar("Search places...", text: $viewModel.searchText)
                .task { await viewModel.loadOnAppear() }
        }
        .padding(theme.spacing.md)
    }

    @ViewBuilder
    private var contentSection: some View {
        switch viewModel.displayMode {
        case .list:
            PlacesListView(viewModel: viewModel)
        case .map:
            PlacesMapView(viewModel: viewModel)
        }
    }

    private var sportChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                ForEach(Sport.allCases) { sport in
                    DSChip(
                        title: sport.rawValue,
                        isSelected: viewModel.selectedSport == sport
                    ) {
                        withAnimation(.snappy(duration: Constants.Animation.chipDuration)) {
                            viewModel.selectedSport = sport
                        }
                    }
                }
            }
            .padding(.vertical, theme.spacing.xxs)
        }
    }
}
