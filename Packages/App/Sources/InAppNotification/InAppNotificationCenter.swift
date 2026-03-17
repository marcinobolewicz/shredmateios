import Foundation
import Observation

/// Central hub for posting and consuming in-app notification banners.
///
/// Inject via `@Environment` at the root of the view hierarchy.
/// Post notifications from anywhere (socket handler, push delegate, etc.).
@MainActor
@Observable
public final class InAppNotificationCenter {

    /// The currently visible notification, or `nil` when dismissed.
    public private(set) var current: InAppNotification?

    private var dismissTask: Task<Void, Never>?

    public init() {}

    /// Shows a notification banner for a fixed duration.
    ///
    /// If another notification is already visible it is replaced immediately.
    public func post(_ notification: InAppNotification, duration: TimeInterval = 3.5) {
        dismissTask?.cancel()
        current = notification

        dismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            self?.current = nil
        }
    }

    /// Dismisses the current notification immediately.
    public func dismiss() {
        dismissTask?.cancel()
        current = nil
    }
}
