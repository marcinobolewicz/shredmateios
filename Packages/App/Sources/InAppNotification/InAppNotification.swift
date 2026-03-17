import Foundation

/// Represents an in-app notification displayed as a banner overlay.
@MainActor
public struct InAppNotification: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let body: String
    public let conversationId: String?

    public init(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        conversationId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.conversationId = conversationId
    }
}
