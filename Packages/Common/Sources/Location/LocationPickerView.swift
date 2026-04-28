import SwiftUI
import MapKit

public struct LocationPickerView: View {
    private let initialCoordinate: CLLocationCoordinate2D?
    private let regionSpan: MKCoordinateSpan
    private let onConfirm: (CLLocationCoordinate2D) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition

    public init(
        initialCoordinate: CLLocationCoordinate2D?,
        regionSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1),
        onConfirm: @escaping (CLLocationCoordinate2D) -> Void
    ) {
        self.initialCoordinate = initialCoordinate
        self.regionSpan = regionSpan
        self.onConfirm = onConfirm

        _selectedCoordinate = State(initialValue: initialCoordinate)

        if let coord = initialCoordinate {
            _cameraPosition = State(initialValue: .region(MKCoordinateRegion(center: coord, span: regionSpan)))
        } else {
            _cameraPosition = State(initialValue: .automatic)
        }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                mapSection
                footerSection
            }
            .navigationTitle(CommonStrings.locationPickerTitle.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(CommonStrings.locationPickerConfirm.localized) {
                        if let coord = selectedCoordinate {
                            onConfirm(coord)
                        }
                        dismiss()
                    }
                    .disabled(selectedCoordinate == nil)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(CommonStrings.cancelButton.localized) { dismiss() }
                }
            }
        }
    }

    private var mapSection: some View {
        MapReader { proxy in
            Map(position: $cameraPosition) {
                if let coord = selectedCoordinate {
                    Marker("", coordinate: coord).tint(.red)
                }
            }
            .onTapGesture { position in
                if let coord = proxy.convert(position, from: .local) {
                    selectedCoordinate = coord
                }
            }
        }
    }

    private var footerSection: some View {
        VStack(spacing: 12) {
            coordinateLabel
        }
        .padding()
        .background(.regularMaterial)
    }

    @ViewBuilder
    private var coordinateLabel: some View {
        if let coord = selectedCoordinate {
            Text(String(format: "%.6f, %.6f", coord.latitude, coord.longitude))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        } else {
            Text(CommonStrings.locationPickerTapHint.localized)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
    }
}
