import Foundation
import Networking

@MainActor
@Observable
final class MentorsViewModel {

    // MARK: - State

    private(set) var mentors: [MentorListItem] = []
    private(set) var isLoading = false
    private(set) var hasMorePages = true

    var selectedSportId: UUID? {
        didSet {
            guard oldValue != selectedSportId else { return }
            selectedPlaceId = nil
            reloadPlaces()
            resetAndLoad()
        }
    }

    func toggleSport(_ sportId: UUID) {
        selectedSportId = selectedSportId == sportId ? nil : sportId
    }

    var selectedPlaceId: UUID? {
        didSet { if oldValue != selectedPlaceId { resetAndLoad() } }
    }

    private(set) var sports: [Sport] = []
    private(set) var places: [PlaceDto] = []

    // MARK: - Dependencies

    private let mentorsService: any MentorsServiceProtocol
    private let sportsService: any SportsServiceProtocol
    private let placesService: any PlacesServiceProtocol
    private var currentPage = 1

    // MARK: - Init

    init(
        mentorsService: any MentorsServiceProtocol,
        sportsService: any SportsServiceProtocol,
        placesService: any PlacesServiceProtocol
    ) {
        self.mentorsService = mentorsService
        self.sportsService = sportsService
        self.placesService = placesService
    }

    // MARK: - Loading

    func loadInitial() async {
        async let sportsResult = sportsService.fetchSports()
        async let placesResult = placesService.fetchPlaces(sportSlug: nil)
        async let mentorsResult = fetchPage(1)

        sports = (try? await sportsResult) ?? []
        places = (try? await placesResult) ?? []
        await mentorsResult
    }

    func loadMore() async {
        guard !isLoading, hasMorePages else { return }
        await fetchPage(currentPage + 1)
    }

    // MARK: - Private

    private var selectedSportSlug: String? {
        guard let selectedSportId else { return nil }
        return sports.first { $0.id == selectedSportId }?.slug
    }

    private func reloadPlaces() {
        Task {
            places = (try? await placesService.fetchPlaces(sportSlug: selectedSportSlug)) ?? []
        }
    }

    private func resetAndLoad() {
        mentors = []
        currentPage = 1
        hasMorePages = true
        Task { await fetchPage(1) }
    }

    @discardableResult
    private func fetchPage(_ page: Int) async -> Void {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await mentorsService.fetchMentors(
                sportId: selectedSportId,
                placeId: selectedPlaceId,
                page: page,
                limit: 20
            )
            if page == 1 {
                mentors = response.items
            } else {
                mentors.append(contentsOf: response.items)
            }
            currentPage = page
            hasMorePages = mentors.count < response.total
        } catch {
            // Silently handle — list stays as-is
        }
    }
}
