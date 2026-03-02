//
//  ProfileView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

import SwiftUI
import Networking
import Common
import PhotosUI
import UIKit

public struct ProfileView: View {

    @State private var viewModel: ProfileViewModel
    @State private var showDeleteConfirmation = false
    @State private var selectedAvatarItem: PhotosPickerItem?
    private let avatarImageProcessor = AvatarImageProcessor()

    public init(viewModel: ProfileViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        Form {
            if viewModel.isLoading && viewModel.rider == nil {
                loadingSection
            } else {
                profileSection
                locationSection
                sportsSection
                dangerZoneSection
            }
        }
        .navigationTitle(ProfileStrings.navigationTitle.localized)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadProfile()
        }
        .alert(CommonStrings.errorTitle.localized, isPresented: .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.clearMessages() } }
        )) {
            Button(CommonStrings.okButton.localized) { viewModel.clearMessages() }
        } message: {
            Text(viewModel.error ?? "")
        }
        .alert(ProfileStrings.successAlertTitle.localized, isPresented: .init(
            get: { viewModel.successMessage != nil },
            set: { if !$0 { viewModel.clearMessages() } }
        )) {
            Button(CommonStrings.okButton.localized) { viewModel.clearMessages() }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
        .confirmationDialog(
            ProfileStrings.deleteAccountDialogTitle.localized,
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(ProfileStrings.deleteAccountButton.localized, role: .destructive) {
                Task { await viewModel.deleteAccount() }
            }
            Button(CommonStrings.cancelButton.localized, role: .cancel) {}
        } message: {
            Text(ProfileStrings.deleteAccountDialogMessage.localized)
        }
    }

    // MARK: - Sections

    private var loadingSection: some View {
        Section {
            HStack {
                Spacer()
                ProgressView(ProfileStrings.loadingProfile.localized)
                Spacer()
            }
            .padding(.vertical, 40)
        }
    }

    private var profileSection: some View {
        Section(ProfileStrings.sectionProfileInformation.localized) {
            HStack(alignment: .top, spacing: 16) {
                PhotosPicker(
                    selection: $selectedAvatarItem,
                    matching: .images
                ) {
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
                }
            }

            Text(ProfileStrings.avatarUploadComingSoon.localized)
                .font(.caption)
                .foregroundStyle(.secondary)

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
        .onChange(of: selectedAvatarItem) { _, newItem in
            guard let newItem else { return }
            Task {
                guard let data = try? await newItem.loadTransferable(type: Data.self) else { return }
                viewModel.avatarImage = avatarImageProcessor.process(data) ?? data
            }
        }
    }

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
                image
                    .resizable()
                    .scaledToFill()
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

    private var locationSection: some View {
        Section(ProfileStrings.sectionBaseLocation.localized) {
            TextField(ProfileStrings.locationNamePlaceholder.localized, text: $viewModel.locationName)

            HStack {
                TextField(ProfileStrings.latitudePlaceholder.localized, text: $viewModel.latitudeText)
                    .keyboardType(.decimalPad)

                TextField(ProfileStrings.longitudePlaceholder.localized, text: $viewModel.longitudeText)
                    .keyboardType(.decimalPad)
            }

            Button {
                Task { await viewModel.saveBaseLocation() }
            } label: {
                HStack {
                    if viewModel.isSaving {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text(ProfileStrings.saveLocationButton.localized)
                }
                .frame(maxWidth: .infinity)
            }
            .disabled(viewModel.isSaving)
        }
    }

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

    private var dangerZoneSection: some View {
        Section(ProfileStrings.sectionDangerZone.localized) {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text(ProfileStrings.deleteAccountButton.localized)
                }
                .frame(maxWidth: .infinity)
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

    @State private var selectedLevel: SkillLevel = .beginner
    @State private var isMentor: Bool = false
    @State private var isExpanded: Bool = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                Picker(ProfileStrings.levelPickerTitle.localized, selection: $selectedLevel) {
                    ForEach(SkillLevel.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
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
                    Text(rs.level.displayName)
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
