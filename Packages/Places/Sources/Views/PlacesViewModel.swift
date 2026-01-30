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
final class PlacesViewModel {
    var displayMode: PlacesDisplayMode = .list
    var searchText: String = ""
    var isLoading: Bool = false
    
//    let service = PlacesService(client: DefaultHTTPClient())
    
    private var loadTask: Task<Void, Never>?
    
    init() {}
    
    func loadOnAppear() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                do {
//                    try await service.pl
                } catch {
                    break
                }
            }
        }
    }
}
