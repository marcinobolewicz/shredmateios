import Foundation

/// Type of a legal document published by the platform.
/// Decodes unknown future values as `.unknown` so adding a new type
/// on the backend never breaks older clients.
public enum LegalDocumentType: String, Codable, Sendable, Equatable, CaseIterable {
    case terms = "TERMS"
    case mentorTerms = "MENTOR_TERMS"
    case privacy = "PRIVACY"
    case unknown = "UNKNOWN"

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = LegalDocumentType(rawValue: raw) ?? .unknown
    }
}

/// A published, immutable version of a legal document.
public struct LegalDocument: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let type: LegalDocumentType
    public let version: String
    public let url: String
    public let publishedAt: String

    public init(id: String, type: LegalDocumentType, version: String, url: String, publishedAt: String) {
        self.id = id
        self.type = type
        self.version = version
        self.url = url
        self.publishedAt = publishedAt
    }
}

/// Response of `GET /legal/status` and `POST /legal/accept`.
public struct LegalStatus: Codable, Sendable, Equatable {
    /// All current document versions.
    public let documents: [LegalDocument]
    /// Current documents the user has not accepted yet.
    public let requiresAcceptance: [LegalDocument]

    public init(documents: [LegalDocument], requiresAcceptance: [LegalDocument]) {
        self.documents = documents
        self.requiresAcceptance = requiresAcceptance
    }
}

/// A single accepted document reference sent to the backend.
public struct AcceptedDocument: Codable, Sendable, Equatable {
    public let type: LegalDocumentType
    public let version: String

    public init(type: LegalDocumentType, version: String) {
        self.type = type
        self.version = version
    }

    public init(document: LegalDocument) {
        self.type = document.type
        self.version = document.version
    }
}

/// Context reported with `POST /legal/accept`
/// (REGISTRATION is recorded server-side via /auth/register).
public enum LegalAcceptanceContext: String, Codable, Sendable {
    case reacceptance = "REACCEPTANCE"
    case mentorOnboarding = "MENTOR_ONBOARDING"
}

/// Request body of `POST /legal/accept`.
public struct AcceptLegalRequest: Codable, Sendable {
    public let documents: [AcceptedDocument]
    public let context: LegalAcceptanceContext

    public init(documents: [AcceptedDocument], context: LegalAcceptanceContext) {
        self.documents = documents
        self.context = context
    }
}
