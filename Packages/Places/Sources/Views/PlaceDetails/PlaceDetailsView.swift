//
//  PlaceDetailsView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import SwiftUI
import Theme
import Networking

// MARK: - View Data

public struct PlaceDetailsViewData: Equatable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let description: String
    public let sportTags: [String]
    public let sportIds: [UUID]
    public let ridersCount: Int
    public let mentorsCount: Int
    public let avatar: Avatar

    public init(
        id: UUID,
        name: String,
        description: String,
        sportTags: [String],
        sportIds: [UUID],
        ridersCount: Int,
        mentorsCount: Int,
        avatar: Avatar
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.sportTags = sportTags
        self.sportIds = sportIds
        self.ridersCount = ridersCount
        self.mentorsCount = mentorsCount
        self.avatar = avatar
    }
}

// MARK: - View

struct PlaceDetailsView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(AuthState.self) private var authState
    let viewData: PlaceDetailsViewData

    @State private var selectedTab: DetailTab = .riders
    @State private var viewModel: PlaceDetailsViewModel

    enum DetailTab: String, CaseIterable, Identifiable {
        case riders
        case mentors

        var id: String { rawValue }
    }

    init(viewData: PlaceDetailsViewData, placesService: PlacesServiceProtocol, authState: AuthState) {
        self.viewData = viewData
        _viewModel = State(
            wrappedValue: PlaceDetailsViewModel(
                placeId: viewData.id,
                sportIds: viewData.sportIds,
                placesService: placesService,
                authState: authState
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                checkInSection
                tabSection
                contentSection
            }
        }
        .background(theme.colors.background)
        .navigationTitle(viewData.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { }
        .alert(
            PlacesStrings.checkInErrorTitle.localized,
            isPresented: .init(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.clearError() } }
            )
        ) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.error ?? "")
        }
        .confirmationDialog(
            PlacesStrings.checkInRoleTitle.localized,
            isPresented: $viewModel.showRolePicker,
            titleVisibility: .visible
        ) {
            Button(PlacesStrings.roleRider.localized) {
                Task { await viewModel.joinWith(role: .rider) }
            }
            Button(PlacesStrings.roleMentor.localized) {
                Task { await viewModel.joinWith(role: .mentor) }
            }
            Button(PlacesStrings.cancelButton.localized, role: .cancel) {}
        } message: {
            Text(PlacesStrings.checkInRoleMessage.localized)
        }
    }

    // MARK: - Check-In Section

    @ViewBuilder
    private var checkInSection: some View {
        if authState.isLoggedIn {
            VStack(spacing: theme.spacing.sm) {
                if viewModel.hasJoined {
                    HStack(spacing: theme.spacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(theme.colors.primary)
                        Text(PlacesStrings.checkedInAs(
                            viewModel.joinedRole?.displayName ?? ""
                        ))
                        .dsTextStyle(.subheadline)
                    }
                } else {
                    Button {
                        viewModel.showRolePicker = true
                    } label: {
                        HStack {
                            if viewModel.isJoining {
                                ProgressView()
                                    .controlSize(.small)
                                    .tint(theme.colors.primaryForeground)
                            }
                            Image(systemName: "mappin.and.ellipse")
                            Text(PlacesStrings.checkInButton.localized)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.dsPrimary)
                    .disabled(viewModel.isJoining)
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: theme.spacing.sm) {
            heroAvatar
                .padding(.top, theme.spacing.md)

                Text(viewData.name)
                    .dsTextStyle(.title)
            sportBadges

            if !viewData.description.isEmpty {
                Text(viewData.description)
                    .dsTextStyle(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, theme.spacing.lg)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, theme.spacing.lg)
    }

    @ViewBuilder
    private var heroAvatar: some View {
        Group {
            switch viewData.avatar {
            case .initials(let text):
                ZStack {
                    Circle().fill(theme.colors.surfaceTertiary)
                    Text(text)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(theme.colors.textSecondary)
                }
            case .imageRemote(let url):
                if let url {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Circle().fill(theme.colors.surfaceTertiary)
                        }
                    }
                    .clipShape(Circle())
                } else {
                    Circle().fill(theme.colors.surfaceTertiary)
                }
            case .image(let name):
                Image(name).resizable().scaledToFill().clipShape(Circle())
            }
        }
        .frame(width: 80, height: 80)
    }

    private var sportBadges: some View {
//        TODO: handle more than one row of pills 
        HStack(spacing: theme.spacing.xs) {
            ForEach(viewData.sportTags, id: \.self) { sportTag in
                PillView(title: sportTag, theme: theme)
            }
        }
    }

    // MARK: - Tabs

    private var tabSection: some View {
        HStack(spacing: 0) {
            ForEach(DetailTab.allCases) { tab in
                Button {
                    withAnimation(.snappy(duration: Constants.Animation.chipDuration)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: theme.spacing.xs) {
                        Text(tabTitle(for: tab))
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .foregroundStyle(
                                selectedTab == tab
                                    ? theme.colors.primary
                                    : theme.colors.textSecondary
                            )

                        Rectangle()
                            .fill(selectedTab == tab ? theme.colors.primary : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.top, theme.spacing.lg)
    }

    private func tabTitle(for tab: DetailTab) -> String {
        switch tab {
        case .riders:
            return "\(PlacesStrings.ridersLabel.localized) (\(viewData.ridersCount))"
        case .mentors:
            return "\(PlacesStrings.mentorsLabel.localized) (\(viewData.mentorsCount))"
        }
    }

    // MARK: - Content (placeholder for future rider list)

    private var contentSection: some View {
        VStack(spacing: theme.spacing.md) {
            switch selectedTab {
            case .riders:
                placeholderList(
                    title: PlacesStrings.detailsRidersEmptyTitle.localized,
                    subtitle: PlacesStrings.detailsRidersEmptyDescription.localized,
                    icon: "figure.snowboarding"
                )
            case .mentors:
                placeholderList(
                    title: PlacesStrings.detailsMentorsEmptyTitle.localized,
                    subtitle: PlacesStrings.detailsMentorsEmptyDescription.localized,
                    icon: "person.badge.shield.checkmark"
                )
            }
        }
        .padding(.top, theme.spacing.md)
        .padding(.horizontal, theme.spacing.md)
    }

    private func placeholderList(title: String, subtitle: String, icon: String) -> some View {
        VStack(spacing: theme.spacing.sm) {
            Spacer().frame(height: theme.spacing.xl)
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(theme.colors.textTertiary)
            Text(title)
                .dsTextStyle(.heading)
            Text(subtitle)
                .dsTextStyle(.subheadline)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
