import SwiftUI
import MapKit
import Theme

struct PlacesMapView: View {
    @Environment(AppTheme.self) private var theme
    @Bindable var viewModel: PlacesViewModel
    private let presenter = PlacesMapPresenter()
    
    @State private var region = PlacesMapPresenter().defaultRegion
    @State private var selectedPinId: UUID?

    private var pins: [PlaceMapPinViewData] {
        presenter.mapPins(from: viewModel.rows)
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: pins) { pin in
            MapAnnotation(coordinate: pin.coordinate) {
                mapPinAnnotation(pin)
            }
        }
        .onAppear {
            syncRegion()
        }
        .onChange(of: viewModel.rows) { _, _ in
            syncRegion()
            if let selectedPinId, !pins.contains(where: { $0.id == selectedPinId }) {
                self.selectedPinId = nil
            }
        }
    }

    private func mapPinAnnotation(_ pin: PlaceMapPinViewData) -> some View {
        VStack(spacing: theme.spacing.xxs) {
            if selectedPinId == pin.id {
                pinCallout(pin)
            }

            Button {
                withAnimation(.snappy(duration: 0.2)) {
                    selectedPinId = (selectedPinId == pin.id) ? nil : pin.id
                }
            } label: {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(theme.colors.primary)
            }
            .buttonStyle(.plain)
        }
    }

    private func pinCallout(_ pin: PlaceMapPinViewData) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            Text(pin.title)
                .dsTextStyle(.heading)
                .lineLimit(1)

            Text(pin.description)
                .dsTextStyle(.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(2)
        }
        .frame(width: 180, alignment: .leading)
        .padding(.horizontal, theme.spacing.sm)
        .padding(.vertical, theme.spacing.xs)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(theme.colors.border.opacity(0.35), lineWidth: 1)
        )
    }

    private func syncRegion() {
        let newRegion = presenter.region(for: pins, fallback: presenter.defaultRegion)
        withAnimation(.snappy(duration: 0.25)) {
            region = newRegion
        }
    }
}
