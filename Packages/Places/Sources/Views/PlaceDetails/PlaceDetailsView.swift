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
    public let placeTags: [String]
    public let sportIds: [UUID]
    public let sportSlugs: [String]
    public let ridersCount: Int
    public let mentorsCount: Int
    public let avatar: Avatar

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
        avatar: Avatar
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
    }

    public var sportFilters: [SportFilter] {
        zip(sportSlugs, sportTags).map { SportFilter(slug: $0.0, title: $0.1) }
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
                sportFilters: viewData.sportFilters,
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
            sportFiltersSection
            placeTagsSection

            if !viewData.description.isEmpty {
                Text(viewData.description)
                    .dsTextStyle(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, theme.spacing.lg)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, theme.spacing.sm)
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
        .padding(.top, theme.spacing.sm)
    }

    private func tabTitle(for tab: DetailTab) -> String {
        switch tab {
        case .riders:
            return "\(PlacesStrings.ridersLabel.localized) (\(viewModel.ridersCount))"
        case .mentors:
            return "\(PlacesStrings.mentorsLabel.localized) (\(viewModel.mentorsCount))"
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
