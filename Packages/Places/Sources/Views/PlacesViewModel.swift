import SwiftUI
import Networking
import Common

enum PlacesDisplayMode: String, CaseIterable, Identifiable {
    case list
    case map
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .list: return PlacesStrings.displayModeList.localized
        case .map: return PlacesStrings.displayModeMap.localized
        }
    }
}

@MainActor
@Observable
public final class PlacesViewModel {

    private(set) var rows: [SpotRowViewData] = []
    var sports: [PlaceSport] = []
    var selectedSport: PlaceSport? = nil
    var displayMode: PlacesDisplayMode = .list
    var searchText: String = ""
    private(set) var state: LoadState = .idle

    private(set) var availableTags: [PlaceTag] = []
    var selectedTagIds: Set<UUID> = []

    let repository: any PlacesRepositoryProtocol
    private let presenter: SpotRowPresenter

    private var allPlaces: [Place] = []
    private var loadTask: Task<Void, Never>?

    init(
        repository: any PlacesRepositoryProtocol,
        presenter: SpotRowPresenter = .init()
    ) {
        self.repository = repository
        self.presenter = presenter
    }

    func loadOnAppear() {
        guard case .idle = state else { return }
        loadSports()
        load()
    }
    
    private func loadSports() {
        guard sports.isEmpty else { return }
        Task { [weak self] in
            guard let self else { return }
            
            do {
                self.sports = try await repository.fetchSports()
            } catch {
                self.state = .failed(.from(error))
            }
        }
    }
    
    func refresh() {
        load()
    }

    func load() {
        if case .loading = state { return }
        loadTask?.cancel()

        state = .loading

        let sportSlug = selectedSport?.slug

        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let places = try await repository.fetchPlaces(for: sportSlug)
                try Task.checkCancellation()

                self.allPlaces = places
                self.availableTags = Self.extractTags(from: places)
                self.applyFilters()
                self.state = .loaded
            } catch is CancellationError {
                self.state = .idle
            } catch {
                self.state = .failed(.from(error))
            }
        }
    }

    func selectSport(_ sport: PlaceSport) {
        selectedSport = sport
        selectedTagIds.removeAll()
        load()
    }

    func toggleTag(_ tagId: UUID) {
        if selectedTagIds.contains(tagId) {
            selectedTagIds.remove(tagId)
        } else {
            selectedTagIds.insert(tagId)
        }
        applyFilters()
    }

    func applyFilters() {
        var result = allPlaces

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }

        if !selectedTagIds.isEmpty {
            result = result.filter { place in
                let placeTagIds = Set(place.tags.map(\.id))
                return selectedTagIds.isSubset(of: placeTagIds)
            }
        }

        rows = result.map { presenter.map(place: $0) }
    }

    private static func extractTags(from places: [Place]) -> [PlaceTag] {
        var seen = Set<UUID>()
        var tags: [PlaceTag] = []
        for place in places {
            for tag in place.tags where seen.insert(tag.id).inserted {
                tags.append(tag)
            }
        }
        return tags.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }
}
