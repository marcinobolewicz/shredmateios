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
    private(set) var sports: [PlaceSport] = []
    private(set) var selectedSport: PlaceSport? = nil
    var displayMode: PlacesDisplayMode = .list
    var searchText: String = ""
    var shouldShowSportFilter: Bool { sports.count > 1 }
    
    private(set) var state: LoadState = .idle

    private(set) var availableTags: [PlaceTag] = []
    private(set) var selectedTagIds: Set<UUID> = []

    private let repository: any PlacesRepositoryProtocol
    private let presenter: SpotRowPresenter
    private let sportPreferenceStorage: any SportPreferenceStorageProtocol

    private var allPlaces: [Place] = []
    private var loadTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?

    init(
        repository: any PlacesRepositoryProtocol,
        presenter: SpotRowPresenter = .init(),
        sportPreferenceStorage: any SportPreferenceStorageProtocol
    ) {
        self.repository = repository
        self.presenter = presenter
        self.sportPreferenceStorage = sportPreferenceStorage
    }

    func loadOnAppear() async {
        guard case .idle = state else { return }
        await loadSports()
        load()
    }

    private func loadSports() async {
        guard sports.isEmpty else { return }
        do {
            sports = try await repository.fetchSports()
            await applySavedSportPreference()
            autoSelectSingleSportIfNeeded()
        } catch {
            state = .failed(.from(error))
        }
    }

    private func applySavedSportPreference() async {
        guard selectedSport == nil else { return }
        let savedSlug = await sportPreferenceStorage.savedSportSlug()
        guard let savedSlug,
              let match = sports.first(where: { $0.slug == savedSlug }) else { return }
        selectedSport = match
    }

    private func autoSelectSingleSportIfNeeded() {
        guard sports.count == 1, let only = sports.first, selectedSport != only else { return }
        selectedSport = only
    }

    func syncSportPreference() async {
        guard !sports.isEmpty, case .loaded = state else { return }
        let savedSlug = await sportPreferenceStorage.savedSportSlug()
        let currentSlug = selectedSport?.slug

        guard savedSlug != currentSlug else { return }

        let match = savedSlug.flatMap { slug in sports.first { $0.slug == slug } }
        selectedSport = match
        selectedTagIds.removeAll()
        load()
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
            do {
                guard let self else { throw CancellationError() }
                
                let places = try await repository.fetchPlaces(for: sportSlug)
                try Task.checkCancellation()

                allPlaces = places
                availableTags = Self.extractTags(from: places)
                applyFilters()
                state = .loaded
            } catch is CancellationError {
                self?.state = .idle
            } catch {
                self?.state = .failed(.from(error))
            }
        }
    }

    func selectSport(_ sport: PlaceSport) {
        let newSport = selectedSport == sport ? nil : sport
        selectedSport = newSport
        selectedTagIds.removeAll()
        Task { await sportPreferenceStorage.saveSportSlug(newSport?.slug) }
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

    func searchTextChanged() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            applyFilters()
        }
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
