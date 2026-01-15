import Foundation

/// Configuration actor for managing app configuration
public actor AppConfiguration: Sendable {
    public static let shared = AppConfiguration()
    
    private var config: [String: String] = [:]
    
    private init() {
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        // Load from Info.plist or environment
        if let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String {
            config["API_BASE_URL"] = baseURL
        }
        
        if let environment = Bundle.main.infoDictionary?["ENVIRONMENT"] as? String {
            config["ENVIRONMENT"] = environment
        }
    }
    
    public func getValue(for key: String) -> String? {
        return config[key]
    }
    
    public func getAPIBaseURL() -> String {
        return config["API_BASE_URL"] ?? "https://api.shredmate.app"
    }
    
    public func getEnvironment() -> String {
        return config["ENVIRONMENT"] ?? "PROD"
    }
}
