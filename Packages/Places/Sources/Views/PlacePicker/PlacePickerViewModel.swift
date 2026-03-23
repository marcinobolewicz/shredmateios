import Foundation
import Networking
import Common

@MainActor
@Observable
final class PlacePickerViewModel {

    private(set) var places: [Place] = []
    var searchText: String = ""
    private(set) var isLoading = false
    var error: AppError?

    private let placesService: any PlacesServiceProtocol

    init(placesService: any PlacesServiceProtocol) {
        self.placesService = placesService
    }

    var filtered: [Place] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return places }
        return places.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    func load() async {
        guard places.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let dtos = try await placesService.fetchPlaces(sportSlug: nil)
            places = dtos.map { PlaceMapper.map($0) }
        } catch {
            self.error = .from(error)
        }
    }
}
