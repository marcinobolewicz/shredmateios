import SwiftUI
import MapKit

public struct LocationPickerView: View {

    public enum NameField {
        case hidden
        case editable(placeholder: String)
    }

    private let initialCoordinate: CLLocationCoordinate2D?
    private let initialLocationName: String
    private let regionSpan: MKCoordinateSpan
    private let nameField: NameField
    private let onConfirm: (CLLocationCoordinate2D, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var locationName: String
    @State private var cameraPosition: MapCameraPosition

    public init(
        initialCoordinate: CLLocationCoordinate2D?,
        initialLocationName: String = "",
        regionSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1),
        nameField: NameField = .editable(placeholder: ""),
        onConfirm: @escaping (CLLocationCoordinate2D, String) -> Void
    ) {
        self.initialCoordinate = initialCoordinate
        self.initialLocationName = initialLocationName
        self.regionSpan = regionSpan
        self.nameField = nameField
        self.onConfirm = onConfirm

        _locationName = State(initialValue: initialLocationName)
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
                            onConfirm(coord, locationName)
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
            nameFieldView
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

    @ViewBuilder
    private var nameFieldView: some View {
        switch nameField {
        case .hidden:
            EmptyView()
        case .editable(let placeholder):
            TextField(placeholder, text: $locationName)
                .textFieldStyle(.roundedBorder)
        }
    }
}
