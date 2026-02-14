import SwiftUI

struct PlacesListView: View {
    @Bindable var viewModel: PlacesViewModel

    var body: some View {
        content
            .navigationTitle("Explore")
            .searchable(text: $viewModel.searchText)
            .onChange(of: viewModel.searchText) { _, _ in
                // Jeśli chcesz: debounce. Bez overengineering: odświeżaj po wpisaniu.
                viewModel.load(force: true)
            }
            .task { viewModel.loadOnAppear() }
            .refreshable { viewModel.refresh() }
            .errorAlert(state: viewModel.state) { viewModel.refresh() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            List {
//                TODO: skeleton rows
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)

        case .loaded:
            if viewModel.rows.isEmpty {
                ContentUnavailableView("Brak miejsc", systemImage: "mappin.and.ellipse", description: Text("Spróbuj zmienić filtr lub wyszukiwanie."))
            } else {
                List(viewModel.rows) { row in
                    SpotRow(viewData: row)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(uiColor: .systemBackground))
            }

        case .failed:
            ContentUnavailableView {
                Label("Nie udało się wczytać", systemImage: "exclamationmark.triangle")
            } description: {
                Text("Sprawdź internet i spróbuj ponownie.")
            } actions: {
                Button("Odśwież", action: viewModel.refresh)
            }
        }
    }
}
