//
//  ProfileView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

import SwiftUI
import Auth

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
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadProfile()
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.clearMessages() } }
        )) {
            Button("OK") { viewModel.clearMessages() }
        } message: {
            Text(viewModel.error ?? "")
        }
        .alert("Success", isPresented: .init(
            get: { viewModel.successMessage != nil },
            set: { if !$0 { viewModel.clearMessages() } }
        )) {
            Button("OK") { viewModel.clearMessages() }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
        .confirmationDialog(
            "Delete Account",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
                Task { await viewModel.deleteAccount() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
    
    // MARK: - Sections
    
    private var loadingSection: some View {
        Section {
            HStack {
                Spacer()
                ProgressView("Loading profile...")
                Spacer()
            }
            .padding(.vertical, 40)
        }
    }
    
    private var profileSection: some View {
        Section("Profile Information") {
            TextField("Display Name", text: $viewModel.displayName)
                .textContentType(.name)
            
            Picker("Type", selection: $viewModel.selectedType) {
                ForEach(RiderType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Description")
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
                    Text("Save Profile")
                }
                .frame(maxWidth: .infinity)
            }
            .disabled(viewModel.isSaving)
        }
    }
    
    private var avatarSection: some View {
        Section("Avatar") {
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
            
            // TODO: Add image picker when PhotosUI is available
            Text("Avatar upload coming soon")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var locationSection: some View {
        Section("Base Location") {
            TextField("Location Name", text: $viewModel.locationName)
            
            HStack {
                TextField("Latitude", text: $viewModel.latitudeText)
                    .keyboardType(.decimalPad)
                
                TextField("Longitude", text: $viewModel.longitudeText)
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
                    Text("Save Location")
                }
                .frame(maxWidth: .infinity)
            }
            .disabled(viewModel.isSaving)
        }
    }
    
    private var sportsSection: some View {
        Section("Sports") {
            if viewModel.allSports.isEmpty {
                Text("Loading sports...")
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
        Section("Danger Zone") {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Account")
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
                Picker("Level", selection: $selectedLevel) {
                    ForEach(SkillLevel.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(.segmented)
                
                Toggle("Available as Mentor", isOn: $isMentor)
                
                HStack {
                    Button("Save") {
                        onUpsert(selectedLevel, isMentor)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                    
                    if riderSport != nil {
                        Button("Remove", role: .destructive) {
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

