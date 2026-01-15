import Foundation

/// Type-erased sendable factory wrapper
private struct SendableFactory<T>: @unchecked Sendable {
    let create: @Sendable () -> T
    
    init(_ factory: @escaping @Sendable () -> T) {
        self.create = factory
    }
}

/// DI Container errors
public enum DIContainerError: Error {
    case dependencyNotFound(String)
}

/// Actor-based dependency container for managing app-wide dependencies
@MainActor
public final class DIContainer: Sendable {
    public static let shared = DIContainer()
    
    private var dependencies: [String: Any] = [:]
    
    private init() {}
    
    /// Register a dependency
    public func register<T>(_ type: T.Type, factory: @Sendable @escaping () -> T) {
        let key = String(describing: type)
        dependencies[key] = SendableFactory(factory)
    }
    
    /// Resolve a dependency (returns nil if not found)
    public func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        guard let wrapper = dependencies[key] as? SendableFactory<T> else {
            return nil
        }
        return wrapper.create()
    }
    
    /// Resolve a required dependency (throws if not found)
    public func resolveRequired<T>(_ type: T.Type) throws -> T {
        guard let dependency = resolve(type) else {
            throw DIContainerError.dependencyNotFound(String(describing: type))
        }
        return dependency
    }
}
