import SwiftUI
import Networking

public struct PlacesView: View {
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
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Picker("Display Mode", selection: $viewModel.displayMode) {
                ForEach(PlacesDisplayMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search places...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .task { await viewModel.loadOnAppear() }
        }
        .padding()
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
            HStack(spacing: 12) {
                ForEach(Sport.allCases) { sport in
                    Chip(
                        title: sport.rawValue,
                        isSelected: viewModel.selectedSport == sport
                    ) {
                        withAnimation(.snappy(duration: 0.18)) {
                            viewModel.selectedSport = sport
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}
