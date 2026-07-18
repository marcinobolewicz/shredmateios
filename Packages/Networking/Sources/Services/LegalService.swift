import Foundation

/// Protocol for legal documents & consent operations (enables testing)
public protocol LegalServiceProtocol: Sendable {
    func fetchDocuments() async throws -> [LegalDocument]
    func fetchStatus() async throws -> LegalStatus
    func accept(documents: [AcceptedDocument], context: LegalAcceptanceContext) async throws -> LegalStatus
}

public final class LegalService: LegalServiceProtocol, Sendable {

    private let client: APIClienting

    public init(client: APIClienting) {
        self.client = client
    }

    public func fetchDocuments() async throws -> [LegalDocument] {
        try await client.send(LegalAPI.documents())
    }

    public func fetchStatus() async throws -> LegalStatus {
        try await client.send(LegalAPI.status())
    }

    public func accept(
        documents: [AcceptedDocument],
        context: LegalAcceptanceContext
    ) async throws -> LegalStatus {
        try await client.send(LegalAPI.accept(documents: documents, context: context))
    }
}
