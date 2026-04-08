//
//  PlaceDetailsView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import SwiftUI
import Theme
import Networking
import Common

// MARK: - View Data

public struct PlaceDetailsViewData: Equatable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let description: String
    public let sportTags: [String]
    public let placeTags: [String]
    public let sportIds: [UUID]
    public let sportSlugs: [String]
    public let ridersCount: Int
    public let mentorsCount: Int
    public let avatar: Avatar
    public let latitude: Double?
    public let longitude: Double?

    public struct SportFilter: Equatable, Hashable, Sendable, Identifiable {
        public let id: String
        public let title: String
        public let slug: String

        public init(slug: String, title: String) {
            self.id = slug
            self.slug = slug
            self.title = title
        }
    }

    public init(
        id: UUID,
        name: String,
        description: String,
        sportTags: [String],
        placeTags: [String],
        sportIds: [UUID],
        sportSlugs: [String],
        ridersCount: Int,
        mentorsCount: Int,
        avatar: Avatar,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.sportTags = sportTags
        self.placeTags = placeTags
        self.sportIds = sportIds
        self.sportSlugs = sportSlugs
        self.ridersCount = ridersCount
        self.mentorsCount = mentorsCount
        self.avatar = avatar
        self.latitude = latitude
        self.longitude = longitude
    }

    public var sportFilters: [SportFilter] {
        zip(sportSlugs, sportTags).map { SportFilter(slug: $0.0, title: $0.1) }
    }
}

// MARK: - View

public struct PlaceDetailsView: View {
    enum DetailTab: String, CaseIterable, Identifiable {
        case mentors, riders, map
        var id: String { rawValue }
    }
    
    @Environment(AppTheme.self) private var theme
    @Environment(AuthState.self) private var authState
    let viewData: PlaceDetailsViewData
    private let onRequestLogin: (() -> Void)?

    @State private var selectedTab: DetailTab = .mentors
    @State private var viewModel: PlaceDetailsViewModel

    public init(
        viewData: PlaceDetailsViewData,
        placesService: PlacesServiceProtocol,
        authState: AuthState,
        sportPreferenceStorage: any SportPreferenceStorageProtocol,
        onRequestLogin: (() -> Void)? = nil
    ) {
        self.viewData = viewData
        self.onRequestLogin = onRequestLogin
        _viewModel = State(
            wrappedValue: PlaceDetailsViewModel(
                placeId: viewData.id,
                sportIds: viewData.sportIds,
                sportFilters: viewData.sportFilters,
                placesService: placesService,
                authState: authState,
                sportPreferenceStorage: sportPreferenceStorage
            )
        )
    }

    private var hasLocation: Bool { viewData.latitude != nil && viewData.longitude != nil }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                infoSection
                if authState.isLoggedIn {
                    checkInSection
                    tabSection
                    contentSection
                } else {
                    guestGateSection
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(theme.colors.backgroundSecondary)
        .navigationTitle(viewData.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            guard authState.isLoggedIn else { return }
            await viewModel.applySavedSportPreference()
            async let membership: Void = viewModel.checkMembership()
            async let riders: Void = viewModel.loadRiders()
            _ = await (membership, riders)
        }
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

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            heroPhoto

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.3),
                    .init(color: .black.opacity(0.7), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                sportFiltersSection
                placeTagsSection
            }
            .padding(.bottom, theme.spacing.md)
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if !viewData.description.isEmpty {
                Text(viewData.description)
                    .dsTextStyle(.subheadline)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
    }

