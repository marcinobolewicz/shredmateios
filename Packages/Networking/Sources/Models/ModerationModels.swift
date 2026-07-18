import Foundation

/// What is being reported.
public enum ReportTargetType: String, Codable, Sendable {
    case rider = "RIDER"
    case message = "MESSAGE"
    case activity = "ACTIVITY"
}

/// Why the content/user is being reported.
public enum ReportReason: String, Codable, Sendable, CaseIterable, Identifiable {
    case spam = "SPAM"
    case harassment = "HARASSMENT"
    case inappropriateContent = "INAPPROPRIATE_CONTENT"
    case fakeProfile = "FAKE_PROFILE"
    case safety = "SAFETY"
    case other = "OTHER"

    public var id: String { rawValue }
}

/// Request body of `POST /reports`.
public struct CreateReportRequest: Codable, Sendable {
    public let targetType: ReportTargetType
    public let targetId: String
    public let reason: ReportReason
    public let comment: String?

    public init(targetType: ReportTargetType, targetId: String, reason: ReportReason, comment: String? = nil) {
        self.targetType = targetType
        self.targetId = targetId
        self.reason = reason
        self.comment = comment
    }
}

/// Response of `POST /reports`.
public struct ReportResponse: Codable, Sendable {
    public let id: String
    public let status: String
    public let createdAt: String
}

/// Request body of `POST /blocks`.
public struct CreateBlockRequest: Codable, Sendable {
    public let blockedUserId: String

    public init(blockedUserId: String) {
        self.blockedUserId = blockedUserId
    }
}

/// One row of `GET /blocks`.
public struct BlockedUser: Codable, Sendable, Identifiable {
    public let userId: String
    public let riderId: String?
    public let displayName: String?
    public let avatarUrl: String?
    public let blockedAt: String

    public var id: String { userId }
}
