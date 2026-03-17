//
//  MapLocationPickerView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 17/03/2026.
//

import SwiftUI
import MapKit
import Common

struct MapLocationPickerView: View {

    let initialCoordinate: CLLocationCoordinate2D?
    let initialLocationName: String
    let onConfirm: (CLLocationCoordinate2D, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var locationName: String
    @State private var cameraPosition: MapCameraPosition

    init(
        initialCoordinate: CLLocationCoordinate2D?,
        initialLocationName: String,
        onConfirm: @escaping (CLLocationCoordinate2D, String) -> Void
    ) {
        self.initialCoordinate = initialCoordinate
        self.initialLocationName = initialLocationName
        self.onConfirm = onConfirm

        _locationName = State(initialValue: initialLocationName)
        _selectedCoordinate = State(initialValue: initialCoordinate)

        if let coord = initialCoordinate {
            _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )))
        } else {
            _cameraPosition = State(initialValue: .automatic)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MapReader { proxy in
                    Map(position: $cameraPosition) {
                        if let coord = selectedCoordinate {
                            Marker("", coordinate: coord)
                                .tint(.red)
                        }
                    }
                    .onTapGesture { position in
                        if let coord = proxy.convert(position, from: .local) {
                            selectedCoordinate = coord
                        }
                    }
                }

                VStack(spacing: 12) {
                    if let coord = selectedCoordinate {
                        Text(String(format: "%.6f, %.6f", coord.latitude, coord.longitude))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text(ProfileStrings.tapMapToPin.localized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    TextField(ProfileStrings.locationNamePlaceholder.localized, text: $locationName)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                .background(.regularMaterial)
            }
            .navigationTitle(ProfileStrings.locationPickerTitle.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(ProfileStrings.confirmLocationButton.localized) {
                        if let coord = selectedCoordinate {
                            onConfirm(coord, locationName)
                        }
                        dismiss()
                    }
                    .disabled(selectedCoordinate == nil)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(CommonStrings.cancelButton.localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}
