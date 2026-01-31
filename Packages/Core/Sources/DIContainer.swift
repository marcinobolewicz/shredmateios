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

@MainActor
public final class DIContainer {
    public static let shared = DIContainer()
    private var dependencies: [String: Any] = [:]
    private init() {}

    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        dependencies[String(describing: type)] = factory
    }

    public func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        guard let factory = dependencies[key] as? (() -> T) else { return nil }
        return factory()
    }
}

