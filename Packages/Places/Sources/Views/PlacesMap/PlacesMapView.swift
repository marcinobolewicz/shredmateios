import SwiftUI
import MapKit
import Theme

struct PlacesMapView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(PlacesRouter.self) private var router
    @Bindable var viewModel: PlacesViewModel
    private let presenter = PlacesMapPresenter()

    @State private var position: MapCameraPosition = .automatic
    @State private var selectedPinId: UUID?
    @State private var pins: [PlaceMapPinViewData] = []
    
    var body: some View {
        Map(position: $position) {
            ForEach(pins) { pin in
                Annotation(pin.title, coordinate: pin.coordinate, anchor: .bottom) {
                    mapPinAnnotation(pin)
                }
                .annotationTitles(.hidden)
            }
        }
        .onTapGesture {
            withAnimation(.snappy(duration: Constants.Animation.chipDuration)) {
                selectedPinId = nil
            }
        }
        .onChange(of: viewModel.rows, initial: true) { _, newRows in
            let newPins = presenter.mapPins(from: newRows)
            pins = newPins

            if let selectedPinId, !newPins.contains(where: { $0.id == selectedPinId }) {
                self.selectedPinId = nil
            }

            let region = presenter.region(for: newPins, fallback: presenter.defaultRegion)
            withAnimation(.snappy(duration: 0.25)) {
                position = .region(region)
            }
        }
    }

    private func mapPinAnnotation(_ pin: PlaceMapPinViewData) -> some View {
        VStack(spacing: theme.spacing.xs) {
            if selectedPinId == pin.id {
                pinCallout(pin)
            }

            Button {
                withAnimation(.snappy(duration: Constants.Animation.chipDuration)) {
                    selectedPinId = (selectedPinId == pin.id) ? nil : pin.id
                }
            } label: {
                Image(systemName: "mappin.and.ellipse.circle.fill")
                    .font(.system(size: Constants.Spacing.xl))
                    .foregroundStyle(theme.colors.primary)
                    .background(
                        Circle()
                            .fill(.white)
                            .padding(Constants.Spacing.xxs)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private func pinCallout(_ pin: PlaceMapPinViewData) -> some View {
        Button {
            router.navigate(to: .placeDetails(pin.placeDetailsData))
        } label: {
            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(pin.title)
                    .dsTextStyle(.heading)
                    .lineLimit(1)

                Text(pin.description)
                    .dsTextStyle(.caption)
                    .lineLimit(2)
            }
            .frame(width: 180, alignment: .leading)
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(theme.colors.border.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
