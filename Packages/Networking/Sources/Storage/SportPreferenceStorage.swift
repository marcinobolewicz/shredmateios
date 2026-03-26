import Foundation

public protocol SportPreferenceStorageProtocol: Sendable {
    func savedSportSlug() async -> String?
    func saveSportSlug(_ slug: String?) async
}

public actor SportPreferenceStorage: SportPreferenceStorageProtocol {
    private let defaults: UserDefaults
    private let key = "com.shredmate.selectedSportSlug"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func savedSportSlug() -> String? {
        defaults.string(forKey: key)
    }

    public func saveSportSlug(_ slug: String?) {
        if let slug {
            defaults.set(slug, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }
}
