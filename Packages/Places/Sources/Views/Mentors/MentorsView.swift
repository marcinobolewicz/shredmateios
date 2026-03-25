import SwiftUI
import Theme
import Networking

struct MentorsView: View {
    @Environment(AppTheme.self) private var theme
    @State private var viewModel: MentorsViewModel

    init(
        mentorsService: MentorsServiceProtocol,
        sportsService: SportsServiceProtocol,
        placesService: PlacesServiceProtocol
    ) {
        _viewModel = State(
            wrappedValue: MentorsViewModel(
                mentorsService: mentorsService,
                sportsService: sportsService,
                placesService: placesService
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                headerSection
                sportChips
                placePicker
                    .padding(.horizontal, theme.spacing.md)
                mentorsList
                    .padding(.horizontal, theme.spacing.md)
            }
        }
        .background(theme.colors.background)
        .task { await viewModel.loadInitial() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(PlacesStrings.mentorsLabel.localized.uppercased())
                .dsTextStyle(.caption, color: \.primary)
                .tracking(1.5)

            Text(PlacesStrings.mentorsSearchTitle.localized)
                .dsTextStyle(.largeTitle)

            Text(PlacesStrings.mentorsSearchDescription.localized)
                .dsTextStyle(.subheadline)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.top, theme.spacing.sm)
    }

    // MARK: - Sport Chips

    private var sportChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.xs) {
                ForEach(viewModel.sports) { sport in
                    DSChip(
                        title: sport.name,
                        isSelected: viewModel.selectedSportId == sport.id
                    ) {
                        withAnimation(.snappy(duration: Constants.Animation.chipDuration)) {
                            viewModel.toggleSport(sport.id)
                        }
                    }
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.xs)
        }
    }

    // MARK: - Place Picker

    private var placePicker: some View {
        Picker(
            PlacesStrings.mentorsAllSpots.localized,
            selection: $viewModel.selectedPlaceId
        ) {
            Text(PlacesStrings.mentorsAllSpots.localized).tag(UUID?.none)
            ForEach(viewModel.places) { place in
                Text(place.name).tag(Optional(place.id))
            }
        }
        .pickerStyle(.menu)
        .tint(theme.colors.textPrimary)
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.xs)
        .background(theme.colors.surfaceTertiary)
        .clipShape(Capsule())
    }

    // MARK: - List

    private var mentorsList: some View {
        LazyVStack(spacing: 0) {
            if viewModel.isLoading && viewModel.mentors.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else if viewModel.mentors.isEmpty {
                emptyState
            } else {
                ForEach(viewModel.mentors) { mentor in
                    NavigationLink(value: riderCardData(for: mentor)) {
                        MentorRow(mentor: mentor)
                    }
                    .buttonStyle(.plain)

                    if mentor.id != viewModel.mentors.last?.id {
                        Divider()
                            .overlay(theme.colors.border.opacity(0.35))
                    }
                }

                if viewModel.hasMorePages {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacing.md)
                        .task { await viewModel.loadMore() }
                }
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
    }

    private var emptyState: some View {
        VStack(spacing: theme.spacing.sm) {
            Spacer().frame(height: theme.spacing.xl)
            Image(systemName: "person.badge.shield.checkmark")
                .font(.system(size: 36))
                .foregroundStyle(theme.colors.textTertiary)
            Text(PlacesStrings.detailsMentorsEmptyTitle.localized)
                .dsTextStyle(.heading)
            Text(PlacesStrings.detailsMentorsEmptyDescription.localized)
                .dsTextStyle(.subheadline)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func riderCardData(for mentor: MentorListItem) -> PlacesRoute {
        .riderCard(
            RiderCardViewData(
                id: mentor.id,
                riderId: mentor.id,
                userId: nil,
                displayName: mentor.displayName ?? "—",
                avatarInitials: MentorRow.initials(for: mentor.displayName),
                avatarURL: mentor.avatarUrl.flatMap(URL.init(string:)),
                description: mentor.description ?? "",
                isMentor: true
            )
        )
    }
}
