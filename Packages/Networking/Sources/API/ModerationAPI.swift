import Foundation

/// Moderation API — report abuse, block/unblock users.
public enum ModerationAPI {

    public static func report(_ body: CreateReportRequest) -> Endpoint<ReportResponse> {
        .post("/reports", body: body, keys: .camelCase, auth: .bearerToken)
    }

    public static func block(userId: String) -> Endpoint<CreateBlockResponse> {
        .post("/blocks", body: CreateBlockRequest(blockedUserId: userId), keys: .camelCase, auth: .bearerToken)
    }

    public static func unblock(userId: String) -> Endpoint<EmptyResponse> {
        .delete("/blocks/\(userId)", auth: .bearerToken)
    }

    public static func listBlocks() -> Endpoint<[BlockedUser]> {
        .get("/blocks", auth: .bearerToken)
    }
}

/// Response of `POST /blocks`.
public struct CreateBlockResponse: Codable, Sendable {
    public let blockedUserId: String
}
