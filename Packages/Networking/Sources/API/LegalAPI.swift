import Foundation

/// Legal documents & consent API endpoints
public enum LegalAPI {

    /// Current versions of legal documents (public)
    public static func documents() -> Endpoint<[LegalDocument]> {
        .get("/legal/documents")
    }

    /// Which current documents the user still has to accept
    public static func status() -> Endpoint<LegalStatus> {
        .get("/legal/status", auth: .bearerToken)
    }

    /// Accept current versions of legal documents
    public static func accept(
        documents: [AcceptedDocument],
        context: LegalAcceptanceContext
    ) -> Endpoint<LegalStatus> {
        .post(
            "/legal/accept",
            body: AcceptLegalRequest(documents: documents, context: context),
            keys: .camelCase,
            auth: .bearerToken
        )
    }
}
