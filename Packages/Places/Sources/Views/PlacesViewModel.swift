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
    var selectedSport: Sport = .snowboard
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
        load()
    }

    public func refresh() {
        load(force: true)
    }

    public func load(force: Bool = false) {
        if case .loading = state { return }
        loadTask?.cancel()

        state = .loading

        let sport = selectedSport
        let sportSlug = sport.slug

        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let places = try await repository.fetchPlaces(for: nil)
                try Task.checkCancellation()

                let filtered = self.applySearch(places: places, text: self.searchText)
                let rows = filtered.map { presenter.map(place: $0, sport: sport) }

                self.rows = rows
                self.state = .loaded
            } catch is CancellationError {
                // no state change if cancel is caused by sport change
                self.state = .idle
            } catch {
                self.state = .failed(.from(error))
            }
        }
    }

    func onSportChanged(_ sport: Sport) {
        selectedSport = sport
        load(force: true)
    }

    func applySearch(places: [Place], text: String) -> [Place] {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return places }
        return places.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }
}

extension Sport {
    var slug: String {
        switch self {
        case .snowboard: return "snowboard"
        case .narty: return "ski"
        case .kitesurfing: return "kitesurfing"
        case .wakeboard: return "wakeboard"
        }
    }
}