    @ViewBuilder
    private var heroPhoto: some View {
        GeometryReader { geo in
            let size = geo.size.width
            let offset = -size * 0.1

            switch viewData.avatar {
            case .imageRemote(let url):
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                            .frame(width: size, height: size)
                            .clipped()
                    default:
                        heroPhotoPlaceholder
                            .frame(width: size, height: size)
                    }
                }
                .offset(y: offset)
            default:
                heroPhotoPlaceholder
                    .frame(width: size, height: size)
                    .offset(y: offset)
            }
        }
        .aspectRatio(1 / 0.9, contentMode: .fit)
        .clipped()
    }

    private var heroPhotoPlaceholder: some View {
        ZStack {
            theme.colors.surfaceTertiary
            Image(systemName: "mountain.2")
                .font(.system(size: 48))
                .foregroundStyle(theme.colors.textTertiary)
        }
    }

    // MARK: - Guest Gate

    private var guestGateSection: some View {
        PlaceDetailsGuestGate(onSignInTap: onRequestLogin)
            .padding(.horizontal, theme.spacing.md)
            .padding(.top, theme.spacing.md)
    }

    // MARK: - Check-In

    @ViewBuilder
    private var checkInSection: some View {
        if !viewModel.isCheckingMembership {
            if viewModel.hasJoined {
                checkedInStrip
            } else {
                checkInButton
            }
        }
    }

    private var checkInButton: some View {
        Button {
            viewModel.showRolePicker = true
        } label: {
            HStack(spacing: theme.spacing.xs) {
                if viewModel.isJoining {
                    ProgressView()
                        .controlSize(.small)
                        .tint(theme.colors.primary)
                }
                Text(PlacesStrings.checkInButton.localized)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.dsOutline)
        .disabled(viewModel.isJoining)
        .padding(.horizontal, theme.spacing.md)
        .padding(.top, theme.spacing.md)
    }

    private var checkedInStrip: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(theme.colors.success)
                .font(.title3)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(PlacesStrings.checkedInTitle.localized)
                    .dsTextStyle(.body)

                Text(PlacesStrings.checkedInRole(viewModel.joinedRole?.displayName ?? "—"))
                    .dsTextStyle(.caption)
            }

            Spacer()

            Button(PlacesStrings.checkOutButton.localized) {
                Task { await viewModel.leavePlace() }
            }
            .buttonStyle(.dsOutline)
            .disabled(viewModel.isLeaving)
        }
        .padding(theme.spacing.sm)
        .background(theme.colors.success.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
        .padding(.horizontal, theme.spacing.md)
        .padding(.top, theme.spacing.md)
    }

    // MARK: - Tabs

    private var availableTabs: [DetailTab] {
        hasLocation ? DetailTab.allCases : [.riders, .mentors]
    }

    private var tabSection: some View {
        HStack(spacing: 0) {
            ForEach(availableTabs) { tab in
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
        .padding(.top, theme.spacing.md)
    }

    private func tabTitle(for tab: DetailTab) -> String {
        switch tab {
        case .riders:
            return "\(PlacesStrings.ridersLabel.localized) (\(viewModel.ridersCount))"
        case .mentors:
            return "\(PlacesStrings.mentorsLabel.localized) (\(viewModel.mentorsCount))"
        case .map:
            return PlacesStrings.mapLabel.localized
        }
    }

    // MARK: - Content

    private var contentSection: some View {
        VStack(spacing: theme.spacing.md) {
            if viewModel.isLoadingRiders {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                switch selectedTab {
                case .riders:
                    ridersList(
                        rows: viewModel.ridersRows,
                        emptyTitle: PlacesStrings.detailsRidersEmptyTitle.localized,
                        emptySubtitle: PlacesStrings.detailsRidersEmptyDescription.localized,
                        emptyIcon: "figure.snowboarding"
                    )
                case .mentors:
                    ridersList(
                        rows: viewModel.mentorsRows,
                        emptyTitle: PlacesStrings.detailsMentorsEmptyTitle.localized,
                        emptySubtitle: PlacesStrings.detailsMentorsEmptyDescription.localized,
                        emptyIcon: "person.badge.shield.checkmark"
                    )
                case .map:
                    PlaceDetailsMapView(viewData: viewData, riderEntries: viewModel.riderEntries)
                        .frame(height: 420)
                        .padding(.horizontal, -theme.spacing.md)
                }
            }
        }
        .padding(.top, theme.spacing.xs)
        .padding(.horizontal, theme.spacing.md)
    }

    // MARK: - Filters

    @ViewBuilder
    private var sportFiltersSection: some View {
        if !viewModel.sportFilters.isEmpty {
            PlaceSportFiltersRow(
                filters: viewModel.sportFilters,
                selectedSportSlug: viewModel.selectedSportSlug,
                horizontalContentPadding: theme.spacing.md
            ) { sportSlug in
                Task { await viewModel.selectSport(sportSlug) }
            }
        }
    }

    private var placeTagsSection: some View {
        PlaceTagsRow(tags: viewData.placeTags, horizontalContentPadding: theme.spacing.md)
    }

    // MARK: - Riders List

    @ViewBuilder
    private func ridersList(
        rows: [PlaceRiderRowViewData],
        emptyTitle: String,
        emptySubtitle: String,
        emptyIcon: String
    ) -> some View {
        if rows.isEmpty {
            placeholderList(title: emptyTitle, subtitle: emptySubtitle, icon: emptyIcon)
        } else {
            LazyVStack(spacing: 0) {
                ForEach(rows) { row in
                    NavigationLink(value: PlacesRoute.riderCard(row.riderCardData)) {
                        PlaceRiderRow(viewData: row)
                            .padding(.vertical, theme.spacing.xs)
                    }
                    .buttonStyle(.plain)

                    if row.id != rows.last?.id {
                        Divider()
                            .overlay(theme.colors.border.opacity(0.35))
                    }
                }
            }
        }
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
