import SwiftUI

public struct PlacesView: View {
    @State private var viewModel = PlacesViewModel()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            headerSection
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
}

#Preview {
    PlacesView()
}
