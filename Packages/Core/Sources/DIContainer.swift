import Foundation

/// Actor-based dependency container for managing app-wide dependencies
@MainActor
public final class DIContainer: Sendable {
    public static let shared = DIContainer()
    
    private var dependencies: [String: Any] = [:]
    
    private init() {}
    
    /// Register a dependency
    public func register<T>(_ type: T.Type, factory: @Sendable @escaping () -> T) {
        let key = String(describing: type)
        dependencies[key] = factory
    }
    
    /// Resolve a dependency
    public func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        guard let factory = dependencies[key] as? () -> T else {
            return nil
        }
        return factory()
    }
}
