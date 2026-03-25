import SwiftUI
import Networking
import Theme

public struct PlacesView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(PlacesRouter.self) private var router
    @State private var viewModel: PlacesViewModel

    public init(
            placesService: any PlacesServiceProtocol,
            sportsService: any SportsServiceProtocol,
            authState: AuthState
    ) {
        let repository = PlacesRepository(service: placesService, sportsService: sportsService)
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
            tagChips
            contentSection
        }
        .task { viewModel.loadOnAppear() }
        .errorAlert(state: viewModel.state) { viewModel.refresh() }
    }

    private var headerSection: some View {
        VStack(spacing: theme.spacing.sm) {
            displayModePicker
            DSSearchBar(PlacesStrings.searchPlaceholder.localized, text: $viewModel.searchText)
                .onChange(of: viewModel.searchText) { _, _ in
                    viewModel.applyFilters()
                }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.top, theme.spacing.sm)
        .padding(.bottom, theme.spacing.xs)
    }

    private var displayModePicker: some View {
        HStack(spacing: 0) {
            ForEach(PlacesDisplayMode.allCases) { mode in
                Button {
                    withAnimation(.snappy(duration: Constants.Animation.chipDuration)) {
                        viewModel.displayMode = mode
                    }
                } label: {
                    Text(mode.title)
                        .font(.subheadline)
                        .fontWeight(viewModel.displayMode == mode ? .semibold : .regular)
                        .foregroundStyle(
                            viewModel.displayMode == mode
                                ? theme.colors.primaryForeground
                                : theme.colors.textPrimary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacing.xs + Constants.Spacing.xxs)
                        .background(
                            Capsule()
                                .fill(
                                    viewModel.displayMode == mode
                                        ? theme.colors.primary
                                        : theme.colors.surfaceTertiary
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .background(Capsule().fill(theme.colors.surfaceTertiary))
    }

    @ViewBuilder
    private var contentSection: some View {
        switch viewModel.displayMode {
        case .list:
            PlacesListView(viewModel: viewModel)
        case .map:
            PlacesMapView(viewModel: viewModel)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private var sportChips: some View {
        chipRow {
            ForEach(viewModel.sports) { sport in
                DSChip(
                    title: sport.slug,
                    isSelected: viewModel.selectedSport == sport
                ) {
                    withAnimation(.snappy(duration: Constants.Animation.chipDuration)) {
                        viewModel.selectSport(sport)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var tagChips: some View {
        if viewModel.selectedSport != nil, !viewModel.availableTags.isEmpty {
            chipRow {
                ForEach(viewModel.availableTags) { tag in
                    DSChip(
                        title: tag.name,
                        isSelected: viewModel.selectedTagIds.contains(tag.id)
                    ) {
                        withAnimation(.snappy(duration: Constants.Animation.chipDuration)) {
                            viewModel.toggleTag(tag.id)
                        }
                    }
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    private func chipRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.xs) {
                content()
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.xs)
        }
    }
}
