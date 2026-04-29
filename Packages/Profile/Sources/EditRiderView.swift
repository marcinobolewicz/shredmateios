import SwiftUI
import Networking
import Common
import MediaPicker
import Theme
import UIKit
import MapKit

struct EditRiderView: View {
    @Bindable var viewModel: ProfileViewModel
    @State private var showLocationPicker = false
    @State private var showAvatarPicker = false

    var body: some View {
        Form {
            profileSection
            locationSection
            sportsSection
        }
        .navigationTitle(ProfileStrings.editRiderTitle.localized)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerView(
                initialCoordinate: locationCoordinate
            ) { coord in
                viewModel.latitudeText = String(format: "%.6f", coord.latitude)
                viewModel.longitudeText = String(format: "%.6f", coord.longitude)
                Task { await viewModel.saveBaseLocation() }
            }
        }
        .imageCropPicker(isPresented: $showAvatarPicker) { result in
            if case .success(let data) = result {
                viewModel.avatarImage = data
            }
        }
        .profileAlerts(viewModel: viewModel)
    }

    // MARK: - Profile

    private var profileSection: some View {
        Section(ProfileStrings.sectionProfileInformation.localized) {
            HStack(alignment: .top, spacing: 16) {
                Button {
                    showAvatarPicker = true
                } label: {
                    profileAvatar
                        .overlay(alignment: .bottomTrailing) {
                            Text(ProfileStrings.changeAvatarBadge.localized)
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 8) {
                    TextField(ProfileStrings.displayNamePlaceholder.localized, text: $viewModel.displayName)
                        .textContentType(.name)
                        .font(.headline)

                    TextEditor(text: $viewModel.description)
                        .frame(minHeight: 90)
                        .overlay(alignment: .topLeading) {
                            if viewModel.description.isEmpty {
                                Text(ProfileStrings.descriptionPlaceholder.localized)
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                                    .allowsHitTesting(false)
                            }
                        }
                }
            }

            Toggle(ProfileStrings.publicProfileToggle.localized, isOn: $viewModel.isPublic)

            DSLoadingButton(
                ProfileStrings.saveProfileButton.localized,
                isLoading: viewModel.isSaving
            ) {
                Task { await viewModel.saveProfile() }
            }
        }
    }

    // MARK: - Avatar

    private var profileAvatar: some View {
        ZStack {
            if let avatarData = viewModel.avatarImage,
               let image = UIImage(data: avatarData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if let avatarUrl = viewModel.rider?.avatarUrl,
                      let url = URL(string: avatarUrl) {
                AsyncImage(url: url, transaction: Transaction()) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        placeholderIcon
                    }
                }
            } else {
                placeholderIcon
            }
        }
        .frame(width: 76, height: 76)
        .clipShape(Circle())
    }

    private var placeholderIcon: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFill()
            .foregroundStyle(.secondary)
    }

    // MARK: - Location

    private var locationSection: some View {
        Section(ProfileStrings.sectionBaseLocation.localized) {
            if hasLocation {
                locationMapPreview
            } else {
                noLocationPlaceholder
            }
        }
    }

    private var hasLocation: Bool {
        Double(viewModel.latitudeText) != nil && Double(viewModel.longitudeText) != nil
    }

    private var locationCoordinate: CLLocationCoordinate2D? {
        guard let lat = Double(viewModel.latitudeText),
              let lng = Double(viewModel.longitudeText) else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    private var locationMapPreview: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !viewModel.locationName.isEmpty {
                Text(viewModel.locationName)
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
            }

            if let coordinate = locationCoordinate {
                Map(position: .constant(.region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))), interactionModes: []) {
                    Marker(viewModel.locationName, coordinate: coordinate)
                        .tint(.red)
                }
                .frame(height: 180)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        showLocationPicker = true
                    } label: {
                        Label(ProfileStrings.pickOnMap.localized, systemImage: "pencil")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(12)
                }
            }
        }
        .listRowInsets(EdgeInsets())
    }

    private var noLocationPlaceholder: some View {
        Button {
            showLocationPicker = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ProfileStrings.noLocationSet.localized)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if viewModel.isSaving {
                    ProgressView().controlSize(.small)
                } else {
                    Image(systemName: "map")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sports

    private var sportsSection: some View {
        Section(ProfileStrings.sectionSports.localized) {
            if viewModel.allSports.isEmpty {
                Text(ProfileStrings.loadingSports.localized)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.allSports) { sport in
                    SportRow(
                        sport: sport,
                        riderSport: viewModel.riderSport(for: sport.id.uuidString),
                        isLoading: viewModel.isSportLoading(sport.id.uuidString),
                        onUpsert: { level, isMentor in
                            Task {
                                await viewModel.upsertSport(
                                    sportId: sport.id.uuidString,
                                    level: level,
                                    isMentor: isMentor
                                )
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Sport Row

private struct SportRow: View {
    let sport: Sport
    let riderSport: RiderSport?
    let isLoading: Bool
    let onUpsert: (SkillLevel, Bool) -> Void

    @State private var selectedLevel: SkillLevel = .casual
    @State private var isMentor: Bool = false

    private var hasChanges: Bool {
        let currentMentor = riderSport?.isMentor ?? false
        return isMentor != currentMentor
    }

    var body: some View {
        HStack {
            Text(sport.name)
                .fontWeight(.medium)

            Spacer()

            if isLoading {
                ProgressView()
                    .controlSize(.small)
            }
        }

        Toggle(ProfileStrings.availableAsMentorToggle.localized, isOn: $isMentor)
            .onAppear {
                if let rs = riderSport {
                    selectedLevel = rs.level
                    isMentor = rs.isMentor
                }
            }
            .onChange(of: riderSport?.isMentor) { _, newValue in
                if let newValue {
                    isMentor = newValue
                }
            }

        if hasChanges {
            DSLoadingButton(
                ProfileStrings.saveButton.localized,
                isLoading: isLoading
            ) {
                onUpsert(selectedLevel, isMentor)
            }
        }
    }
}
