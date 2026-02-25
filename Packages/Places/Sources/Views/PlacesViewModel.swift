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

    let repository: any PlacesRepositoryProtocol
    private let presenter: SpotRowPresenter

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
        load(force: true)
    }

    func load(force: Bool = false) {
        if case .loading = state { return }
        loadTask?.cancel()

        state = .loading

        let sportSlug = selectedSport?.slug

        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let places = try await repository.fetchPlaces(for: sportSlug)
                try Task.checkCancellation()

                let filtered = self.applySearch(places: places, text: self.searchText)
                let rows = filtered.map { presenter.map(place: $0) }

                self.rows = rows
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
        load(force: true)
    }

    func onSportChanged(_ sport: PlaceSport) {
        selectedSport = sport
        load(force: true)
    }

    func applySearch(places: [Place], text: String) -> [Place] {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return places }
        return places.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
