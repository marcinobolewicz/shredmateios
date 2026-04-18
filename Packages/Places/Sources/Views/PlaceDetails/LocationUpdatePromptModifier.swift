import SwiftUI
import CoreLocation
import Common

struct LocationUpdatePromptModifier: ViewModifier {
    @Bindable var viewModel: PlaceDetailsViewModel
    let spot: CLLocationCoordinate2D?

    func body(content: Content) -> some View {
        content
            .alert(
                PlacesStrings.locationUpdatePromptTitle.localized,
                isPresented: $viewModel.showLocationUpdatePrompt
            ) {
                Button(PlacesStrings.locationUpdateConfirm.localized) {
                    Task { await viewModel.confirmAutoLocationUpdate() }
                }
                Button(PlacesStrings.locationUpdateOnMap.localized) {
                    viewModel.showLocationMapPicker = true
                }
                Button(PlacesStrings.cancelButton.localized, role: .cancel) {}
            } message: {
                Text(PlacesStrings.locationUpdatePromptMessage.localized)
            }
            .sheet(isPresented: $viewModel.showLocationMapPicker) {
                LocationPickerView(
                    initialCoordinate: spot,
                    nameField: .hidden
                ) { coord, _ in
                    Task { await viewModel.confirmMapLocation(coord) }
                }
            }
    }
}

extension View {
    func locationUpdatePrompt(
        viewModel: PlaceDetailsViewModel,
        spot: CLLocationCoordinate2D?
    ) -> some View {
        modifier(LocationUpdatePromptModifier(viewModel: viewModel, spot: spot))
    }
}
