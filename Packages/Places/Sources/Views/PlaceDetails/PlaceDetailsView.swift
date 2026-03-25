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
    @Environment(AppTheme.self) private var theme
    @Environment(AuthState.self) private var authState
    let viewData: PlaceDetailsViewData

    @State private var selectedTab: DetailTab = .riders
    @State private var viewModel: PlaceDetailsViewModel

    enum DetailTab: String, CaseIterable, Identifiable {
        case riders
        case mentors
        case map

        var id: String { rawValue }
    }

    public init(viewData: PlaceDetailsViewData, placesService: PlacesServiceProtocol, authState: AuthState) {
        self.viewData = viewData
        _viewModel = State(
            wrappedValue: PlaceDetailsViewModel(
                placeId: viewData.id,
                sportIds: viewData.sportIds,
                sportFilters: viewData.sportFilters,
                placesService: placesService,
                authState: authState
            )
        )
    }

    private var hasLocation: Bool { viewData.latitude != nil && viewData.longitude != nil }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroPhoto
                heroInfo
                checkInSection
                tabSection
                contentSection
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(theme.colors.background)
        .navigationTitle(viewData.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadRiders()
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

    // MARK: - Check-In Section

    @ViewBuilder
    private var checkInSection: some View {
        if authState.isLoggedIn {
            VStack(spacing: theme.spacing.md) {
                if viewModel.hasJoined {
                    checkedInCard
                } else {
                    checkInCard
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.top, theme.spacing.md)
        }
    }
    
    private var checkedInCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(spacing: theme.spacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.14))
                        .frame(width: 44, height: 44)

                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                        .font(.system(size: 20, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Jesteś checked-in")
                        .dsTextStyle(.heading)

                    Text("Rola: \(viewModel.joinedRole?.displayName ?? "—")")
                        .dsTextStyle(.subheadline)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer()
            }

            HStack(spacing: theme.spacing.sm) {
                Button {
                    viewModel.showRolePicker = true
                } label: {
                    Text("Zmień rolę")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.dsOutline)

                Button(role: .destructive) {
                    // przyszłościowo: Task { await viewModel.checkOut() }
                } label: {
                    Text("Check out")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(theme.spacing.md)
        .background(Color.green.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.green.opacity(0.22), lineWidth: 1)
        )
    }
    
    private var checkInCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                ZStack {
                    Circle()
                        .fill(theme.colors.primary.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(theme.colors.primary)
                        .font(.system(size: 18, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Dołącz do spotu")
                        .dsTextStyle(.heading)

                    Text("Daj znać innym, że jesteś na miejscu jako Rider albo Mentor.")
                        .dsTextStyle(.subheadline)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer()
            }

            HStack(spacing: theme.spacing.sm) {
                spotStatPill(
                    icon: "figure.outdoor.cycle",
                    text: "\(viewModel.ridersCount) rider\(viewModel.ridersCount == 1 ? "" : "ów")"
                )

                spotStatPill(
                    icon: "person.badge.shield.checkmark",
                    text: "\(viewModel.mentorsCount) mentor\(viewModel.mentorsCount == 1 ? "" : "ów")"
                )
            }

            Button {
                viewModel.showRolePicker = true
            } label: {
                HStack(spacing: theme.spacing.sm) {
                    if viewModel.isJoining {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    }

                    Text("Check in")
                        .fontWeight(.semibold)

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color.white)
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.md)
                .frame(maxWidth: .infinity)
                .background(theme.colors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isJoining)
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(theme.colors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
    }
    
    private func spotStatPill(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
            Text(text)
                .font(.footnote)
                .fontWeight(.medium)
        }
        .foregroundStyle(theme.colors.textSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(theme.colors.surfaceSecondary)
        .clipShape(Capsule())
    }

    // MARK: - Hero

    @ViewBuilder
    private var heroPhoto: some View {
        switch viewData.avatar {
        case .imageRemote(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure, .empty:
                    heroPhotoPlaceholder
                @unknown default:
                    heroPhotoPlaceholder
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipped()
        default:
            heroPhotoPlaceholder
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)
        }
    }

    private var heroPhotoPlaceholder: some View {
        ZStack {
            theme.colors.surfaceTertiary
            Image(systemName: "mountain.2")
                .font(.system(size: 48))
                .foregroundStyle(theme.colors.textTertiary)
        }
    }

    private var heroInfo: some View {
        VStack(
            alignment: .leading,
            spacing: theme.spacing.sm
        ) {
            sportFiltersSection
            placeTagsSection

            if !viewData.description.isEmpty {
                Text(viewData.description)
                    .dsTextStyle(.subheadline)
                    .padding(.horizontal, theme.spacing.lg)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, theme.spacing.sm)
        .padding(.bottom, theme.spacing.sm)
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
        .padding(.top, theme.spacing.sm)
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
                        .clipShape(RoundedRectangle(cornerRadius: 0))
                }
            }
        }
        .padding(.top, theme.spacing.xs)
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var sportFiltersSection: some View {
        if !viewModel.sportFilters.isEmpty {
            PlaceSportFiltersRow(
                filters: viewModel.sportFilters,
                selectedSportSlug: viewModel.selectedSportSlug
            ) { sportSlug in
                Task { await viewModel.selectSport(sportSlug) }
            }
        }
    }

    private var placeTagsSection: some View {
        PlaceTagsRow(tags: viewData.placeTags, horizontalContentPadding: theme.spacing.md)
    }

    @ViewBuilder
    private func ridersList(rows: [PlaceRiderRowViewData], emptyTitle: String, emptySubtitle: String, emptyIcon: String) -> some View {
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
