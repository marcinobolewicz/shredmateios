import SwiftUI
import Networking

enum PlacesDisplayMode: String, CaseIterable, Identifiable {
    case list
    case map
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .list: return "List"
        case .map: return "Map"
        }
    }
}

@MainActor
@Observable
public final class PlacesViewModel {
    var displayMode: PlacesDisplayMode = .list
    var searchText: String = ""
    var isLoading: Bool = false
    
    private let placesService: any PlacesServiceProtocol
    private let authState: AuthState

    
    public init(placesService: any PlacesServiceProtocol, authState: AuthState) {
        self.placesService = placesService
        self.authState = authState
    }
    
    func loadOnAppear() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let skiPlaces = try await placesService.fetchPlaces(sportSlug: "ski")
            print(skiPlaces)
        } catch {
            // handle
        }
    }

}
