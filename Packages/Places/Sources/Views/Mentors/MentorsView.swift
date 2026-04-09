import SwiftUI
import Theme
import Networking

struct MentorsView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(PlacesRouter.self) private var router
    @State private var viewModel: MentorsViewModel
    @State private var appearCount = 0

    init(
        mentorsService: MentorsServiceProtocol,
        sportsService: SportsServiceProtocol,
        placesService: PlacesServiceProtocol,
        sportPreferenceStorage: any SportPreferenceStorageProtocol
    ) {
        _viewModel = State(
            wrappedValue: MentorsViewModel(
                mentorsService: mentorsService,
                sportsService: sportsService,
                placesService: placesService,
                sportPreferenceStorage: sportPreferenceStorage
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                DSScreenHeader(title: PlacesStrings.mentorsLabel.localized)
                sportChips
                placePicker
                    .padding(.horizontal, theme.spacing.md)
                mentorsList
            }
        }
        .background(theme.colors.backgroundSecondary)
        .refreshable { await viewModel.refresh() }
        .task { await viewModel.loadInitial() }
        .onAppear { appearCount += 1 }
        .task(id: appearCount) {
            guard appearCount > 0 else { return }
            await viewModel.syncSportPreference()
        }
    }

    // MARK: - Sport Chips

    @ViewBuilder
    private var sportChips: some View {
        if viewModel.shouldShowSportFilter {
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
        .background(theme.colors.background)
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
                    Button {
                        router.navigate(to: riderCardData(for: mentor))
                    } label: {
                        MentorRow(mentor: mentor)
                            .padding(.horizontal, theme.spacing.md)
                    }
                    .buttonStyle(.plain)

                    if mentor.id != viewModel.mentors.last?.id {
                        Divider()
                            .padding(.horizontal, theme.spacing.md)
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
