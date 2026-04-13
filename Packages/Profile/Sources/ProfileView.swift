//
//  ProfileView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

import SwiftUI
import Networking
import Common
import Theme



public enum ProfileRoute: Hashable, Sendable {
    case editRider
    case myBookings
    case mySlots
    case generateSlots
    case stripeOnboarding
    case contact
}

public struct ProfileView: View {
    @Environment(AppTheme.self) private var theme
    @State private var viewModel: ProfileViewModel
    @State private var showDeleteConfirmation = false
    @Binding private var path: [ProfileRoute]

    public init(viewModel: ProfileViewModel, path: Binding<[ProfileRoute]>) {
        self._viewModel = State(initialValue: viewModel)
        self._path = path
    }

    public var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                DSScreenHeader(title: ProfileStrings.navigationTitle.localized)
                Form {
                    if viewModel.isLoading && viewModel.rider == nil {
                        loadingSection
                    } else {
                        headerSection
                        menuSection
                            .listRowSeparator(.hidden)
                        accountSection
                            .listRowSeparator(.hidden)
                        supportSection
                            .listRowSeparator(.hidden)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .background(theme.colors.backgroundSecondary)
            .navigationBarHidden(true)
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .editRider:
                    EditRiderView(viewModel: viewModel)
                case .myBookings:
                    MyBookingsView(service: viewModel.mentorSlotsService)
                case .mySlots:
                    MySlotsView(service: viewModel.mentorSlotsService)
                case .generateSlots:
                    GenerateSlotsView(
                        mentorSlotsService: viewModel.mentorSlotsService,
                        placesService: viewModel.placesService,
                        riderSports: viewModel.riderSports
                    )
                case .stripeOnboarding:
                    StripeOnboardingView(viewModel: viewModel.stripeOnboardingViewModel)
                case .contact:
                    ContactView()
                }
            }
            .navigationDestination(for: UUID.self) { riderId in
                MyPostsView(riderId: riderId.uuidString.lowercased(), feedService: viewModel.feedService)
            }
        }
        .task {
            await viewModel.loadProfile()
        }
        .profileAlerts(viewModel: viewModel)
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

    // MARK: - Header

    private var headerSection: some View {
        Section {
            HStack(spacing: 16) {
                profileAvatar
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.displayName.isEmpty
                         ? (viewModel.rider?.displayName ?? "")
                         : viewModel.displayName)
                        .font(.title3.weight(.semibold))
                    if let desc = viewModel.rider?.description, !desc.isEmpty {
                        Text(desc)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding(.vertical, 4)
            .listRowSeparator(.hidden)
        }
    }

    @ViewBuilder
    private var profileAvatar: some View {
        if let avatarUrl = viewModel.rider?.avatarUrl,
           let url = URL(string: avatarUrl) {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFill()
                .foregroundStyle(.secondary)
                .frame(width: 64, height: 64)
        }
    }

    // MARK: - Menu

    private var menuSection: some View {
        Section {
            NavigationLink(value: ProfileRoute.editRider) {
                Label(ProfileStrings.editRiderTitle.localized, systemImage: "pencil")
            }

            if let riderId = viewModel.riderId {
                NavigationLink(value: riderId) {
                    Label(ProfileStrings.myPostsNavigationTitle.localized, systemImage: "newspaper")
                }
            }

            NavigationLink(value: ProfileRoute.myBookings) {
                Label(ProfileStrings.myBookingsTitle.localized, systemImage: "calendar.badge.clock")
            }

            NavigationLink(value: ProfileRoute.mySlots) {
                Label(ProfileStrings.mySlotsTitle.localized, systemImage: "clock.badge")
            }

            if viewModel.hasMentorSports {
                NavigationLink(value: ProfileRoute.generateSlots) {
                    Label(ProfileStrings.generateSlotsTitle.localized, systemImage: "calendar.badge.plus")
                }
            }

            if viewModel.hasMentorSports {
                NavigationLink(value: ProfileRoute.stripeOnboarding) {
                    Label(StripeStrings.navigationTitle.localized, systemImage: "creditcard")
                }
            }
        }
    }

    // MARK: - Support & Legal

    private var supportSection: some View {
        Section(ProfileStrings.sectionSupport.localized) {
            NavigationLink(value: ProfileRoute.contact) {
                Label(ProfileStrings.contactTitle.localized, systemImage: "envelope")
            }

            DSLinkButton(
                ProfileStrings.termsTitle.localized,
                systemImage: "doc.text",
                url: URL(string: "https://shredmate.pl/terms")!
            )

            DSLinkButton(
                ProfileStrings.privacyTitle.localized,
                systemImage: "hand.raised",
                url: URL(string: "https://shredmate.pl/privacy")!
            )
        }
    }

    // MARK: - Account

    private var accountSection: some View {
        Section {
            Button(role: .destructive) {
                Task { await viewModel.logout() }
            } label: {
                Label(ProfileStrings.logoutButton.localized, systemImage: "rectangle.portrait.and.arrow.right")
            }

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label(ProfileStrings.deleteAccountButton.localized, systemImage: "trash")
            }
        }
    }

    // MARK: - Loading

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
}

// MARK: - Profile Alerts

private struct ProfileAlertsModifier: ViewModifier {
    @Bindable var viewModel: ProfileViewModel

    func body(content: Content) -> some View {
        content
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
    }
}

extension View {
    func profileAlerts(viewModel: ProfileViewModel) -> some View {
        modifier(ProfileAlertsModifier(viewModel: viewModel))
    }
}
