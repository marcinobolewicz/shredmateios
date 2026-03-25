import SwiftUI
import Networking
import Common
import MediaPicker
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
            let initialCoord: CLLocationCoordinate2D? = {
                guard let lat = Double(viewModel.latitudeText),
                      let lng = Double(viewModel.longitudeText) else { return nil }
                return CLLocationCoordinate2D(latitude: lat, longitude: lng)
            }()
            MapLocationPickerView(
                initialCoordinate: initialCoord,
                initialLocationName: viewModel.locationName
            ) { coord, name in
                viewModel.latitudeText = String(format: "%.6f", coord.latitude)
                viewModel.longitudeText = String(format: "%.6f", coord.longitude)
                viewModel.locationName = name
                Task { await viewModel.saveBaseLocation() }
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

            Button {
                Task { await viewModel.saveProfile() }
            } label: {
                HStack {
                    if viewModel.isSaving {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text(ProfileStrings.saveProfileButton.localized)
                }
                .frame(maxWidth: .infinity)
            }
            .disabled(viewModel.isSaving)
        }
        .imageCropPicker(isPresented: $showAvatarPicker) { result in
            if case .success(let data) = result {
                viewModel.avatarImage = data
            }
        }
    }

    // MARK: - Avatar

    @ViewBuilder
    private var profileAvatar: some View {
        if let avatarData = viewModel.avatarImage,
           let image = UIImage(data: avatarData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 76, height: 76)
                .clipShape(Circle())
        } else if let avatarUrl = viewModel.rider?.avatarUrl,
                  let url = URL(string: avatarUrl) {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 76, height: 76)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFill()
                .foregroundStyle(.secondary)
                .frame(width: 76, height: 76)
        }
    }

    // MARK: - Location

    private var locationSection: some View {
        Section(ProfileStrings.sectionBaseLocation.localized) {
            Button {
                showLocationPicker = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if !viewModel.locationName.isEmpty {
                            Text(viewModel.locationName)
                                .foregroundStyle(.primary)
                            if !viewModel.latitudeText.isEmpty {
                                Text("\(viewModel.latitudeText), \(viewModel.longitudeText)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } else if !viewModel.latitudeText.isEmpty {
                            Text("\(viewModel.latitudeText), \(viewModel.longitudeText)")
                                .foregroundStyle(.primary)
                        } else {
                            Text(ProfileStrings.noLocationSet.localized)
                                .foregroundStyle(.secondary)
                        }
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
                        },
                        onRemove: {
                            Task {
                                await viewModel.removeSport(sportId: sport.id.uuidString)
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
    let onRemove: () -> Void

    @State private var selectedLevel: SkillLevel = .casual
    @State private var isMentor: Bool = false
    @State private var isExpanded: Bool = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                Picker(ProfileStrings.levelPickerTitle.localized, selection: $selectedLevel) {
                    ForEach(SkillLevel.allCases, id: \.self) { level in
                        Text(level.localizedName).tag(level)
                    }
                }
                .pickerStyle(.segmented)

                Toggle(ProfileStrings.availableAsMentorToggle.localized, isOn: $isMentor)

                HStack {
                    Button(ProfileStrings.saveButton.localized) {
                        onUpsert(selectedLevel, isMentor)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)

                    if riderSport != nil {
                        Button(ProfileStrings.removeButton.localized, role: .destructive) {
                            onRemove()
                        }
                        .buttonStyle(.bordered)
                        .disabled(isLoading)
                    }

                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
            .padding(.vertical, 8)
        } label: {
            HStack {
                Text(sport.name)
                    .fontWeight(.medium)

                Spacer()

                if let rs = riderSport {
                    Text(rs.level.localizedName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())

                    if rs.isMentor {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                    }
                }
            }
        }
        .onAppear {
            if let rs = riderSport {
                selectedLevel = rs.level
                isMentor = rs.isMentor
            }
        }
    }
}
