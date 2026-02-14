//
//  ProfileView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

import SwiftUI
import Networking
import Common

public struct ProfileView: View {
    
    @State private var viewModel: ProfileViewModel
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: ProfileViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        Form {
            if viewModel.isLoading && viewModel.rider == nil {
                loadingSection
            } else {
                profileSection
                avatarSection
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
            TextField(ProfileStrings.displayNamePlaceholder.localized, text: $viewModel.displayName)
                .textContentType(.name)
            
            Picker(ProfileStrings.typePickerTitle.localized, selection: $viewModel.selectedType) {
                ForEach(RiderType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(ProfileStrings.descriptionLabel.localized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 100)
            }
            
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
    }
    
    private var avatarSection: some View {
        Section(ProfileStrings.sectionAvatar.localized) {
            if let avatarUrl = viewModel.rider?.avatarUrl,
               let url = URL(string: avatarUrl) {
                HStack {
                    Spacer()
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    Spacer()
                }
            }
            
                        Text(ProfileStrings.avatarUploadComingSoon.localized)
                .font(.caption)
                .foregroundStyle(.secondary)
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
                        riderSport: viewModel.riderSport(for: sport.id),
                        isLoading: viewModel.isSportLoading(sport.id),
                        onUpsert: { level, isMentor in
                            Task {
                                await viewModel.upsertSport(
                                    sportId: sport.id,
                                    level: level,
                                    isMentor: isMentor
                                )
                            }
                        },
                        onRemove: {
                            Task {
                                await viewModel.removeSport(sportId: sport.id)
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

