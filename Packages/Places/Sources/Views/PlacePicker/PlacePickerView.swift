import SwiftUI
import Networking
import Common

/// Reusable full-screen place picker.
///
/// Present inside a `NavigationStack` (e.g. as a sheet).
/// Sets `selection` and dismisses itself when the user taps a row.
public struct PlacePickerView: View {

    @Binding var selection: Place?
    @State private var viewModel: PlacePickerViewModel
    @Environment(\.dismiss) private var dismiss

    public init(placesService: any PlacesServiceProtocol, selection: Binding<Place?>) {
        _selection = selection
        _viewModel = State(initialValue: PlacePickerViewModel(placesService: placesService))
    }

    public var body: some View {
        List(viewModel.filtered) { place in
            Button {
                selection = place
                dismiss()
            } label: {
                row(for: place)
            }
            .tint(.primary)
        }
        .searchable(text: $viewModel.searchText, prompt: PlacesStrings.searchPlaceholder.localized)
        .overlay { if viewModel.isLoading { ProgressView() } }
        .navigationTitle(PlacesStrings.pickerTitle.localized)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .alert(item: $viewModel.error) { err in
            Alert(
                title: Text(err.title),
                message: Text(err.message),
                dismissButton: .default(Text(PlacesStrings.cancelButton.localized))
            )
        }
    }

    // MARK: - Private

    @ViewBuilder
    private func row(for place: Place) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                if !place.sports.isEmpty {
                    Text(place.sports.map(\.name).joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if selection?.id == place.id {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
                    .fontWeight(.semibold)
            }
        }
    }
}
