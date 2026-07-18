import Foundation
import Observation

/// Reports abuse and blocks/unblocks users. Injected into the SwiftUI environment
/// (like `StripePaymentService`) so any screen showing another user can offer the
/// moderation actions required by App Store Guideline 1.2.
@MainActor
@Observable
public final class ModerationService {

    private let client: APIClienting

    /// User ids the current user has blocked, cached for quick UI state.
    /// Refreshed via `refreshBlocks()`; updated optimistically on block/unblock.
    public private(set) var blockedUserIds: Set<String> = []

    public init(client: APIClienting) {
        self.client = client
    }

    public func report(
        targetType: ReportTargetType,
        targetId: String,
        reason: ReportReason,
        comment: String? = nil
    ) async throws {
        _ = try await client.send(
            ModerationAPI.report(
                CreateReportRequest(targetType: targetType, targetId: targetId, reason: reason, comment: comment)
            )
        )
    }

    public func block(userId: String) async throws {
        _ = try await client.send(ModerationAPI.block(userId: userId))
        blockedUserIds.insert(userId)
    }

    public func unblock(userId: String) async throws {
        _ = try await client.send(ModerationAPI.unblock(userId: userId))
        blockedUserIds.remove(userId)
    }

    public func refreshBlocks() async {
        do {
            let blocks = try await client.send(ModerationAPI.listBlocks())
            blockedUserIds = Set(blocks.map(\.userId))
        } catch {
            // Non-fatal: leave the cached set as-is.
        }
    }

    public func isBlocked(userId: String) -> Bool {
        blockedUserIds.contains(userId)
    }
}
